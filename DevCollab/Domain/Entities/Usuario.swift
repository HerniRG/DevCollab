struct Usuario: Equatable, Hashable {
    let id: String
    let nombre: String
    let lenguajes: [LenguajeProgramacion]
    let descripcion: String?
    let correo: String
}
