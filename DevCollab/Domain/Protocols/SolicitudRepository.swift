protocol SolicitudRepository {
    func enviarSolicitud(solicitud: Solicitud) async throws
    func obtenerSolicitudes(proyectoID: String) async throws -> [Solicitud]
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async throws
}
