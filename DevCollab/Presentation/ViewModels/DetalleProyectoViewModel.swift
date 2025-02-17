import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class DetalleProyectoViewModel: ObservableObject {
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
    
    // Toast-like short message
    @Published var toastMessage: String? = nil
    
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
    
    // MARK: - Toast Helper
    private func showToast(_ message: String) {
        DispatchQueue.main.async {
            self.toastMessage = message
        }
        // Hide automatically after 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if self.toastMessage == message {
                withAnimation {
                    self.toastMessage = nil
                }
            }
        }
    }
    
    // MARK: - Show Error & Success
    private func showError(_ message: String) {
        // “❌” prefix for errors
        showToast("❌ \(message)")
    }
    
    private func showSuccess(_ message: String) {
        // “✅” prefix for successes
        showToast("✅ \(message)")
    }
    
    // MARK: - Fetch Usuario
    func fetchUsuario(for solicitud: Solicitud) async -> Usuario? {
        do {
            let usuario = try await usuarioRepository.obtenerUsuario(usuarioID: solicitud.usuarioID)
            return usuario
        } catch {
            print("Error al obtener usuario: \(error.localizedDescription)")
            showError("No se pudo obtener al usuario.")
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
            showError("Error al obtener estado de solicitud.")
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
            print("Error al agregar participante: \(error.localizedDescription)")
            showError("No se pudo agregar al participante.")
        }
    }
    
    // MARK: - Obtener Datos Adicionales
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
            print("Error al obtener datos del proyecto: \(error.localizedDescription)")
            showError("Error al cargar el proyecto.")
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
            print("Error al obtener participantes: \(error.localizedDescription)")
            showError("No se pudo obtener la lista de participantes.")
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
            print("Error al obtener solicitudes: \(error.localizedDescription)")
            showError("No se pudieron obtener las solicitudes.")
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
            print("Error al obtener solicitudes por proyecto: \(error.localizedDescription)")
            showError("No se pudieron obtener las solicitudes del proyecto.")
        }
    }
    
    // MARK: - Alternar Estado Proyecto
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
            print("Error al cambiar estado del proyecto: \(error.localizedDescription)")
            showError("No se pudo cambiar el estado del proyecto.")
        }
    }
    
    // MARK: - Solicitar Participación
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
                self?.showSuccess("Solicitud enviada correctamente.")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error al enviar la solicitud: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Actualizar Estado Solicitud
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) async {
        do {
            try await gestionarSolicitudesUseCase.actualizarEstadoSolicitud(solicitudID: solicitudID, estado: estado)
            showSuccess("Solicitud \(estado)")
        } catch {
            print("Error al actualizar estado de solicitud: \(error.localizedDescription)")
            showError("No se pudo actualizar la solicitud a \(estado).")
        }
    }
    
    // MARK: - Abandonar Proyecto
    func abandonarProyecto(proyectoID: String) async {
        do {
            try await gestionarSolicitudesUseCase.abandonarProyecto(proyectoID: proyectoID, usuarioID: userID)
            try await solicitudRepository.eliminarSolicitud(proyectoID: proyectoID, usuarioID: userID)
            DispatchQueue.main.async {
                self.soyParticipante = false
                self.yaSolicitado = false
                self.showSuccess("Has abandonado el proyecto.")
            }
        } catch {
            print("Error al abandonar proyecto: \(error.localizedDescription)")
            showError("No se pudo abandonar el proyecto.")
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
