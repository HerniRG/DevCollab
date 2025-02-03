import FirebaseFirestore

class FirebaseSolicitudRepository: SolicitudRepository {
    private let db = Firestore.firestore()
    
    func enviarSolicitud(solicitud: Solicitud) async throws {
        let data: [String: Any] = [
            "usuarioID": solicitud.usuarioID,
            "proyectoID": solicitud.proyectoID,
            "mensaje": solicitud.mensaje ?? "",
            "estado": "Pendiente"
        ]
        try await db.collection("solicitudes").document(solicitud.id).setData(data)
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
    
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async throws {
        try await db.collection("solicitudes").document(solicitudID).updateData(["estado": estado])
    }
}
