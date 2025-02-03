class ProyectoMapper {
    static func map(document: [String: Any], id: String) -> Proyecto {
        return Proyecto(
            id: id,
            nombre: document["nombre"] as? String ?? "",
            descripcion: document["descripcion"] as? String ?? "",
            lenguajes: (document["lenguajes"] as? [String])?.compactMap { LenguajeProgramacion(rawValue: $0) } ?? [],
            horasSemanales: document["horasSemanales"] as? Int ?? 0,
            tipoColaboracion: document["tipoColaboracion"] as? String ?? "",
            estado: document["estado"] as? String ?? "Abierto",
            creadorID: document["creadorID"] as? String ?? ""
        )
    }
}
