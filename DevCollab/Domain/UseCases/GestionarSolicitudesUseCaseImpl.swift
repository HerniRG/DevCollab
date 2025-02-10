protocol GestionarSolicitudesUseCaseProtocol {
    func obtenerEstadoProyecto(proyectoID: String) async throws -> String
    func cambiarEstadoProyecto(proyectoID: String, nuevoEstado: String) async throws
    func enviarSolicitud(proyectoID: String, usuarioID: String, mensaje: String) async throws
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async throws
    func abandonarProyecto(proyectoID: String, usuarioID: String) async throws
}

class GestionarSolicitudesUseCaseImpl: GestionarSolicitudesUseCaseProtocol {
    private let repository: SolicitudRepository
    
    init(repository: SolicitudRepository) {
        self.repository = repository
    }
    
    func obtenerEstadoProyecto(proyectoID: String) async throws -> String {
        return try await repository.obtenerEstadoProyecto(proyectoID: proyectoID)
    }
    
    func cambiarEstadoProyecto(proyectoID: String, nuevoEstado: String) async throws {
        try await repository.cambiarEstadoProyecto(proyectoID: proyectoID, nuevoEstado: nuevoEstado)
    }
    
    func enviarSolicitud(proyectoID: String, usuarioID: String, mensaje: String) async throws {
        try await repository.enviarSolicitud(proyectoID: proyectoID, usuarioID: usuarioID, mensaje: mensaje)
    }
    
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async throws {
        try await repository.actualizarEstadoSolicitud(solicitudID: solicitudID, estado: estado)
    }
    
    func abandonarProyecto(proyectoID: String, usuarioID: String) async throws {
        try await repository.abandonarProyecto(proyectoID: proyectoID, usuarioID: usuarioID)
    }
}
