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
    
    // ToastManager: no mantenemos toastMessage local
    var toastManager: ToastManager

    // Dependencias para operaciones
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
        showToast("❌ \(message)")
    }
    
    private func showSuccess(_ message: String) {
        showToast("✅ \(message)")
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
            DispatchQueue.main.async {
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
            showSuccess("Participante agregado correctamente")
        } catch {
            debugPrint("Error al agregar participante: \(error.localizedDescription)")
            showError("No se pudo agregar al participante.")
        }
    }
    
    // MARK: - Obtener Datos Adicionales del Proyecto
    func obtenerDatosAdicionales(proyectoID: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        do {
            let detalles = try await obtenerDetallesProyectoUseCase.ejecutar(proyectoID: proyectoID, userID: userID)
            let estadoActual = try await gestionarSolicitudesUseCase.obtenerEstadoProyecto(proyectoID: proyectoID)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
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
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
            }
            debugPrint("Error al obtener datos del proyecto: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Participantes
    func fetchParticipantes(proyectoID: String) async {
        do {
            let snapshot = try await db.collection("participantes")
                .whereField("proyectoID", isEqualTo: proyectoID)
                .getDocuments()
            var lista: [Usuario] = []
            for document in snapshot.documents {
                let data = document.data()
                let usuarioID = data["usuarioID"] as? String ?? ""
                let userDoc = try await db.collection("usuarios").document(usuarioID).getDocument()
                if let userData = userDoc.data() {
                    let usuario = Usuario(
                        id: usuarioID,
                        nombre: userData["nombre"] as? String ?? "",
                        lenguajes: (userData["lenguajes"] as? [String])?.compactMap { LenguajeProgramacion(rawValue: $0) } ?? [],
                        descripcion: userData["descripcion"] as? String,
                        correo: userData["correo"] as? String ?? ""
                    )
                    lista.append(usuario)
                }
            }
            DispatchQueue.main.async {
                self.participantes = lista
            }
        } catch {
            debugPrint("Error al obtener participantes: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Solicitudes
    func fetchSolicitudes() async {
        do {
            let solicitudes = try await obtenerSolicitudesUseCase.execute(usuarioID: userID)
            DispatchQueue.main.async {
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
            DispatchQueue.main.async {
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
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.estadoProyecto = nuevoEstado
                }
                self.showSuccess("Proyecto cambiado a estado: \(nuevoEstado)")
            }
        } catch {
            debugPrint("Error al cambiar estado del proyecto: \(error.localizedDescription)")
            showError("No se pudo cambiar el estado del proyecto.")
        }
    }
    
    // MARK: - Solicitar Participación
    func solicitarParticipacion(proyectoID: String, mensaje: String) async {
        do {
            try await gestionarSolicitudesUseCase.enviarSolicitud(proyectoID: proyectoID, usuarioID: userID, mensaje: mensaje)
            DispatchQueue.main.async { [weak self] in
                self?.yaSolicitado = true
                self?.showSuccess("✅ Solicitud enviada correctamente.")
            }
        } catch {
            DispatchQueue.main.async {
                self.showError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Actualizar Estado de Solicitud
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async {
        do {
            try await gestionarSolicitudesUseCase.actualizarEstadoSolicitud(solicitudID: solicitudID, estado: estado)
            showSuccess("Solicitud \(estado)")
        } catch {
            debugPrint("Error al actualizar estado de solicitud: \(error.localizedDescription)")
            showError("No se pudo actualizar la solicitud a \(estado).")
        }
    }
    
    // MARK: - Abandonar Proyecto
    func abandonarProyecto(proyectoID: String) async {
        do {
            try await gestionarSolicitudesUseCase.abandonarProyecto(proyectoID: proyectoID, usuarioID: userID)
            DispatchQueue.main.async {
                self.soyParticipante = false
                self.yaSolicitado = false
                self.showSuccess("🚀 Has abandonado el proyecto correctamente.")
            }
        } catch {
            DispatchQueue.main.async {
                self.showError("❌ Error al abandonar el proyecto: \(error.localizedDescription)")
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
            DispatchQueue.main.async {
                self.showSuccess("Proyecto eliminado correctamente")
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error al eliminar proyecto: \(error.localizedDescription)"
            }
        }
    }
}
