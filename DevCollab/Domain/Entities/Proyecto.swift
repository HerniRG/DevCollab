struct Proyecto {
    let id: String
    let nombre: String
    let descripcion: String
    let lenguajes: [LenguajeProgramacion]
    let horasSemanales: Int
    let tipoColaboracion: String
    let estado: String // "Abierto" o "Cerrado"
    let creadorID: String
}
