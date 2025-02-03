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
                lenguajes: data["lenguajes"] as? [LenguajeProgramacion] ?? [],
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
            "lenguajes": proyecto.lenguajes,
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
            "lenguajes": proyecto.lenguajes,
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
}
