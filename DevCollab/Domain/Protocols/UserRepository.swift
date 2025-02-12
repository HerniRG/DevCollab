protocol UserRepository {
    func updateUserData(userID: String,
                        nombre: String,
                        descripcion: String,
                        lenguajes: [LenguajeProgramacion]) async throws
    func obtenerUsuario(usuarioID: String) async throws -> Usuario

}
