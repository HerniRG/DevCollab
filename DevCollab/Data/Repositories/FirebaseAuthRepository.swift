import FirebaseAuth
import FirebaseFirestore

class FirebaseAuthRepository: AuthRepository {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    func register(email: String, password: String, nombre: String, lenguajes: [LenguajeProgramacion], descripcion: String?) async throws -> Usuario {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            
            // Enviar email de verificación tras el registro
            try await result.user.sendEmailVerification()
            
            let usuario = Usuario(
                id: result.user.uid,
                nombre: nombre,
                lenguajes: lenguajes,
                descripcion: descripcion,
                correo: email
            )
            try await saveUserData(usuario: usuario, email: email)
            return usuario
        } catch {
            throw (error as NSError).toAuthRepositoryError()
        }
    }
    
    private func saveUserData(usuario: Usuario, email: String) async throws {
        // 🔍 Verificar si ya existe un usuario con este correo en Firestore
        let snapshot = try await db.collection("usuarios")
            .whereField("correo", isEqualTo: email)
            .getDocuments()
        
        if !snapshot.documents.isEmpty {
            throw NSError(domain: "Firestore", code: 409, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("auth_email_exists", comment: "Error cuando el email ya está registrado")])
        }
        
        // 🔥 Si el correo no existe, guardamos el nuevo usuario
        let userData: [String: Any] = [
            "nombre": usuario.nombre,
            "lenguajes": usuario.lenguajes.map { $0.rawValue },
            "descripcion": usuario.descripcion ?? "",
            "correo": email  // Guardamos el correo también
        ]
        try await db.collection("usuarios").document(usuario.id).setData(userData)
    }
    
    func getCurrentUser() async throws -> Usuario? {
        guard let user = auth.currentUser else { return nil }
        
        // 🔍 Si el usuario no verificó su email, cerramos sesión
        if !user.isEmailVerified {
            try await logout()
            throw AuthRepositoryError.emailNotVerified
        }

        let document = try await db.collection("usuarios").document(user.uid).getDocument()
        guard let data = document.data() else { return nil }

        return Usuario(
            id: user.uid,
            nombre: data["nombre"] as? String ?? "",
            lenguajes: (data["lenguajes"] as? [String])?.compactMap { LenguajeProgramacion(rawValue: $0) } ?? [],
            descripcion: data["descripcion"] as? String,
            correo: data["correo"] as? String ?? ""
        )
    }
    
    func login(email: String, password: String) async throws -> Usuario {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            
            // Verificar que el email esté verificado
            if !result.user.isEmailVerified {
                throw AuthRepositoryError.emailNotVerified
            }
            
            return try await getCurrentUser() ?? Usuario(id: result.user.uid, nombre: "", lenguajes: [], descripcion: nil, correo: email)
        } catch {
            throw (error as NSError).toAuthRepositoryError()
        }
    }
    
    func logout() async throws {
        do {
            try auth.signOut()
        } catch {
            throw (error as NSError).toAuthRepositoryError()
        }
    }
    
    /// Método para restablecer la contraseña
    func resetPassword(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw (error as NSError).toAuthRepositoryError()
        }
    }
    
    func checkIfEmailExists(_ email: String) async throws -> Bool {
        let snapshot = try await db.collection("usuarios")
            .whereField("correo", isEqualTo: email)
            .getDocuments()
        return !snapshot.documents.isEmpty
    }
    
    /// Método opcional para reenviar el correo de verificación
    func resendVerificationEmail() async throws {
        guard let user = auth.currentUser else {
            throw AuthRepositoryError.userNotFound
        }
        try await user.sendEmailVerification()
    }
    
    func deleteAccount(password: String) async throws {
        guard let user = auth.currentUser, let email = user.email else {
            throw AuthRepositoryError.userNotFound
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        do {
            // 1️⃣ 🔄 Re-autenticamos al usuario antes de eliminar la cuenta
            try await user.reauthenticate(with: credential)

            // 2️⃣ 🗑️ Eliminamos primero los datos del usuario en Firestore
            do {
                try await db.collection("usuarios").document(user.uid).delete()
            } catch {
                throw AuthRepositoryError.unknown(error)
            }

            // 3️⃣ 🚀 Eliminamos la cuenta de Firebase Authentication
            do {
                try await user.delete()
            } catch let authError as NSError {
                switch authError.code {
                case AuthErrorCode.requiresRecentLogin.rawValue:
                    throw AuthRepositoryError.emailNotVerified
                default:
                    throw AuthRepositoryError.unknown(authError)
                }
            }

            // 4️⃣ ✅ Cerramos sesión manualmente para evitar que el usuario siga autenticado
            try await logout()

        } catch {
            throw error
        }
    }
}

extension NSError {
    func toAuthRepositoryError() -> AuthRepositoryError {
        guard self.domain == AuthErrorDomain else {
            return .unknown(self)
        }
        
        switch self.code {
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.weakPassword.rawValue:
            return .weakPassword
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.wrongPassword.rawValue, 17004:
            return .wrongPassword
        default:
            debugPrint("Error no mapeado en AuthRepositoryError: domain: \(self.domain), code: \(self.code)")
            return .unknown(self)
        }
    }
}
