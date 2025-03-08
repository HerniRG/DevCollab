import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

final class PerfilViewModel: ObservableObject {
    @Published var usuario: Usuario?
    @Published var proyectosCreados: [Proyecto] = []
    @Published var proyectosParticipando: [Proyecto] = []
    @Published var solicitudes: [Solicitud] = []
        
    // Dependencias
    private let authRepository: AuthRepository
    private let proyectoRepository: ProyectoRepository
    private let solicitudRepository: SolicitudRepository
    private let updatePerfilUseCase: UpdatePerfilUseCase
    
    private let db = Firestore.firestore()
    
    // ToastManager centralizado
    var toastManager: ToastManager

    init(authRepository: AuthRepository,
         proyectoRepository: ProyectoRepository,
         solicitudRepository: SolicitudRepository,
         updatePerfilUseCase: UpdatePerfilUseCase,
         toastManager: ToastManager = ToastManager()) {
        self.authRepository = authRepository
        self.proyectoRepository = proyectoRepository
        self.solicitudRepository = solicitudRepository
        self.updatePerfilUseCase = updatePerfilUseCase
        self.toastManager = toastManager
        
        fetchUserProfile()
    }
    
    // MARK: - Toast Helpers
    private func showToast(_ message: String) {
        toastManager.showToast(message)
    }
    
    private func showError(_ message: String) {
        // Prefijo de error
        let errorPrefix = NSLocalizedString("perfil_vm_error_prefix", comment: "Prefijo para errores (❌)")
        showToast("\(errorPrefix) \(message)")
    }
    
    private func showSuccess(_ message: String) {
        // Prefijo de éxito
        let successPrefix = NSLocalizedString("perfil_vm_success_prefix", comment: "Prefijo para éxitos (✅)")
        showToast("\(successPrefix) \(message)")
    }
    
