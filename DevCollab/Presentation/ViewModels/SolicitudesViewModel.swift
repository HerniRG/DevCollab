import Foundation
import Combine

class SolicitudesViewModel: ObservableObject {
    @Published var solicitudes: [Solicitud] = []
    private let obtenerSolicitudesUseCase: ObtenerSolicitudesUseCase
    var toastManager: ToastManager

    init(obtenerSolicitudesUseCase: ObtenerSolicitudesUseCase, toastManager: ToastManager = ToastManager()) {
        self.obtenerSolicitudesUseCase = obtenerSolicitudesUseCase
        self.toastManager = toastManager
    }
    
    func fetchSolicitudes(usuarioID: String) {
        Task {
            do {
                let solicitudes = try await obtenerSolicitudesUseCase.execute(usuarioID: usuarioID)
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
