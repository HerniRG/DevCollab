import Foundation
import Combine

class DetalleProyectoViewModel: ObservableObject {
    @Published var nombreCreador: String = ""
    @Published var yaSolicitado: Bool = false
    @Published var esMiProyecto: Bool = false
    @Published var soyParticipante: Bool = false
    @Published var solicitudesPendientes: [Solicitud] = []
    
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
    
    func obtenerDatosAdicionales(proyectoID: String) {
        Task {
            do {
                let detalles = try await obtenerDetallesProyectoUseCase.ejecutar(proyectoID: proyectoID, userID: userID)
                DispatchQueue.main.async {
                    self.nombreCreador = detalles.0
                    self.yaSolicitado = detalles.1
                    self.esMiProyecto = detalles.2
                    self.soyParticipante = detalles.3
                }
                if self.esMiProyecto {
                    await self.fetchSolicitudes(proyectoID: proyectoID)
                }
            } catch {
                print("Error al obtener detalles del proyecto: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchSolicitudes(proyectoID: String) async {
        do {
            let solicitudes = try await obtenerSolicitudesUseCase.execute(proyectoID: proyectoID)
            DispatchQueue.main.async {
                self.solicitudesPendientes = solicitudes
            }
        } catch {
            print("Error al obtener solicitudes: \(error.localizedDescription)")
        }
    }

    func toggleEstadoProyecto(proyectoID: String) async {
        do {
            try await gestionarSolicitudesUseCase.cambiarEstadoProyecto(proyectoID: proyectoID)
        } catch {
            print("Error al cambiar estado del proyecto: \(error.localizedDescription)")
        }
    }
    
    func solicitarParticipacion(proyectoID: String) async {
        do {
            try await gestionarSolicitudesUseCase.enviarSolicitud(proyectoID: proyectoID, usuarioID: userID)
        } catch {
            print("Error al enviar solicitud: \(error.localizedDescription)")
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
            try await gestionarSolicitudesUseCase.abandonarProyecto(proyectoID: proyectoID, usuarioID: userID)
        } catch {
            print("Error al abandonar proyecto: \(error.localizedDescription)")
        }
    }
}
