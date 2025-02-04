protocol GestionarSolicitudesUseCaseProtocol {
    func cambiarEstadoProyecto(proyectoID: String, nuevoEstado: String) async throws
    func enviarSolicitud(proyectoID: String, usuarioID: String) async throws
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async throws
    func abandonarProyecto(proyectoID: String, usuarioID: String) async throws
    func toggleEstadoProyecto(proyectoID: String) async throws -> String
}

class GestionarSolicitudesUseCaseImpl: GestionarSolicitudesUseCaseProtocol {
    private let repository: SolicitudRepository
    
    init(repository: SolicitudRepository) {
        self.repository = repository
    }
    
    func cambiarEstadoProyecto(proyectoID: String, nuevoEstado: String) async throws {
        try await repository.cambiarEstadoProyecto(proyectoID: proyectoID, nuevoEstado: nuevoEstado)
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
    
    func toggleEstadoProyecto(proyectoID: String) async throws -> String {
        let estadoActual = try await repository.obtenerEstadoProyecto(proyectoID: proyectoID)
        let nuevoEstado = estadoActual == "Abierto" ? "Cerrado" : "Abierto"
        try await repository.cambiarEstadoProyecto(proyectoID: proyectoID, nuevoEstado: nuevoEstado)
        return nuevoEstado
    }
}
