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
            DispatchQueue.main.async { self.isLoading = true }
            do {
                let proyectos = try await obtenerProyectosUseCase.execute()
                DispatchQueue.main.async { [weak self] in
                    self?.proyectos = proyectos
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.isLoading = false
                    let errorFormat = NSLocalizedString("proyectos_vm_error_fetch_projects_format", comment: "Error al obtener proyectos: %@")
                    let finalError = String(format: errorFormat, error.localizedDescription)
                    debugPrint(finalError)
                    
                    // Si quisieras mostrar un Toast en lugar de debugPrint:
                    // self?.toastManager.showToast(finalError)
                }
            }
        }
    }
    
    func fetchSolicitudesPendientesParaMisProyectos() {
        Task {
            let misProyectos = self.proyectos.filter { $0.creadorID == Auth.auth().currentUser?.uid }
            var nuevasSolicitudes: [String: [Solicitud]] = [:]
            for proyecto in misProyectos {
                do {
                    let solicitudes = try await ObtenerSolicitudesPorProyectoUseCaseImpl(repository: FirebaseSolicitudRepository())
                        .execute(proyectoID: proyecto.id)
                    // Solo las pendientes
                    nuevasSolicitudes[proyecto.id] = solicitudes.filter { $0.estado == "Pendiente" }
                } catch {
                    let errorFormat = NSLocalizedString("proyectos_vm_error_fetch_solicitudes_project_format", comment: "Error al obtener solicitudes para el proyecto %@: %@")
                    let finalError = String(format: errorFormat, proyecto.id, error.localizedDescription)
                    debugPrint(finalError)
                    
                    // Si quisieras Toast:
                    // self.toastManager.showToast(finalError)
                }
            }
            DispatchQueue.main.async {
                self.solicitudesPendientesPorProyecto = nuevasSolicitudes
            }
        }
    }
    
    func fetchSolicitudes() {
        Task {
            do {
                let currentUserID = Auth.auth().currentUser?.uid ?? ""
                let solicitudes = try await obtenerSolicitudesUseCase.execute(usuarioID: currentUserID)
                DispatchQueue.main.async { [weak self] in
                    self?.solicitudes = solicitudes
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    let errorFormat = NSLocalizedString("proyectos_vm_error_fetch_solicitudes_format", comment: "Error al obtener solicitudes: %@")
                    let finalError = String(format: errorFormat, error.localizedDescription)
                    debugPrint(finalError)
                }
            }
        }
    }
}
