import FirebaseAuth
import FirebaseFirestore

class FirebaseAuthRepository: AuthRepository {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    func register(email: String, password: String, nombre: String, lenguajes: [LenguajeProgramacion], disponibilidad: String, descripcion: String?) async throws -> Usuario {
        let result = try await auth.createUser(withEmail: email, password: password)
        let usuario = Usuario(
            id: result.user.uid,
            nombre: nombre,
            lenguajes: lenguajes,
            disponibilidad: disponibilidad,
            descripcion: descripcion
        )
        try await saveUserData(usuario: usuario)
        return usuario
    }
    
    private func saveUserData(usuario: Usuario) async throws {
        let userData: [String: Any] = [
            "nombre": usuario.nombre,
            "lenguajes": usuario.lenguajes.map { $0.rawValue },
            "disponibilidad": usuario.disponibilidad,
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
            lenguajes: (data["lenguajes"] as? [String])?.compactMap { LenguajeProgramacion(rawValue: $0) } ?? [], // Conversión de String a Enum
            disponibilidad: data["disponibilidad"] as? String ?? "",
            descripcion: data["descripcion"] as? String
        )
    }
    
    func login(email: String, password: String) async throws -> Usuario {
        let result = try await auth.signIn(withEmail: email, password: password)
        return try await getCurrentUser() ?? Usuario(id: result.user.uid, nombre: "", lenguajes: [], disponibilidad: "", descripcion: nil)
    }
    
    func logout() async throws {
        try auth.signOut()
    }
}
