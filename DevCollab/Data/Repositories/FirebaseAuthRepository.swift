import FirebaseAuth
import FirebaseFirestore

class FirebaseAuthRepository: AuthRepository {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    func register(email: String, password: String, nombre: String, lenguajes: [LenguajeProgramacion], descripcion: String?) async throws -> Usuario {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let usuario = Usuario(
                id: result.user.uid,
                nombre: nombre,
                lenguajes: lenguajes,
                descripcion: descripcion
            )
            try await saveUserData(usuario: usuario, email: email)
            return usuario
        } catch {
            throw (error as NSError).toAuthRepositoryError()
        }
    }
    
    private func saveUserData(usuario: Usuario, email: String) async throws {
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
        let document = try await db.collection("usuarios").document(user.uid).getDocument()
        guard let data = document.data() else { return nil }
        
        return Usuario(
            id: user.uid,
            nombre: data["nombre"] as? String ?? "",
            lenguajes: (data["lenguajes"] as? [String])?.compactMap { LenguajeProgramacion(rawValue: $0) } ?? [],
            descripcion: data["descripcion"] as? String
        )
    }
    
    func login(email: String, password: String) async throws -> Usuario {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return try await getCurrentUser() ?? Usuario(id: result.user.uid, nombre: "", lenguajes: [], descripcion: nil)
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
    
    /// Método para restablecer contraseña
    func resetPassword(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw (error as NSError).toAuthRepositoryError()
        }
    }
}

extension NSError {
    func toAuthRepositoryError() -> AuthRepositoryError {
        // Verifica que el dominio sea el de Firebase Auth.
        guard self.domain == AuthErrorDomain else {
            return .unknown(self)
        }
        
        // Mapea según el código de error.
        switch self.code {
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.weakPassword.rawValue:
            return .weakPassword
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        // Se añade el código 17004 para cubrir el caso de contraseña incorrecta
        case AuthErrorCode.wrongPassword.rawValue, 17004:
            return .wrongPassword
        default:
            debugPrint("Error no mapeado en AuthRepositoryError: domain: \(self.domain), code: \(self.code)")
            return .unknown(self)
        }
    }
}
