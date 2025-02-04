import FirebaseFirestore

class FirebaseSolicitudRepository: SolicitudRepository {
    
    private let db = Firestore.firestore()
    
    func enviarSolicitud(proyectoID: String, usuarioID: String) async throws {
        let data: [String: Any] = [
            "usuarioID": usuarioID,
            "proyectoID": proyectoID,
            "estado": "Pendiente"
        ]
        try await db.collection("solicitudes").addDocument(data: data)
    }
    
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async throws {
        try await db.collection("solicitudes").document(solicitudID).updateData(["estado": estado])
    }
    
    func cambiarEstadoProyecto(proyectoID: String) async throws {
        try await db.collection("proyectos").document(proyectoID).updateData(["estado": "Cerrado"])
    }
    
    func abandonarProyecto(proyectoID: String, usuarioID: String) async throws {
        let snapshot = try await db.collection("participantes")
            .whereField("proyectoID", isEqualTo: proyectoID)
            .whereField("usuarioID", isEqualTo: usuarioID)
            .getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    func obtenerSolicitudes(proyectoID: String) async throws -> [Solicitud] {
        let snapshot = try await db.collection("solicitudes").whereField("proyectoID", isEqualTo: proyectoID).getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return Solicitud(
                id: doc.documentID,
                usuarioID: data["usuarioID"] as? String ?? "",
                proyectoID: data["proyectoID"] as? String ?? "",
                mensaje: data["mensaje"] as? String,
                estado: data["estado"] as? String ?? "Pendiente"
            )
        }
    }
}
