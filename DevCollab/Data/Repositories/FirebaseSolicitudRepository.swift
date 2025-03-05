import FirebaseFirestore

class FirebaseSolicitudRepository: SolicitudRepository {
    
    private let db = Firestore.firestore()
    
    func enviarSolicitud(proyectoID: String, usuarioID: String, mensaje: String) async throws {
        // 🔍 Verificar si el usuario ya abandonó este proyecto
        let snapshot = try await db.collection("solicitudes")
            .whereField("proyectoID", isEqualTo: proyectoID)
            .whereField("usuarioID", isEqualTo: usuarioID)
            .whereField("abandonado", isEqualTo: true)
            .getDocuments()

        if !snapshot.documents.isEmpty {
            throw NSError(domain: "SolicitudError", code: 403, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("request_already_abandoned", comment: "El usuario ya abandonó este proyecto.")
            ])
        }

        // 🔍 Verificar que el usuario no tenga más de 2 solicitudes aceptadas
        let solicitudesUsuario = try await obtenerSolicitudes(usuarioID: usuarioID)
        let aceptadas = solicitudesUsuario.filter { $0.estado == "Aceptada" }

        if aceptadas.count >= 2 {
            throw NSError(domain: "SolicitudError", code: 403, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("max_approved_requests", comment: "El usuario ya está en 2 proyectos.")
            ])
        }

        // ✅ Si pasa las validaciones, permitir la solicitud
        let data: [String: Any] = [
            "usuarioID": usuarioID,
            "proyectoID": proyectoID,
            "estado": "Pendiente",
            "mensaje": mensaje,
            "abandonado": false  // Asegurar que se guarda correctamente
        ]
        try await db.collection("solicitudes").addDocument(data: data)
    }
    
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async throws {
        try await db.collection("solicitudes").document(solicitudID).updateData(["estado": estado])
    }
    
    func cambiarEstadoProyecto(proyectoID: String, nuevoEstado: String) async throws {
        try await db.collection("proyectos").document(proyectoID).updateData(["estado": nuevoEstado])
        debugPrint("🔥 Estado cambiado en Firestore a: \(nuevoEstado)")
    }
    
    func abandonarProyecto(proyectoID: String, usuarioID: String) async throws {
        let snapshot = try await db.collection("solicitudes")
            .whereField("proyectoID", isEqualTo: proyectoID)
            .whereField("usuarioID", isEqualTo: usuarioID)
            .getDocuments()

        for document in snapshot.documents {
            try await document.reference.updateData(["abandonado": true])
        }

        // 🚀 Eliminar al usuario de la colección de participantes
        let participantesSnapshot = try await db.collection("participantes")
            .whereField("proyectoID", isEqualTo: proyectoID)
            .whereField("usuarioID", isEqualTo: usuarioID)
            .getDocuments()

        for document in participantesSnapshot.documents {
            try await document.reference.delete()
        }

        // 🗑 Eliminar la solicitud si todavía estaba pendiente
        try await eliminarSolicitud(proyectoID: proyectoID, usuarioID: usuarioID)
    }
    
    func obtenerSolicitudes(usuarioID: String) async throws -> [Solicitud] {
        let snapshot = try await db.collection("solicitudes")
            .whereField("usuarioID", isEqualTo: usuarioID)
            .getDocuments()
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
    
    func obtenerSolicitudesPorProyecto(proyectoID: String) async throws -> [Solicitud] {
        let snapshot = try await db.collection("solicitudes")
            .whereField("proyectoID", isEqualTo: proyectoID)
            .whereField("estado", isEqualTo: "Pendiente") // Filtra solo las solicitudes pendientes
            .getDocuments()
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
    func eliminarSolicitud(proyectoID: String, usuarioID: String) async throws {
        let snapshot = try await db.collection("solicitudes")
            .whereField("proyectoID", isEqualTo: proyectoID)
            .whereField("usuarioID", isEqualTo: usuarioID)
            .getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    func obtenerEstadoProyecto(proyectoID: String) async throws -> String {
        let docRef = db.collection("proyectos").document(proyectoID)
        
        // 🔥 Obtiene el estado actual
        let snapshot = try await docRef.getDocument()
        guard let currentEstado = snapshot.data()?["estado"] as? String else {
            throw NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("state_not_found", comment: "El estado del proyecto no fue encontrado.")])
        }
        
        return currentEstado // ✅ Solo devuelve el estado, no lo cambia
    }
}
