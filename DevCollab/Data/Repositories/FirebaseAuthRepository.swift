import FirebaseAuth
import FirebaseFirestore

class FirebaseAuthRepository: AuthRepository {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    func register(email: String, password: String, nombre: String, lenguajes: [LenguajeProgramacion], descripcion: String?) async throws -> Usuario {
        let result = try await auth.createUser(withEmail: email, password: password)
        let usuario = Usuario(
            id: result.user.uid,
            nombre: nombre,
            lenguajes: lenguajes,
            descripcion: descripcion
        )
        try await saveUserData(usuario: usuario)
        return usuario
    }
    
    private func saveUserData(usuario: Usuario) async throws {
        let userData: [String: Any] = [
            "nombre": usuario.nombre,
            "lenguajes": usuario.lenguajes.map { $0.rawValue },
            "descripcion": usuario.descripcion ?? ""
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
        let result = try await auth.signIn(withEmail: email, password: password)
        return try await getCurrentUser() ?? Usuario(id: result.user.uid, nombre: "", lenguajes: [], descripcion: nil)
    }
    
    func logout() async throws {
        try auth.signOut()
    }
    
    /// 🔥 **Nuevo método para restablecer contraseña**
    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
}
