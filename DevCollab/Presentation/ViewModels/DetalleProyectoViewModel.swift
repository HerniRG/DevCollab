import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class DetalleProyectoViewModel: ObservableObject {
    @Published var nombreCreador: String = ""
    @Published var descripcionCreador: String = ""
    @Published var lenguajesCreador: [String] = []  // Cadena para mostrar los lenguajes del creador
    @Published var estadoProyecto: String = ""
    @Published var yaSolicitado: Bool = false
    @Published var esMiProyecto: Bool = false
    @Published var soyParticipante: Bool = false
    @Published var solicitudesPendientes: [Solicitud] = []
    @Published var isLoading: Bool = true   // Indicador de carga
    @Published var errorMessage: String? = nil  // Para manejar errores en la vista
    
    // Nueva propiedad para participantes aprobados
    @Published var participantes: [Usuario] = []
    
    private let obtenerDetallesProyectoUseCase: ObtenerDetallesProyectoUseCaseProtocol
    private let gestionarSolicitudesUseCase: GestionarSolicitudesUseCaseProtocol
    private let obtenerSolicitudesUseCase: ObtenerSolicitudesUseCase
    private let proyectoRepository: ProyectoRepository
    private let userID: String
    private let db = Firestore.firestore()  // Para consultas directas si es necesario
    
    init(userID: String) {
        let proyectoRepository = FirebaseProyectoRepository()
        let solicitudRepository = FirebaseSolicitudRepository()
        
        self.obtenerDetallesProyectoUseCase = ObtenerDetallesProyectoUseCaseImpl(repository: proyectoRepository)
        self.gestionarSolicitudesUseCase = GestionarSolicitudesUseCaseImpl(repository: solicitudRepository)
        self.obtenerSolicitudesUseCase = ObtenerSolicitudesUseCaseImpl(repository: solicitudRepository)
        self.proyectoRepository = proyectoRepository
        self.userID = userID
    }
    
    func obtenerDatosAdicionales(proyectoID: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        Task {
            do {
                // Se espera que el use case retorne: (nombreCreador, descripcionCreador, lenguajesCreador, yaSolicitado, esMiProyecto, soyParticipante)
                let detalles = try await obtenerDetallesProyectoUseCase.ejecutar(proyectoID: proyectoID, userID: userID)
                let estadoActual = try await gestionarSolicitudesUseCase.obtenerEstadoProyecto(proyectoID: proyectoID)
                DispatchQueue.main.async { [weak self] in
                    self?.nombreCreador = detalles.0
                    self?.descripcionCreador = detalles.1
                    self?.lenguajesCreador = detalles.2
                    self?.yaSolicitado = detalles.3
                    self?.esMiProyecto = detalles.4
                    self?.soyParticipante = detalles.5
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
    
    /// Nueva función para obtener participantes aprobados en el proyecto.
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
    
    /// Resto de funciones existentes (fetchSolicitudes, alternarEstadoProyecto, solicitarParticipacion, actualizarEstadoSolicitud, abandonarProyecto, eliminarProyecto) se mantienen igual.
    
    func fetchSolicitudes() async {
        do {
            let solicitudes = try await obtenerSolicitudesUseCase.execute(usuarioID: userID)
            DispatchQueue.main.async { [weak self] in
                self?.solicitudesPendientes = solicitudes
            }
        } catch {
            print("❌ Error al obtener solicitudes: \(error.localizedDescription)")
        }
    }
    
    func alternarEstadoProyecto(proyectoID: String) async {
        do {
            let estadoActual = try await gestionarSolicitudesUseCase.obtenerEstadoProyecto(proyectoID: proyectoID)
            let nuevoEstado = (estadoActual == "Abierto") ? "Cerrado" : "Abierto"
            print("🔥 Intentando cambiar estado a: \(nuevoEstado)")
            try await gestionarSolicitudesUseCase.cambiarEstadoProyecto(proyectoID: proyectoID, nuevoEstado: nuevoEstado)
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.estadoProyecto = nuevoEstado
                }
            }
            print("✅ Proyecto cambiado a estado: \(nuevoEstado)")
        } catch {
            print("❌ Error al cambiar estado del proyecto: \(error.localizedDescription)")
        }
    }
    
    func solicitarParticipacion(proyectoID: String) async {
        do {
            let solicitudesUsuario = try await obtenerSolicitudesUseCase.execute(usuarioID: userID)
            let aceptadas = solicitudesUsuario.filter { $0.estado == "Aceptada" }
            if aceptadas.count >= 2 {
                DispatchQueue.main.async {
                    self.errorMessage = "Ya estás aprobado en 2 proyectos. No puedes solicitar más."
                }
                return
            }
            try await gestionarSolicitudesUseCase.enviarSolicitud(proyectoID: proyectoID, usuarioID: userID)
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
            print("❌ Error al actualizar estado de solicitud: \(error.localizedDescription)")
        }
    }
    
    func abandonarProyecto(proyectoID: String) async {
        do {
            try await gestionarSolicitudesUseCase.abandonarProyecto(proyectoID: proyectoID, usuarioID: userID)
        } catch {
            print("❌ Error al abandonar proyecto: \(error.localizedDescription)")
        }
    }
    
    func eliminarProyecto(proyecto: Proyecto) async {
        do {
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
