protocol EnviarSolicitudUseCase {
    func execute(solicitud: Solicitud) async throws
}

class EnviarSolicitudUseCaseImpl: EnviarSolicitudUseCase {
    private let repository: SolicitudRepository
    
    init(repository: SolicitudRepository) {
        self.repository = repository
    }
    
    func execute(solicitud: Solicitud) async throws {
        try await repository.enviarSolicitud(solicitud: solicitud)
    }
}
