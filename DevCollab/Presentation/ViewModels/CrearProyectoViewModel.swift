import Foundation
import Combine
import FirebaseAuth
import SwiftUI

final class CrearProyectoViewModel: ObservableObject {
    var toastManager: ToastManager
    private let crearProyectoUseCase: CrearProyectoUseCase
    private let proyectoRepository: ProyectoRepository
    
    init(crearProyectoUseCase: CrearProyectoUseCase,
         proyectoRepository: ProyectoRepository,
         toastManager: ToastManager = ToastManager()) {
        self.crearProyectoUseCase = crearProyectoUseCase
        self.proyectoRepository = proyectoRepository
        self.toastManager = toastManager
    }
    
    // MARK: - Crear Proyecto con completion
    func crearProyecto(nombre: String,
                       descripcion: String,
                       lenguajes: [LenguajeProgramacion],
                       horasSemanales: String,
                       tipoColaboracion: String,
                       creadorID: String,
                       completion: @escaping (Bool) -> Void) {
        // Validación de campos obligatorios
        guard !nombre.isEmpty,
              !descripcion.isEmpty,
              !horasSemanales.isEmpty,
              !tipoColaboracion.isEmpty,
              !lenguajes.isEmpty else {
            let missingFieldsMessage = NSLocalizedString("crear_proyecto_vm_missing_fields", comment: "Faltan campos por rellenar")
            toastManager.showToast("❌ \(missingFieldsMessage)")
            completion(false)
            return
        }
        
        // Validación de horas semanales como número válido
        guard let horas = Int(horasSemanales), horas > 0 else {
            let invalidHoursMessage = NSLocalizedString("crear_proyecto_vm_invalid_hours", comment: "Las horas semanales deben ser un número mayor que 0")
            toastManager.showToast("❌ \(invalidHoursMessage)")
            completion(false)
            return
        }
        
        Task {
            do {
                // 1. Obtener todos los proyectos
                let proyectos = try await proyectoRepository.obtenerProyectos()
                
                // 2. Filtrar los proyectos del usuario
                let misProyectos = proyectos.filter { $0.creadorID == creadorID }
                
                // 3. Comprobar cuántos proyectos tiene
                if misProyectos.count >= 2 {
                    let tooManyProjectsMessage = NSLocalizedString("crear_proyecto_vm_too_many_projects", comment: "Ya tienes 2 proyectos creados. No puedes crear más.")
                    toastManager.showToast("❌ \(tooManyProjectsMessage)")
                    completion(false)
                    return
                }
                
                // 4. Crear el objeto proyecto
                let proyecto = Proyecto(
                    id: UUID().uuidString,
                    nombre: nombre,
                    descripcion: descripcion,
                    lenguajes: lenguajes,
                    horasSemanales: horas,
                    tipoColaboracion: tipoColaboracion,
                    estado: "Abierto",
                    creadorID: creadorID
                )
                
                // 5. Guardar el proyecto en Firebase
                try await crearProyectoUseCase.execute(proyecto: proyecto)
                
                // 6. Éxito
                let successMessage = NSLocalizedString("crear_proyecto_vm_project_created", comment: "Proyecto creado exitosamente.")
                toastManager.showToast("✅ \(successMessage)")
                completion(true)
            } catch {
                toastManager.showToast("❌ \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}
