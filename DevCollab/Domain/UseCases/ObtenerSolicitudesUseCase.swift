protocol ObtenerSolicitudesUseCase {
    func execute(proyectoID: String) async throws -> [Solicitud]
}

class ObtenerSolicitudesUseCaseImpl: ObtenerSolicitudesUseCase {
    private let repository: SolicitudRepository
    
    init(repository: SolicitudRepository) {
        self.repository = repository
    }
    
    func execute(proyectoID: String) async throws -> [Solicitud] {
        return try await repository.obtenerSolicitudes(proyectoID: proyectoID)
    }
}
