import FirebaseFirestore

class FirebaseProyectoRepository: ProyectoRepository {
    private let db = Firestore.firestore()
    
    func obtenerProyectos() async throws -> [Proyecto] {
        let snapshot = try await db.collection("proyectos").getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return Proyecto(
                id: doc.documentID,
                nombre: data["nombre"] as? String ?? "",
                descripcion: data["descripcion"] as? String ?? "",
                lenguajes: (data["lenguajes"] as? [String])?.compactMap { LenguajeProgramacion(rawValue: $0) } ?? [],
                horasSemanales: data["horasSemanales"] as? Int ?? 0,
                tipoColaboracion: data["tipoColaboracion"] as? String ?? "",
                estado: data["estado"] as? String ?? "Abierto",
                creadorID: data["creadorID"] as? String ?? ""
            )
        }
    }
    
    func crearProyecto(proyecto: Proyecto) async throws {
        let data: [String: Any] = [
            "nombre": proyecto.nombre,
            "descripcion": proyecto.descripcion,
            "lenguajes": proyecto.lenguajes.map { $0.rawValue },
            "horasSemanales": proyecto.horasSemanales,
            "tipoColaboracion": proyecto.tipoColaboracion,
            "estado": proyecto.estado,
            "creadorID": proyecto.creadorID
        ]
        try await db.collection("proyectos").document(proyecto.id).setData(data)
    }
    
    func actualizarProyecto(proyecto: Proyecto) async throws {
        let data: [String: Any] = [
            "nombre": proyecto.nombre,
            "descripcion": proyecto.descripcion,
            "lenguajes": proyecto.lenguajes.map { $0.rawValue },
            "horasSemanales": proyecto.horasSemanales,
            "tipoColaboracion": proyecto.tipoColaboracion,
            "estado": proyecto.estado
        ]
        try await db.collection("proyectos").document(proyecto.id).updateData(data)
    }
    
    func cerrarProyecto(proyectoID: String) async throws {
        try await db.collection("proyectos").document(proyectoID).updateData(["estado": "Cerrado"])
    }
    
    func eliminarProyecto(proyectoID: String) async throws {
        try await db.collection("proyectos").document(proyectoID).delete()
    }
    
    func obtenerDetallesProyecto(proyectoID: String, userID: String) async throws -> (nombreCreador: String, yaSolicitado: Bool, esCreador: Bool, soyParticipante: Bool) {
        let document = try await db.collection("proyectos").document(proyectoID).getDocument()
        guard let data = document.data() else {
            throw NSError(domain: "FirebaseProyectoRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Proyecto no encontrado"])
        }
        let nombreCreador = data["creadorID"] as? String ?? "Desconocido"
        let yaSolicitado = try await db.collection("solicitudes")
            .whereField("proyectoID", isEqualTo: proyectoID)
            .whereField("usuarioID", isEqualTo: userID)
            .getDocuments()
            .documents.count > 0
        let esCreador = nombreCreador == userID
        let soyParticipante = try await db.collection("participantes")
            .whereField("proyectoID", isEqualTo: proyectoID)
            .whereField("usuarioID", isEqualTo: userID)
            .getDocuments()
            .documents.count > 0
        return (nombreCreador, yaSolicitado, esCreador, soyParticipante)
    }
}
