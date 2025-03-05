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
    
    func obtenerDetallesProyecto(proyectoID: String, userID: String) async throws -> (nombreCreador: String, descripcionCreador: String, lenguajesCreador: [String], correoCreador: String, yaSolicitado: Bool, esCreador: Bool, soyParticipante: Bool) {
        // Obtener el documento del proyecto
        let proyectoDoc = try await db.collection("proyectos").document(proyectoID).getDocument()
        guard let data = proyectoDoc.data() else {
            throw NSError(domain: "FirebaseProyectoRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("project_not_found", comment: "Error cuando el proyecto no existe")])
        }
        
        // Extraer el creadorID
        let creadorID = data["creadorID"] as? String ?? ""
        
        // Consultar la colección "usuarios" para obtener la información del creador
        let usuarioDoc = try await db.collection("usuarios").document(creadorID).getDocument()
        let userData = usuarioDoc.data() ?? [:]
        let nombreCreador = userData["nombre"] as? String ?? NSLocalizedString("unknown_creator", comment: "Texto para cuando no se encuentra el nombre del creador")
        let descripcionCreador = userData["descripcion"] as? String ?? ""
        let lenguajesCreador = userData["lenguajes"] as? [String] ?? []
        let correoCreador = userData["correo"] as? String ?? ""  // Obtenemos el correo
        
        // Consultar solicitudes para determinar yaSolicitado
        let solicitudesSnapshot = try await db.collection("solicitudes")
            .whereField("proyectoID", isEqualTo: proyectoID)
            .whereField("usuarioID", isEqualTo: userID)
            .getDocuments()
        let yaSolicitado = solicitudesSnapshot.documents.count > 0
        
        // Determinar si el usuario es el creador
        let esCreador = (creadorID == userID)
        
        // Consultar participantes para determinar si el usuario es participante
        let participantesSnapshot = try await db.collection("participantes")
            .whereField("proyectoID", isEqualTo: proyectoID)
            .whereField("usuarioID", isEqualTo: userID)
            .getDocuments()
        let soyParticipante = participantesSnapshot.documents.count > 0
        
        return (nombreCreador, descripcionCreador, lenguajesCreador, correoCreador, yaSolicitado, esCreador, soyParticipante)
    }
}
