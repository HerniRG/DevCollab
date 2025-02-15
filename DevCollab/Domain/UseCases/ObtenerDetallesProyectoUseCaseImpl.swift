protocol ObtenerDetallesProyectoUseCaseProtocol {
    /// Retorna una tupla con:
    /// - nombreCreador: String
    /// - descripcionCreador: String
    /// - lenguajesCreador: [String]
    /// - correoCreador: String
    /// - yaSolicitado: Bool
    /// - esCreador: Bool
    /// - soyParticipante: Bool
    func ejecutar(proyectoID: String, userID: String) async throws -> (
        nombreCreador: String,
        descripcionCreador: String,
        lenguajesCreador: [String],
        correoCreador: String,
        yaSolicitado: Bool,
        esCreador: Bool,
        soyParticipante: Bool
    )
}
class ObtenerDetallesProyectoUseCaseImpl: ObtenerDetallesProyectoUseCaseProtocol {
    private let repository: ProyectoRepository
    
    init(repository: ProyectoRepository) {
        self.repository = repository
    }
    
    func ejecutar(proyectoID: String, userID: String) async throws -> (
        nombreCreador: String,
        descripcionCreador: String,
        lenguajesCreador: [String],
        correoCreador: String,
        yaSolicitado: Bool,
        esCreador: Bool,
        soyParticipante: Bool
    ) {
        return try await repository.obtenerDetallesProyecto(proyectoID: proyectoID, userID: userID)
    }
}
