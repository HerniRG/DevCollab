protocol SolicitudRepository {
    func enviarSolicitud(proyectoID: String, usuarioID: String, mensaje: String) async throws
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async throws
    func cambiarEstadoProyecto(proyectoID: String, nuevoEstado: String) async throws
    func abandonarProyecto(proyectoID: String, usuarioID: String) async throws
    func obtenerSolicitudes(usuarioID: String) async throws -> [Solicitud]
    func obtenerSolicitudesPorProyecto(proyectoID: String) async throws -> [Solicitud]
    func eliminarSolicitud(proyectoID: String, usuarioID: String) async throws
    func obtenerEstadoProyecto(proyectoID: String) async throws -> String
}
