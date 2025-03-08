import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

final class DetalleProyectoViewModel: ObservableObject {
    // Propiedades para mostrar datos
    @Published var nombreCreador: String = ""
    @Published var descripcionCreador: String = ""
    @Published var lenguajesCreador: [String] = []
    @Published var estadoProyecto: String = ""
    @Published var yaSolicitado: Bool = false
    @Published var esMiProyecto: Bool = false
    @Published var soyParticipante: Bool = false
    @Published var solicitudesPendientes: [Solicitud] = []
    @Published var participantes: [Usuario] = []
    
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    
    @Published var estadoSolicitud: String = ""
    @Published var correoCreador: String = ""
    
    // ToastManager
    var toastManager: ToastManager

    // Dependencias
    private let obtenerDetallesProyectoUseCase: ObtenerDetallesProyectoUseCaseProtocol
    private let gestionarSolicitudesUseCase: GestionarSolicitudesUseCaseProtocol
    private let obtenerSolicitudesUseCase: ObtenerSolicitudesUseCase
    private let obtenerSolicitudesPorProyectoUseCase: ObtenerSolicitudesPorProyectoUseCase
    private let proyectoRepository: ProyectoRepository
    private let usuarioRepository: UserRepository
    private let solicitudRepository: SolicitudRepository
    
    private let userID: String
    private let db = Firestore.firestore()
    
    init(userID: String, toastManager: ToastManager = ToastManager()) {
        let proyectoRepo = FirebaseProyectoRepository()
        let solicitudRepo = FirebaseSolicitudRepository()
        
        self.obtenerDetallesProyectoUseCase = ObtenerDetallesProyectoUseCaseImpl(repository: proyectoRepo)
        self.gestionarSolicitudesUseCase = GestionarSolicitudesUseCaseImpl(repository: solicitudRepo)
        self.obtenerSolicitudesUseCase = ObtenerSolicitudesUseCaseImpl(repository: solicitudRepo)
        self.obtenerSolicitudesPorProyectoUseCase = ObtenerSolicitudesPorProyectoUseCaseImpl(repository: solicitudRepo)
        
        self.proyectoRepository = proyectoRepo
        self.usuarioRepository = FirebaseUserRepository()
        self.solicitudRepository = solicitudRepo
        self.userID = userID
        self.toastManager = toastManager
    }
    
    // MARK: - Toast Helpers
    private func showToast(_ message: String) {
        toastManager.showToast(message)
    }
    
    private func showError(_ message: String) {
        // Prefijo de error
        let errorPrefix = NSLocalizedString("detalle_proyecto_error_prefix", comment: "Prefijo para errores: ❌")
        showToast("\(errorPrefix) \(message)")
    }
    
    private func showSuccess(_ message: String) {
        // Prefijo de éxito
        let successPrefix = NSLocalizedString("detalle_proyecto_success_prefix", comment: "Prefijo para éxitos: ✅")
        showToast("\(successPrefix) \(message)")
    }
    
