import Foundation
import Combine

class CrearProyectoViewModel: ObservableObject {
    @Published var isSuccess: Bool = false
    @Published var errorMessage: String? = nil
    private let crearProyectoUseCase: CrearProyectoUseCase
    
    init(crearProyectoUseCase: CrearProyectoUseCase) {
        self.crearProyectoUseCase = crearProyectoUseCase
    }
    
    func crearProyecto(nombre: String,
                       descripcion: String,
                       lenguajes: [LenguajeProgramacion],
                       horasSemanales: String,
                       tipoColaboracion: String,
                       creadorID: String) {
        // Validación de campos obligatorios y que se haya seleccionado al menos un lenguaje
        if nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            descripcion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            horasSemanales.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            tipoColaboracion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            lenguajes.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Faltan campos por rellenar"
                self.isSuccess = false
            }
            return
        }
        
        let proyecto = Proyecto(
            id: UUID().uuidString,
            nombre: nombre,
            descripcion: descripcion,
            lenguajes: lenguajes,
            horasSemanales: Int(horasSemanales) ?? 0,
            tipoColaboracion: tipoColaboracion,
            estado: "Abierto",
            creadorID: creadorID
        )
        
        Task {
            do {
                try await crearProyectoUseCase.execute(proyecto: proyecto)
                DispatchQueue.main.async {
                    self.isSuccess = true
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isSuccess = false
                }
            }
        }
    }
}
