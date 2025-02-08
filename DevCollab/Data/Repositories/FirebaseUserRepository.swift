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
}
