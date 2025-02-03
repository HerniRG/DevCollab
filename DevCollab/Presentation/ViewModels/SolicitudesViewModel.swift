import Foundation
import Combine

class SolicitudesViewModel: ObservableObject {
    @Published var solicitudes: [Solicitud] = []
    private let obtenerSolicitudesUseCase: ObtenerSolicitudesUseCase
    
    init(obtenerSolicitudesUseCase: ObtenerSolicitudesUseCase) {
        self.obtenerSolicitudesUseCase = obtenerSolicitudesUseCase
    }
    
    func fetchSolicitudes(proyectoID: String) {
        Task {
            do {
                let solicitudes = try await obtenerSolicitudesUseCase.execute(proyectoID: proyectoID)
                DispatchQueue.main.async { [weak self] in
                    self?.solicitudes = solicitudes
                }
            } catch {
                print("Error al obtener solicitudes: \(error.localizedDescription)")
            }
        }
    }
}