    // MARK: - Perfil y Proyectos
    func fetchUserProfile() {
        Task {
            do {
                if let user = try await authRepository.getCurrentUser() {
                    await MainActor.run {
                        self.usuario = user
                    }
                    fetchUserProjects(userID: user.id)
                    fetchSolicitudes(usuarioID: user.id)
                    await fetchParticipandoProjects(userID: user.id)
                }
            } catch {
                debugPrint("Error al obtener perfil: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchUserProjects(userID: String) {
        Task {
            do {
                let proyectos = try await proyectoRepository.obtenerProyectos()
                await MainActor.run {
                    self.proyectosCreados = proyectos.filter { $0.creadorID == userID }
                }
            } catch {
                debugPrint("Error al obtener proyectos: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchSolicitudes(usuarioID: String) {
        Task {
            do {
                let solicitudes = try await solicitudRepository.obtenerSolicitudes(usuarioID: usuarioID)
                await MainActor.run {
                    self.solicitudes = solicitudes
                }
            } catch {
                debugPrint("Error al obtener solicitudes: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchParticipandoProjects(userID: String) async {
        do {
            let snapshot = try await db.collection("participantes")
                .whereField("usuarioID", isEqualTo: userID)
                .getDocuments()

            // 🔥 Ejecutamos consultas en paralelo usando `withThrowingTaskGroup`
            let proyectos = try await withThrowingTaskGroup(of: Proyecto?.self) { group -> [Proyecto] in
                for document in snapshot.documents {
                    let data = document.data()
                    let proyectoID = data["proyectoID"] as? String ?? ""

                    group.addTask {
                        let proyectoDoc = try await self.db.collection("proyectos").document(proyectoID).getDocument()
                        if let projectData = proyectoDoc.data() {
                            return Proyecto(
                                id: proyectoID,
                                nombre: projectData["nombre"] as? String ?? "",
                                descripcion: projectData["descripcion"] as? String ?? "",
                                lenguajes: (projectData["lenguajes"] as? [String])?.compactMap { LenguajeProgramacion(rawValue: $0) } ?? [],
                                horasSemanales: projectData["horasSemanales"] as? Int ?? 0,
                                tipoColaboracion: projectData["tipoColaboracion"] as? String ?? "",
                                estado: projectData["estado"] as? String ?? "Abierto",
                                creadorID: projectData["creadorID"] as? String ?? ""
                            )
                        }
                        return nil
                    }
                }

                var resultados: [Proyecto] = []
                for try await proyecto in group {
                    if let proyecto = proyecto {
                        resultados.append(proyecto)
                    }
                }
                return resultados
            }

            await MainActor.run {
                self.proyectosParticipando = proyectos
            }
        } catch {
            debugPrint("Error al obtener proyectos participando: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Eliminar Proyecto
    func deleteProject(proyecto: Proyecto) {
        Task {
            do {
                let snapshot = try await db.collection("participantes")
                    .whereField("proyectoID", isEqualTo: proyecto.id)
                    .getDocuments()
                let batch = db.batch()
                for document in snapshot.documents {
                    batch.deleteDocument(document.reference)
                }
                try await batch.commit()
                
                try await proyectoRepository.eliminarProyecto(proyectoID: proyecto.id)
                
                await MainActor.run {
                    self.proyectosCreados.removeAll { $0.id == proyecto.id }
                    self.proyectosParticipando.removeAll { $0.id == proyecto.id }
                }
                // Antes: "Proyecto eliminado correctamente."
                let successMsg = NSLocalizedString("perfil_vm_project_deleted", comment: "Proyecto eliminado correctamente.")
                showSuccess(successMsg)
            } catch {
                // Antes: "Error al eliminar proyecto: \(error.localizedDescription)"
                let errorFormat = NSLocalizedString("perfil_vm_project_delete_error_format", comment: "Error al eliminar proyecto con formato: %@")
                let finalErr = String(format: errorFormat, error.localizedDescription)
                showError(finalErr)
            }
        }
    }
    
    // MARK: - Actualizar Perfil
    func updateUserProfile(nombre: String,
                           descripcion: String,
                           lenguajes: [LenguajeProgramacion]) {
        let maxNombreLength = 25
        let maxDescripcionLength = 150
        
        // Validaciones
        let nameEmpty = NSLocalizedString("perfil_vm_name_empty", comment: "El nombre no puede estar vacío.")
        let nameExceeded = String(format: NSLocalizedString("perfil_vm_name_exceeded_format", comment: "El nombre excede los %d caracteres."), maxNombreLength)
        let descEmpty = NSLocalizedString("perfil_vm_description_empty", comment: "La descripción no puede estar vacía.")
        let descExceeded = String(format: NSLocalizedString("perfil_vm_description_exceeded_format", comment: "La descripción excede los %d caracteres."), maxDescripcionLength)
        let noLanguage = NSLocalizedString("perfil_vm_no_language", comment: "Selecciona al menos un lenguaje.")
        let noUserToUpdate = NSLocalizedString("perfil_vm_no_user_to_update", comment: "No hay usuario para actualizar")
        
        if nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showError(nameEmpty)
            return
        }
        if nombre.count > maxNombreLength {
            showError(nameExceeded)
            return
        }
        if descripcion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showError(descEmpty)
            return
        }
        if descripcion.count > maxDescripcionLength {
            showError(descExceeded)
            return
        }
        if lenguajes.isEmpty {
            showError(noLanguage)
            return
        }
        
        guard let userID = usuario?.id else {
            showError(noUserToUpdate)
            return
        }
        
        Task {
            do {
                try await updatePerfilUseCase.execute(
                    userID: userID,
                    nombre: nombre,
                    descripcion: descripcion,
                    lenguajes: lenguajes
                )
                await MainActor.run {
                    self.usuario = Usuario(
                        id: userID,
                        nombre: nombre,
                        lenguajes: lenguajes,
                        descripcion: descripcion.isEmpty ? nil : descripcion,
                        correo: self.usuario?.correo ?? ""
                    )
                }
                // Antes: "Perfil actualizado con éxito."
                let successMsg = NSLocalizedString("perfil_vm_profile_updated", comment: "Perfil actualizado con éxito.")
                showSuccess(successMsg)
            } catch {
                // Antes: "Error al actualizar el perfil: \(error.localizedDescription)"
                let errorFormat = NSLocalizedString("perfil_vm_profile_update_error_format", comment: "Error al actualizar el perfil: %@")
                let finalErr = String(format: errorFormat, error.localizedDescription)
                showError(finalErr)
            }
        }
    }
}
