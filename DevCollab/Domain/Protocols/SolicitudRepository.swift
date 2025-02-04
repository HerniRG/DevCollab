protocol SolicitudRepository {
    func enviarSolicitud(proyectoID: String, usuarioID: String) async throws
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async throws
    func cambiarEstadoProyecto(proyectoID: String) async throws
    func abandonarProyecto(proyectoID: String, usuarioID: String) async throws
}
