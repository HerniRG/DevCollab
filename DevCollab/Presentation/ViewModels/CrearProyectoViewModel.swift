import Foundation
import Combine

class CrearProyectoViewModel: ObservableObject {
    @Published var isSuccess: Bool = false
    @Published var errorMessage: String? = nil
    
    private let crearProyectoUseCase: CrearProyectoUseCase
    private let proyectoRepository: ProyectoRepository
    
    init(crearProyectoUseCase: CrearProyectoUseCase,
         proyectoRepository: ProyectoRepository) {
        self.crearProyectoUseCase = crearProyectoUseCase
        self.proyectoRepository = proyectoRepository
    }
    
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
            lenguajes.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Faltan campos por rellenar"
                self.isSuccess = false
            }
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
                    DispatchQueue.main.async {
                        self.errorMessage = "Ya tienes 2 proyectos creados. No puedes crear más."
                        self.isSuccess = false
                    }
                    return
                }
                
                // 4. Crear el proyecto
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
