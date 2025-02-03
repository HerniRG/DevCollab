import Foundation
import Combine

class CrearProyectoViewModel: ObservableObject {
    @Published var isSuccess: Bool = false
    private let crearProyectoUseCase: CrearProyectoUseCase
    
    init(crearProyectoUseCase: CrearProyectoUseCase) {
        self.crearProyectoUseCase = crearProyectoUseCase
    }
    
    func crearProyecto(proyecto: Proyecto) {
        Task {
            do {
                try await crearProyectoUseCase.execute(proyecto: proyecto)
                DispatchQueue.main.async { [weak self] in
                    self?.isSuccess = true
                }
            } catch {
                print("Error al crear proyecto: \(error.localizedDescription)")
            }
        }
    }
}
