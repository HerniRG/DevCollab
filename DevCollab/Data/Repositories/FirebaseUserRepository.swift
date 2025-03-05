import FirebaseFirestore

class FirebaseUserRepository: UserRepository {
    private let db = Firestore.firestore()
    
    func updateUserData(userID: String,
                        nombre: String,
                        descripcion: String,
                        lenguajes: [LenguajeProgramacion]) async throws {
        let userData: [String: Any] = [
            "nombre": nombre,
            "descripcion": descripcion,
            "lenguajes": lenguajes.map { $0.rawValue }
        ]
        try await db.collection("usuarios").document(userID).updateData(userData)
    }
    
    func obtenerUsuario(usuarioID: String) async throws -> Usuario {
        let document = try await db.collection("usuarios").document(usuarioID).getDocument()
        guard let data = document.data() else {
            throw NSError(domain: "Firestore", code: 404, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("user_not_found", comment: "El usuario no fue encontrado en la base de datos.")
            ])
        }
        
        return Usuario(
            id: usuarioID,
            nombre: data["nombre"] as? String ?? "",
            lenguajes: (data["lenguajes"] as? [String])?.compactMap { LenguajeProgramacion(rawValue: $0) } ?? [],
            descripcion: data["descripcion"] as? String,
            correo: data["correo"] as? String ?? ""  // Se agrega el correo
        )
    }
}
