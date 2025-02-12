protocol ObtenerSolicitudesPorProyectoUseCase {
    func execute(proyectoID: String) async throws -> [Solicitud]
}

class ObtenerSolicitudesPorProyectoUseCaseImpl: ObtenerSolicitudesPorProyectoUseCase {
    private let repository: SolicitudRepository
    
    init(repository: SolicitudRepository) {
        self.repository = repository
    }
    
    func execute(proyectoID: String) async throws -> [Solicitud] {
        return try await repository.obtenerSolicitudesPorProyecto(proyectoID: proyectoID)
    }
}
