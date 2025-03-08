struct Solicitud {
    let id: String
    let usuarioID: String
    let proyectoID: String
    let mensaje: String?
    let estado: String // "Pendiente", "Aceptada", "Rechazada", "Abandonado"
}