    // MARK: - Fetch Usuario para solicitud
    func fetchUsuario(for solicitud: Solicitud) async -> Usuario? {
        do {
            let usuario = try await usuarioRepository.obtenerUsuario(usuarioID: solicitud.usuarioID)
            return usuario
        } catch {
            debugPrint("Error al obtener usuario: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Obtener Estado de la Solicitud
    func fetchSolicitudEstado(proyectoID: String) async {
        do {
            let snapshot = try await db.collection("solicitudes")
                .whereField("proyectoID", isEqualTo: proyectoID)
                .whereField("usuarioID", isEqualTo: userID)
                .getDocuments()
            
            let estado = snapshot.documents.first?.data()["estado"] as? String ?? ""
            await MainActor.run {
                self.estadoSolicitud = estado
            }
        } catch {
            debugPrint("Error al obtener estado de solicitud: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Agregar Participante
    func agregarParticipante(solicitud: Solicitud) async {
        do {
            let data: [String: Any] = [
                "proyectoID": solicitud.proyectoID,
                "usuarioID": solicitud.usuarioID
            ]
            try await db.collection("participantes").addDocument(data: data)
            
            let msg = NSLocalizedString("detalle_proyecto_participant_added", comment: "Participante agregado correctamente")
            showSuccess(msg)
        } catch {
            debugPrint("Error al agregar participante: \(error.localizedDescription)")
            let errMsg = NSLocalizedString("detalle_proyecto_could_not_add_participant", comment: "No se pudo agregar al participante.")
            showError(errMsg)
        }
    }
    
    // MARK: - Obtener Datos Adicionales del Proyecto
    func obtenerDatosAdicionales(proyectoID: String) async {
        await MainActor.run {
            self.isLoading = true
        }
        do {
            let detalles = try await obtenerDetallesProyectoUseCase.ejecutar(proyectoID: proyectoID, userID: userID)
            let estadoActual = try await gestionarSolicitudesUseCase.obtenerEstadoProyecto(proyectoID: proyectoID)
            await MainActor.run {
                self.nombreCreador = detalles.nombreCreador
                self.descripcionCreador = detalles.descripcionCreador
                self.lenguajesCreador = detalles.lenguajesCreador
                self.correoCreador = detalles.correoCreador
                self.yaSolicitado = detalles.yaSolicitado
                self.esMiProyecto = detalles.esCreador
                self.soyParticipante = detalles.soyParticipante
                self.estadoProyecto = estadoActual
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            debugPrint("Error al obtener datos del proyecto: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Participantes
    // MARK: - Fetch Participantes
    func fetchParticipantes(proyectoID: String) async {
        do {
            let snapshot = try await db.collection("participantes")
                .whereField("proyectoID", isEqualTo: proyectoID)
                .getDocuments()
            
            // Mapeamos todos los documentos y obtenemos los datos concurrentemente
            let usuarios = try await withThrowingTaskGroup(of: Usuario?.self) { group -> [Usuario] in
                for document in snapshot.documents {
                    let data = document.data()
                    let usuarioID = data["usuarioID"] as? String ?? ""
                    
                    group.addTask {
                        let userDoc = try await self.db.collection("usuarios").document(usuarioID).getDocument()
                        if let userData = userDoc.data() {
                            return Usuario(
                                id: usuarioID,
                                nombre: userData["nombre"] as? String ?? "",
                                lenguajes: (userData["lenguajes"] as? [String])?.compactMap { LenguajeProgramacion(rawValue: $0) } ?? [],
                                descripcion: userData["descripcion"] as? String,
                                correo: userData["correo"] as? String ?? ""
                            )
                        }
                        return nil
                    }
                }
                
                var usuarios: [Usuario] = []
                for try await usuario in group {
                    if let usuario = usuario {
                        usuarios.append(usuario)
                    }
                }
                return usuarios
            }
            
            await MainActor.run {
                self.participantes = usuarios
            }
        } catch {
            debugPrint("Error al obtener participantes: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Solicitudes
    func fetchSolicitudes() async {
        do {
            let solicitudes = try await obtenerSolicitudesUseCase.execute(usuarioID: userID)
            await MainActor.run {
                self.solicitudesPendientes = solicitudes
            }
        } catch {
            debugPrint("Error al obtener solicitudes: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Solicitudes por Proyecto
    func fetchSolicitudesPorProyecto(proyectoID: String) async {
        do {
            let solicitudes = try await obtenerSolicitudesPorProyectoUseCase.execute(proyectoID: proyectoID)
            await MainActor.run {
                self.solicitudesPendientes = solicitudes
            }
        } catch {
            debugPrint("Error al obtener solicitudes por proyecto: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Alternar Estado del Proyecto
    func alternarEstadoProyecto(proyectoID: String) async {
        do {
            let estadoActual = try await gestionarSolicitudesUseCase.obtenerEstadoProyecto(proyectoID: proyectoID)
            let nuevoEstado = (estadoActual == "Abierto") ? "Cerrado" : "Abierto"
            try await gestionarSolicitudesUseCase.cambiarEstadoProyecto(proyectoID: proyectoID, nuevoEstado: nuevoEstado)
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.estadoProyecto = nuevoEstado
                }
                // Mensaje de éxito con "Proyecto cambiado a estado: X"
                let msgFormat = NSLocalizedString("detalle_proyecto_state_changed_format", comment: "Proyecto cambiado a estado: %@")
                let finalMsg = String(format: msgFormat, nuevoEstado)
                self.showSuccess(finalMsg)
            }
        } catch {
            debugPrint("Error al cambiar estado del proyecto: \(error.localizedDescription)")
            let errMsg = NSLocalizedString("detalle_proyecto_could_not_change_state", comment: "No se pudo cambiar el estado del proyecto.")
            showError(errMsg)
        }
    }
    
    // MARK: - Solicitar Participación
    func solicitarParticipacion(proyectoID: String, mensaje: String) async {
        do {
            try await gestionarSolicitudesUseCase.enviarSolicitud(proyectoID: proyectoID, usuarioID: userID, mensaje: mensaje)
            
            await MainActor.run {
                self.yaSolicitado = true
                let successMsg = NSLocalizedString("detalle_proyecto_request_sent", comment: "Solicitud enviada correctamente.")
                self.showSuccess(successMsg)
            }
        } catch {
            let err = (error as NSError).localizedDescription
            await MainActor.run {
                self.showError(err)
            }
        }
    }
    
    // MARK: - Actualizar Estado de Solicitud
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async {
        do {
            try await gestionarSolicitudesUseCase.actualizarEstadoSolicitud(solicitudID: solicitudID, estado: estado)
            // "Solicitud <estado>"
            let msg = String(format: NSLocalizedString("detalle_proyecto_request_state_format", comment: "Solicitud %@"), estado)
            showSuccess(msg)
        } catch {
            debugPrint("Error al actualizar estado de solicitud: \(error.localizedDescription)")
            let errMsgFormat = NSLocalizedString("detalle_proyecto_could_not_update_request_format", comment: "No se pudo actualizar la solicitud a %@")
            let finalErr = String(format: errMsgFormat, estado)
            showError(finalErr)
        }
    }
    
    // MARK: - Abandonar Proyecto
    func abandonarProyecto(proyectoID: String) async {
        do {
            try await gestionarSolicitudesUseCase.abandonarProyecto(proyectoID: proyectoID, usuarioID: userID)
            await MainActor.run {
                self.soyParticipante = false
                self.yaSolicitado = false
                let msg = NSLocalizedString("detalle_proyecto_abandon_success", comment: "Has abandonado el proyecto correctamente.")
                self.showSuccess(msg)
            }
        } catch {
            debugPrint("Error al abandonar proyecto: \(error.localizedDescription)")
            let errMsgFormat = NSLocalizedString("detalle_proyecto_abandon_error_format", comment: "Error al abandonar el proyecto: %@")
            let finalErr = String(format: errMsgFormat, error.localizedDescription)
            await MainActor.run {
                self.showError(finalErr)
            }
        }
    }
    
    // MARK: - Eliminar Proyecto
    func eliminarProyecto(proyecto: Proyecto) async {
        do {
            let snapshot = try await db.collection("participantes")
                .whereField("proyectoID", isEqualTo: proyecto.id)
                .getDocuments()
            let batch = db.batch()
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
            try await batch.commit()
            try await proyectoRepository.eliminarProyecto(proyectoID: proyecto.id)
            
            await MainActor.run {
                let successMsg = NSLocalizedString("detalle_proyecto_deleted_success", comment: "Proyecto eliminado correctamente")
                self.showSuccess(successMsg)
                self.errorMessage = nil
            }
        } catch {
            let errMsgFormat = NSLocalizedString("detalle_proyecto_deleted_error_format", comment: "Error al eliminar proyecto: %@")
            let finalErr = String(format: errMsgFormat, error.localizedDescription)
            
            await MainActor.run {
                self.errorMessage = finalErr
            }
        }
    }
}
