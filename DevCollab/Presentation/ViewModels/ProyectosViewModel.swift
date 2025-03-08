import Foundation
import Combine
import FirebaseAuth

class ProyectosViewModel: ObservableObject {
    @Published var proyectos: [Proyecto] = []
    @Published var solicitudes: [Solicitud] = []  // Solicitudes del usuario
    @Published var isLoading: Bool = false
    @Published var solicitudesPendientesPorProyecto: [String: [Solicitud]] = [:] // Clave: proyectoID

    private let obtenerProyectosUseCase: ObtenerProyectosUseCase
    private let obtenerSolicitudesUseCase: ObtenerSolicitudesUseCase
    
    // ToastManager (opcional) para mostrar mensajes, inyectado
    var toastManager: ToastManager

    init(toastManager: ToastManager = ToastManager()) {
        let proyectoRepository = FirebaseProyectoRepository()
        self.obtenerProyectosUseCase = ObtenerProyectosUseCaseImpl(repository: proyectoRepository)
        
        let solicitudRepository = FirebaseSolicitudRepository()
        self.obtenerSolicitudesUseCase = ObtenerSolicitudesUseCaseImpl(repository: solicitudRepository)
        
        self.toastManager = toastManager
        
        fetchProyectos()
        fetchSolicitudes()
    }
    
    func fetchProyectos() {
        Task {
            await MainActor.run { self.isLoading = true }
            
            do {
                let proyectos = try await obtenerProyectosUseCase.execute()
                
                await MainActor.run {
                    self.proyectos = proyectos
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    let errorFormat = NSLocalizedString("proyectos_vm_error_fetch_projects_format", comment: "Error al obtener proyectos: %@")
                    let finalError = String(format: errorFormat, error.localizedDescription)
                    debugPrint(finalError)
                    
                    // Si quieres mostrar un Toast en lugar de debugPrint:
                    // self.toastManager.showToast(finalError)
                }
            }
        }
    }
    
    func fetchSolicitudesPendientesParaMisProyectos() {
        Task {
            let misProyectos = self.proyectos.filter { $0.creadorID == Auth.auth().currentUser?.uid }
            
            let solicitudesPendientes = try await withThrowingTaskGroup(of: (String, [Solicitud])?.self) { group -> [String: [Solicitud]] in
                for proyecto in misProyectos {
                    group.addTask {
                        do {
                            let solicitudes = try await ObtenerSolicitudesPorProyectoUseCaseImpl(repository: FirebaseSolicitudRepository())
                                .execute(proyectoID: proyecto.id)
                            return (proyecto.id, solicitudes.filter { $0.estado == "Pendiente" })
                        } catch {
                            let errorFormat = NSLocalizedString("proyectos_vm_error_fetch_solicitudes_project_format", comment: "Error al obtener solicitudes para el proyecto %@: %@")
                            let finalError = String(format: errorFormat, proyecto.id, error.localizedDescription)
                            debugPrint(finalError)
                            return nil
                        }
                    }
                }
                
                var resultado: [String: [Solicitud]] = [:]
                for try await solicitud in group {
                    if let (proyectoID, listaSolicitudes) = solicitud {
                        resultado[proyectoID] = listaSolicitudes
                    }
                }
                return resultado
            }

            await MainActor.run {
                self.solicitudesPendientesPorProyecto = solicitudesPendientes
            }
        }
    }
    
    func fetchSolicitudes() {
        Task {
            do {
                let currentUserID = Auth.auth().currentUser?.uid ?? ""
                let solicitudes = try await obtenerSolicitudesUseCase.execute(usuarioID: currentUserID)
                await MainActor.run {
                    self.solicitudes = solicitudes
                }
            } catch {
                await MainActor.run {
                    let errorFormat = NSLocalizedString("proyectos_vm_error_fetch_solicitudes_format", comment: "Error al obtener solicitudes: %@")
                    let finalError = String(format: errorFormat, error.localizedDescription)
                    debugPrint(finalError)
                }
            }
        }
    }
}
