protocol ProyectoRepository {
    func obtenerProyectos() async throws -> [Proyecto]
    func crearProyecto(proyecto: Proyecto) async throws
    func actualizarProyecto(proyecto: Proyecto) async throws
    func cerrarProyecto(proyectoID: String) async throws
    func eliminarProyecto(proyectoID: String) async throws
    func obtenerDetallesProyecto(proyectoID: String, userID: String) async throws -> (
        nombreCreador: String,
        descripcionCreador: String,
        lenguajesCreador: [String],
        correoCreador: String,
        yaSolicitado: Bool,
        esCreador: Bool,
        soyParticipante: Bool
    )
}
