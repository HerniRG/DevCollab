import Foundation
import Combine

class ProyectosViewModel: ObservableObject {
    @Published var proyectos: [Proyecto] = []
    private let obtenerProyectosUseCase: ObtenerProyectosUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(obtenerProyectosUseCase: ObtenerProyectosUseCase) {
        self.obtenerProyectosUseCase = obtenerProyectosUseCase
        fetchProyectos()
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
}
