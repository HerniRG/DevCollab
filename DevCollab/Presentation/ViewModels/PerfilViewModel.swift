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
    
    // MARK: - Toast Helpers (delegados al ToastManager)
    private func showToast(_ message: String) {
        toastManager.showToast(message)
    }
    
    private func showError(_ message: String) {
        showToast("❌ \(message)")
    }
    
    private func showSuccess(_ message: String) {
        showToast("✅ \(message)")
    }
    
    // MARK: - Perfil y Proyectos
    func fetchUserProfile() {
        Task {
            do {
                if let user = try await authRepository.getCurrentUser() {
                    DispatchQueue.main.async {
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
                DispatchQueue.main.async {
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
                DispatchQueue.main.async {
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
            var proyectos: [Proyecto] = []
            for document in snapshot.documents {
                let data = document.data()
                let proyectoID = data["proyectoID"] as? String ?? ""
                let proyectoDoc = try await db.collection("proyectos").document(proyectoID).getDocument()
                if let projectData = proyectoDoc.data() {
                    let proyecto = Proyecto(
                        id: proyectoID,
                        nombre: projectData["nombre"] as? String ?? "",
                        descripcion: projectData["descripcion"] as? String ?? "",
                        lenguajes: (projectData["lenguajes"] as? [String])?.compactMap { LenguajeProgramacion(rawValue: $0) } ?? [],
                        horasSemanales: projectData["horasSemanales"] as? Int ?? 0,
                        tipoColaboracion: projectData["tipoColaboracion"] as? String ?? "",
                        estado: projectData["estado"] as? String ?? "Abierto",
                        creadorID: projectData["creadorID"] as? String ?? ""
                    )
                    proyectos.append(proyecto)
                }
            }
            DispatchQueue.main.async {
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
                
                DispatchQueue.main.async {
                    self.proyectosCreados.removeAll { $0.id == proyecto.id }
                    self.proyectosParticipando.removeAll { $0.id == proyecto.id }
                }
                showSuccess("Proyecto eliminado correctamente.")
            } catch {
                showError("Error al eliminar proyecto: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Actualizar Perfil
    func updateUserProfile(nombre: String,
                           descripcion: String,
                           lenguajes: [LenguajeProgramacion]) {
        let maxNombreLength = 25
        let maxDescripcionLength = 150
        
        if nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showError("El nombre no puede estar vacío.")
            return
        }
        if nombre.count > maxNombreLength {
            showError("El nombre excede los \(maxNombreLength) caracteres.")
            return
        }
        if descripcion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showError("La descripción no puede estar vacía.")
            return
        }
        if descripcion.count > maxDescripcionLength {
            showError("La descripción excede los \(maxDescripcionLength) caracteres.")
            return
        }
        if lenguajes.isEmpty {
            showError("Selecciona al menos un lenguaje.")
            return
        }
        
        guard let userID = usuario?.id else {
            showError("No hay usuario para actualizar")
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
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.usuario = Usuario(
                        id: userID,
                        nombre: nombre,
                        lenguajes: lenguajes,
                        descripcion: descripcion.isEmpty ? nil : descripcion,
                        correo: self.usuario?.correo ?? ""
                    )
                }
                showSuccess("Perfil actualizado con éxito.")
            } catch {
                showError("Error al actualizar el perfil: \(error.localizedDescription)")
            }
        }
    }
}
