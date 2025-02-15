import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class DetalleProyectoViewModel: ObservableObject {
    @Published var nombreCreador: String = ""
    @Published var descripcionCreador: String = ""
    @Published var lenguajesCreador: [String] = []  // Para mostrar los lenguajes del creador
    @Published var estadoProyecto: String = ""
    @Published var yaSolicitado: Bool = false
    @Published var esMiProyecto: Bool = false
    @Published var soyParticipante: Bool = false
    @Published var solicitudesPendientes: [Solicitud] = []
    @Published var isLoading: Bool = true   // Indicador de carga
    @Published var errorMessage: String? = nil  // Para manejar errores en la vista
    @Published var participantes: [Usuario] = []  // Participantes aprobados
    @Published var estadoSolicitud: String = ""
    @Published var correoCreador: String = ""
    
    private let obtenerDetallesProyectoUseCase: ObtenerDetallesProyectoUseCaseProtocol
    private let gestionarSolicitudesUseCase: GestionarSolicitudesUseCaseProtocol
    private let obtenerSolicitudesUseCase: ObtenerSolicitudesUseCase
    private let obtenerSolicitudesPorProyectoUseCase: ObtenerSolicitudesPorProyectoUseCase
    private let proyectoRepository: ProyectoRepository
    private let usuarioRepository: UserRepository
    private let solicitudRepository: SolicitudRepository
    
    private let userID: String
    private let db = Firestore.firestore()
    
    init(userID: String) {
        let proyectoRepository = FirebaseProyectoRepository()
        let solicitudRepository = FirebaseSolicitudRepository()
        self.obtenerDetallesProyectoUseCase = ObtenerDetallesProyectoUseCaseImpl(repository: proyectoRepository)
        self.gestionarSolicitudesUseCase = GestionarSolicitudesUseCaseImpl(repository: solicitudRepository)
        self.obtenerSolicitudesUseCase = ObtenerSolicitudesUseCaseImpl(repository: solicitudRepository)
        self.obtenerSolicitudesPorProyectoUseCase = ObtenerSolicitudesPorProyectoUseCaseImpl(repository: solicitudRepository)
        self.proyectoRepository = proyectoRepository
        self.usuarioRepository = FirebaseUserRepository()
        self.solicitudRepository = solicitudRepository
        self.userID = userID
    }
    
    // Función para obtener los datos del usuario utilizando el UserRepository
    func fetchUsuario(for solicitud: Solicitud) async -> Usuario? {
        do {
            let usuario = try await usuarioRepository.obtenerUsuario(usuarioID: solicitud.usuarioID)
            return usuario
        } catch {
            print("Error al obtener usuario: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchSolicitudEstado(proyectoID: String) async {
        do {
            let snapshot = try await db.collection("solicitudes")
                .whereField("proyectoID", isEqualTo: proyectoID)
                .whereField("usuarioID", isEqualTo: userID)
                .getDocuments()
            if let doc = snapshot.documents.first {
                let data = doc.data()
                let estado = data["estado"] as? String ?? ""
                DispatchQueue.main.async {
                    self.estadoSolicitud = estado
                }
            } else {
                DispatchQueue.main.async {
                    self.estadoSolicitud = ""
                }
            }
        } catch {
            print("Error al obtener estado de solicitud: \(error.localizedDescription)")
        }
    }
    
    // Función para agregar participante tras aprobar una solicitud
    func agregarParticipante(solicitud: Solicitud) async {
        do {
            let data: [String: Any] = [
                "proyectoID": solicitud.proyectoID,
                "usuarioID": solicitud.usuarioID
            ]
            try await db.collection("participantes").addDocument(data: data)
            print("Participante agregado correctamente")
        } catch {
            print("Error al agregar participante: \(error.localizedDescription)")
        }
    }
    
    func obtenerDatosAdicionales(proyectoID: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        Task {
            do {
                // Ahora el tuple incluye 'correoCreador'
                let detalles = try await obtenerDetallesProyectoUseCase.ejecutar(proyectoID: proyectoID, userID: userID)
                let estadoActual = try await gestionarSolicitudesUseCase.obtenerEstadoProyecto(proyectoID: proyectoID)
                DispatchQueue.main.async { [weak self] in
                    self?.nombreCreador = detalles.nombreCreador
                    self?.descripcionCreador = detalles.descripcionCreador
                    self?.lenguajesCreador = detalles.lenguajesCreador
                    self?.correoCreador = detalles.correoCreador  // Asigna el correo del creador
                    self?.yaSolicitado = detalles.yaSolicitado
                    self?.esMiProyecto = detalles.esCreador
                    self?.soyParticipante = detalles.soyParticipante
                    self?.estadoProyecto = estadoActual
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.isLoading = false
                }
                print("Error al obtener datos del proyecto: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchParticipantes(proyectoID: String) async {
        do {
            let snapshot = try await db.collection("participantes")
                .whereField("proyectoID", isEqualTo: proyectoID)
                .getDocuments()
            var participantes: [Usuario] = []
            for document in snapshot.documents {
                let data = document.data()
                let usuarioID = data["usuarioID"] as? String ?? ""
                let userDoc = try await db.collection("usuarios").document(usuarioID).getDocument()
                if let userData = userDoc.data() {
                    let usuario = Usuario(
                        id: usuarioID,
                        nombre: userData["nombre"] as? String ?? "",
                        lenguajes: (userData["lenguajes"] as? [String])?.compactMap { LenguajeProgramacion(rawValue: $0) } ?? [],
                        descripcion: userData["descripcion"] as? String
                    )
                    participantes.append(usuario)
                }
            }
            DispatchQueue.main.async {
                self.participantes = participantes
            }
        } catch {
            print("Error al obtener participantes: \(error.localizedDescription)")
        }
    }
    
    // Función actual (filtra por usuarioID)
    func fetchSolicitudes() async {
        do {
            let solicitudes = try await obtenerSolicitudesUseCase.execute(usuarioID: userID)
            DispatchQueue.main.async { [weak self] in
                self?.solicitudesPendientes = solicitudes
            }
        } catch {
            print("Error al obtener solicitudes: \(error.localizedDescription)")
        }
    }
    
    // NUEVA FUNCIÓN: Filtra solicitudes por proyectoID
    func fetchSolicitudesPorProyecto(proyectoID: String) async {
        do {
            let solicitudes = try await obtenerSolicitudesPorProyectoUseCase.execute(proyectoID: proyectoID)
            DispatchQueue.main.async { [weak self] in
                self?.solicitudesPendientes = solicitudes
            }
        } catch {
            print("Error al obtener solicitudes por proyecto: \(error.localizedDescription)")
        }
    }
    
    func alternarEstadoProyecto(proyectoID: String) async {
        do {
            let estadoActual = try await gestionarSolicitudesUseCase.obtenerEstadoProyecto(proyectoID: proyectoID)
            let nuevoEstado = (estadoActual == "Abierto") ? "Cerrado" : "Abierto"
            print("Intentando cambiar estado a: \(nuevoEstado)")
            try await gestionarSolicitudesUseCase.cambiarEstadoProyecto(proyectoID: proyectoID, nuevoEstado: nuevoEstado)
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.estadoProyecto = nuevoEstado
                }
            }
            print("Proyecto cambiado a estado: \(nuevoEstado)")
        } catch {
            print("Error al cambiar estado del proyecto: \(error.localizedDescription)")
        }
    }
    
    func solicitarParticipacion(proyectoID: String, mensaje: String) async {
        do {
            let solicitudesUsuario = try await obtenerSolicitudesUseCase.execute(usuarioID: userID)
            let aceptadas = solicitudesUsuario.filter { $0.estado == "Aceptada" }
            if aceptadas.count >= 2 {
                DispatchQueue.main.async {
                    self.errorMessage = "Ya estás aprobado en 2 proyectos. No puedes solicitar más."
                }
                return
            }
            try await gestionarSolicitudesUseCase.enviarSolicitud(proyectoID: proyectoID, usuarioID: userID, mensaje: mensaje)
            DispatchQueue.main.async { [weak self] in
                self?.yaSolicitado = true
                self?.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error al enviar la solicitud: \(error.localizedDescription)"
            }
        }
    }
    
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async {
        do {
            try await gestionarSolicitudesUseCase.actualizarEstadoSolicitud(solicitudID: solicitudID, estado: estado)
        } catch {
            print("Error al actualizar estado de solicitud: \(error.localizedDescription)")
        }
    }
    
    func abandonarProyecto(proyectoID: String) async {
        do {
            // Elimina de la colección "participantes"
            try await gestionarSolicitudesUseCase.abandonarProyecto(proyectoID: proyectoID, usuarioID: userID)
            // Elimina la solicitud correspondiente de la colección "solicitudes"
            try await solicitudRepository.eliminarSolicitud(proyectoID: proyectoID, usuarioID: userID) // O si defines esta función en otro use case/repository, úsalo
            DispatchQueue.main.async {
                self.soyParticipante = false
                self.yaSolicitado = false
            }
        } catch {
            print("Error al abandonar proyecto: \(error.localizedDescription)")
        }
    }
    
    func eliminarProyecto(proyecto: Proyecto) async {
        do {
            // Primero, eliminar todos los participantes asociados al proyecto
            let snapshot = try await db.collection("participantes")
                .whereField("proyectoID", isEqualTo: proyecto.id)
                .getDocuments()
            
            let batch = db.batch()
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
            try await batch.commit()
            
            // Luego, eliminar el proyecto
            try await proyectoRepository.eliminarProyecto(proyectoID: proyecto.id)
            
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error al eliminar proyecto: \(error.localizedDescription)"
            }
        }
    }
}
