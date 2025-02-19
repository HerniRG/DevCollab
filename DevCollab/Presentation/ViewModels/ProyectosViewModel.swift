import Foundation
import Combine
import FirebaseAuth

class ProyectosViewModel: ObservableObject {
    @Published var proyectos: [Proyecto] = []
    @Published var solicitudes: [Solicitud] = []  // Solicitudes del usuario
    @Published var isLoading: Bool = false

    private let obtenerProyectosUseCase: ObtenerProyectosUseCase
    private let obtenerSolicitudesUseCase: ObtenerSolicitudesUseCase
    
    // ToastManager para mostrar mensajes (inyectado)
    var toastManager: ToastManager

    init(toastManager: ToastManager = ToastManager()) {
        let proyectoRepository = FirebaseProyectoRepository()  // Suponiendo que este repositorio implementa el protocolo para proyectos
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
                    debugPrint("❌ Error al obtener proyectos: \(error.localizedDescription)")
                }
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
                    debugPrint("❌ Error al obtener solicitudes: \(error.localizedDescription)")
                }
            }
        }
    }
}
