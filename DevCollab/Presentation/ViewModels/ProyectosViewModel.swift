import Foundation
import Combine
import FirebaseAuth

class ProyectosViewModel: ObservableObject {
    @Published var proyectos: [Proyecto] = []
    @Published var solicitudes: [Solicitud] = []  // Solicitudes del usuario
    
    private let obtenerProyectosUseCase: ObtenerProyectosUseCase
    private let obtenerSolicitudesUseCase: ObtenerSolicitudesUseCase

    init() {
        let proyectoRepository = FirebaseProyectoRepository()  // Suponiendo que este repositorio implementa el protocolo para proyectos
        self.obtenerProyectosUseCase = ObtenerProyectosUseCaseImpl(repository: proyectoRepository)
        
        let solicitudRepository = FirebaseSolicitudRepository()
        self.obtenerSolicitudesUseCase = ObtenerSolicitudesUseCaseImpl(repository: solicitudRepository)
        
        fetchProyectos()
        fetchSolicitudes()
    }
    
    func fetchProyectos() {
        Task {
            do {
                let proyectos = try await obtenerProyectosUseCase.execute()
                DispatchQueue.main.async { [weak self] in
                    self?.proyectos = proyectos
                }
            } catch {
                print("Error al obtener proyectos: \(error.localizedDescription)")
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
                print("Error al obtener solicitudes: \(error.localizedDescription)")
            }
        }
    }
}
