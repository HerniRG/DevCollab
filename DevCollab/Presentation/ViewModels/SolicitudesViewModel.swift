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
                await MainActor.run {
                    self.solicitudes = solicitudes
                }
            } catch {
                await MainActor.run {
                    // Antes: "❌ Error al obtener solicitudes: \(error.localizedDescription)"
                    let errorFormat = NSLocalizedString("solicitudes_vm_error_fetch_format", comment: "Error al obtener solicitudes: %@")
                    let finalError = String(format: errorFormat, error.localizedDescription)
                    
                    // Lo imprimimos o usamos un Toast (descomenta si deseas un Toast):
                    debugPrint(finalError)
                    // self?.toastManager.showToast(finalError)
                }
            }
        }
    }
}
