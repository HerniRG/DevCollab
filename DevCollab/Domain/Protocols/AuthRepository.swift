protocol AuthRepository {
    func login(email: String, password: String) async throws -> Usuario
    func register(email: String, password: String, nombre: String, lenguajes: [LenguajeProgramacion], descripcion: String?) async throws -> Usuario
    func logout() async throws
    func getCurrentUser() async throws -> Usuario?
    func resetPassword(email: String) async throws
    func resendVerificationEmail() async throws
    func deleteAccount(password: String) async throws
}
