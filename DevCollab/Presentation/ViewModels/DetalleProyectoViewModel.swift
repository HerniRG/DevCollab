import SwiftUI
import Combine

class DetalleProyectoViewModel: ObservableObject {
    @Published var solicitudesPendientes: [Solicitud] = []
    private let obtenerDetallesProyectoUseCase: ObtenerDetallesProyectoUseCaseProtocol
    private let gestionarSolicitudesUseCase: GestionarSolicitudesUseCaseProtocol
    private let userID: String
    
    init(obtenerDetallesProyectoUseCase: ObtenerDetallesProyectoUseCaseProtocol, gestionarSolicitudesUseCase: GestionarSolicitudesUseCaseProtocol, userID: String) {
        self.obtenerDetallesProyectoUseCase = obtenerDetallesProyectoUseCase
        self.gestionarSolicitudesUseCase = gestionarSolicitudesUseCase
        self.userID = userID
    }
    
    func obtenerDatosAdicionales(proyectoID: String) {
        Task {
            do {
                let detalles = try await obtenerDetallesProyectoUseCase.ejecutar(proyectoID: proyectoID, userID: userID)
                DispatchQueue.main.async {
                    self.handleDetallesProyecto(detalles)
                }
            } catch {
                print("Error al obtener detalles del proyecto: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleDetallesProyecto(_ detalles: (String, Bool, Bool, Bool)) {
        // Lógica para actualizar UI con detalles del proyecto
    }
    
    func toggleEstadoProyecto(proyectoID: String) {
        Task {
            do {
                try await gestionarSolicitudesUseCase.cambiarEstadoProyecto(proyectoID: proyectoID)
            } catch {
                print("Error al cambiar estado del proyecto: \(error.localizedDescription)")
            }
        }
    }
    
    func solicitarParticipacion(proyectoID: String) {
        Task {
            do {
                try await gestionarSolicitudesUseCase.enviarSolicitud(proyectoID: proyectoID, usuarioID: userID)
            } catch {
                print("Error al enviar solicitud: \(error.localizedDescription)")
            }
        }
    }
    
    func actualizarEstadoSolicitud(solicitudID: String, estado: String) {
        Task {
            do {
                try await gestionarSolicitudesUseCase.actualizarEstadoSolicitud(solicitudID: solicitudID, estado: estado)
            } catch {
                print("Error al actualizar estado de solicitud: \(error.localizedDescription)")
            }
        }
    }
    
    func abandonarProyecto(proyectoID: String) {
        Task {
            do {
                try await gestionarSolicitudesUseCase.abandonarProyecto(proyectoID: proyectoID, usuarioID: userID)
            } catch {
                print("Error al abandonar proyecto: \(error.localizedDescription)")
            }
        }
    }
}
