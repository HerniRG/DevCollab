protocol AuthRepository {
    func login(email: String, password: String) async throws -> Usuario
    func register(email: String, password: String, nombre: String, lenguajes: [LenguajeProgramacion], disponibilidad: String, descripcion: String?) async throws -> Usuario
    func logout() async throws
    func getCurrentUser() async throws -> Usuario?
}
