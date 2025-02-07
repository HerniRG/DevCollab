protocol ObtenerSolicitudesUseCase {
    func execute(usuarioID: String) async throws -> [Solicitud]
}

class ObtenerSolicitudesUseCaseImpl: ObtenerSolicitudesUseCase {
    private let repository: SolicitudRepository
    
    init(repository: SolicitudRepository) {
        self.repository = repository
    }
    
    func execute(usuarioID: String) async throws -> [Solicitud] {
        return try await repository.obtenerSolicitudes(usuarioID: usuarioID)
    }
}
