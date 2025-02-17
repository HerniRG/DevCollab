import Foundation
import Combine

class CrearProyectoViewModel: ObservableObject {
    // Toast-like short-lived message
    @Published var toastMessage: String? = nil
    
    private let crearProyectoUseCase: CrearProyectoUseCase
    private let proyectoRepository: ProyectoRepository
    
    init(crearProyectoUseCase: CrearProyectoUseCase,
         proyectoRepository: ProyectoRepository) {
        self.crearProyectoUseCase = crearProyectoUseCase
        self.proyectoRepository = proyectoRepository
    }
    
    // MARK: - Toast Helpers
    private func showToast(_ message: String) {
        DispatchQueue.main.async {
            self.toastMessage = message
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            // Only clear if it's still the same message
            if self.toastMessage == message {
                self.toastMessage = nil
            }
        }
    }
    
    private func showSuccess(_ message: String) {
        showToast("✅ " + message)
    }
    
    private func showError(_ message: String) {
        showToast("❌ " + message)
    }
    
    // MARK: - Crear Proyecto
    func crearProyecto(nombre: String,
                       descripcion: String,
                       lenguajes: [LenguajeProgramacion],
                       horasSemanales: String,
                       tipoColaboracion: String,
                       creadorID: String) {
        // Validación de campos obligatorios
        if nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           descripcion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           horasSemanales.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           tipoColaboracion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           lenguajes.isEmpty
        {
            showError("Faltan campos por rellenar")
            return
        }
        
        Task {
            do {
                // 1. Obtener todos los proyectos
                let proyectos = try await proyectoRepository.obtenerProyectos()
                
                // 2. Filtrar los que ha creado el usuario actual
                let misProyectos = proyectos.filter { $0.creadorID == creadorID }
                
                // 3. Comprobar cuántos proyectos tiene
                if misProyectos.count >= 2 {
                    // Mostrar error y salir
                    showError("Ya tienes 2 proyectos creados. No puedes crear más.")
                    return
                }
                
                // 4. Crear el objeto proyecto
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
                
                // 5. Llamar al use case
                try await crearProyectoUseCase.execute(proyecto: proyecto)
                
                // 6. Éxito
                showSuccess("Proyecto creado exitosamente.")
            } catch {
                showError(error.localizedDescription)
            }
        }
    }
}
