import Foundation
import Combine
import FirebaseAuth

class PerfilViewModel: ObservableObject {
    @Published var usuario: Usuario?
    @Published var proyectosCreados: [Proyecto] = []
    @Published var proyectosParticipando: [Proyecto] = []
    @Published var solicitudes: [Solicitud] = []  // Solicitudes del usuario
    
    private let authRepository: AuthRepository
    private let proyectoRepository: ProyectoRepository
    private let solicitudRepository: SolicitudRepository
    
    init(authRepository: AuthRepository, proyectoRepository: ProyectoRepository, solicitudRepository: SolicitudRepository) {
        self.authRepository = authRepository
        self.proyectoRepository = proyectoRepository
        self.solicitudRepository = solicitudRepository
        fetchUserProfile()
    }
    
    func fetchUserProfile() {
        Task {
            do {
                if let user = try await authRepository.getCurrentUser() {
                    DispatchQueue.main.async { [weak self] in
                        self?.usuario = user
                    }
                    fetchUserProjects(userID: user.id)
                    fetchSolicitudes(usuarioID: user.id)
                }
            } catch {
                print("Error al obtener perfil: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchUserProjects(userID: String) {
        Task {
            do {
                let proyectos = try await proyectoRepository.obtenerProyectos()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.proyectosCreados = proyectos.filter { $0.creadorID == userID }
                    // Se asume que proyectosParticipando se actualiza según las solicitudes
                    self.updateProyectosParticipando(userID: userID, allProjects: proyectos)
                }
            } catch {
                print("Error al obtener proyectos del usuario: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchSolicitudes(usuarioID: String) {
        Task {
            do {
                let solicitudes = try await solicitudRepository.obtenerSolicitudes(usuarioID: usuarioID)
                DispatchQueue.main.async { [weak self] in
                    self?.solicitudes = solicitudes
                    if let userID = self?.usuario?.id {
                        let proyectos = (self?.proyectosCreados ?? []) + (self?.proyectosParticipando ?? [])
                        self?.updateProyectosParticipando(userID: userID, allProjects: proyectos)
                    }
                }
            } catch {
                print("Error al obtener solicitudes: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateProyectosParticipando(userID: String, allProjects: [Proyecto]) {
        let participando = allProjects.filter { proyecto in
            proyecto.creadorID != userID &&
            self.solicitudes.contains { solicitud in
                solicitud.proyectoID == proyecto.id && solicitud.estado == "Aceptada"
            }
        }
        DispatchQueue.main.async {
            self.proyectosParticipando = participando
        }
    }
    
    func deleteProject(proyecto: Proyecto) {
        Task {
            do {
                try await proyectoRepository.eliminarProyecto(proyectoID: proyecto.id)
                DispatchQueue.main.async { [weak self] in
                    self?.proyectosCreados.removeAll { $0.id == proyecto.id }
                    self?.proyectosParticipando.removeAll { $0.id == proyecto.id }
                }
            } catch {
                print("Error al borrar proyecto: \(error.localizedDescription)")
            }
        }
    }
}
