protocol GestionarSolicitudesUseCaseProtocol {
    func cambiarEstadoProyecto(proyectoID: String) async throws
    func enviarSolicitud(proyectoID: String, usuarioID: String) async throws
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async throws
    func abandonarProyecto(proyectoID: String, usuarioID: String) async throws
}

class GestionarSolicitudesUseCase: GestionarSolicitudesUseCaseProtocol {
    private let repository: SolicitudRepository
    
    init(repository: SolicitudRepository) {
        self.repository = repository
    }
    
    func cambiarEstadoProyecto(proyectoID: String) async throws {
        try await repository.cambiarEstadoProyecto(proyectoID: proyectoID)
    }
    
    func enviarSolicitud(proyectoID: String, usuarioID: String) async throws {
        try await repository.enviarSolicitud(proyectoID: proyectoID, usuarioID: usuarioID)
    }
    
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async throws {
        try await repository.actualizarEstadoSolicitud(solicitudID: solicitudID, estado: estado)
    }
    
    func abandonarProyecto(proyectoID: String, usuarioID: String) async throws {
        try await repository.abandonarProyecto(proyectoID: proyectoID, usuarioID: usuarioID)
    }
}
