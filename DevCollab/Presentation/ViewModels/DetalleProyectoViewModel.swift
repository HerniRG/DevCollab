import Foundation
import Combine

class DetalleProyectoViewModel: ObservableObject {
    @Published var nombreCreador: String = ""
    @Published var descripcionCreador: String = ""
    @Published var lenguajesCreador: [String] = []  // O [LenguajeProgramacion], formateados como cadena
    @Published var estadoProyecto: String = ""
    @Published var yaSolicitado: Bool = false
    @Published var esMiProyecto: Bool = false
    @Published var soyParticipante: Bool = false
    @Published var solicitudesPendientes: [Solicitud] = []
    @Published var isLoading: Bool = true   // Indicador de carga
    
    private let obtenerDetallesProyectoUseCase: ObtenerDetallesProyectoUseCaseProtocol
    private let gestionarSolicitudesUseCase: GestionarSolicitudesUseCaseProtocol
    private let obtenerSolicitudesUseCase: ObtenerSolicitudesUseCase
    private let userID: String
    
    init(userID: String) {
        let proyectoRepository = FirebaseProyectoRepository()
        let solicitudRepository = FirebaseSolicitudRepository()
        
        self.obtenerDetallesProyectoUseCase = ObtenerDetallesProyectoUseCaseImpl(repository: proyectoRepository)
        self.gestionarSolicitudesUseCase = GestionarSolicitudesUseCaseImpl(repository: solicitudRepository)
        self.obtenerSolicitudesUseCase = ObtenerSolicitudesUseCaseImpl(repository: solicitudRepository)
        self.userID = userID
    }
    
    func obtenerDatosAdicionales(proyectoID: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        Task {
            do {
                // Suponemos que el use case se ha extendido para devolver también información del creador:
                // (nombreCreador, descripcionCreador, lenguajesCreador, yaSolicitado, esMiProyecto, soyParticipante)
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
    /// 🔥 Obtiene las solicitudes pendientes del proyecto
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

    /// 🔥 Alterna el estado del proyecto entre "Abierto" y "Cerrado"
    func alternarEstadoProyecto(proyectoID: String) async {
        do {
            // 1️⃣ Obtener el estado actual del proyecto
            let estadoActual = try await gestionarSolicitudesUseCase.obtenerEstadoProyecto(proyectoID: proyectoID)
            let nuevoEstado = (estadoActual == "Abierto") ? "Cerrado" : "Abierto"

            print("🔥 Intentando cambiar estado a: \(nuevoEstado)")

            // 2️⃣ Cambiar el estado en Firestore
            try await gestionarSolicitudesUseCase.cambiarEstadoProyecto(proyectoID: proyectoID, nuevoEstado: nuevoEstado)

            // 3️⃣ Actualizar estado en la UI
            DispatchQueue.main.async {
                self.estadoProyecto = nuevoEstado
            }

            print("✅ Proyecto cambiado a estado: \(nuevoEstado)")

        } catch {
            print("❌ Error al cambiar estado del proyecto: \(error.localizedDescription)")
        }
    }
    
    func solicitarParticipacion(proyectoID: String) async {
        do {
            try await gestionarSolicitudesUseCase.enviarSolicitud(proyectoID: proyectoID, usuarioID: userID)
        } catch {
            print("❌ Error al enviar solicitud: \(error.localizedDescription)")
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
}
