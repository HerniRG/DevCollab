import Foundation
import Combine

class PerfilViewModel: ObservableObject {
    @Published var usuario: Usuario?
    @Published var proyectosCreados: [Proyecto] = []
    @Published var proyectosParticipando: [Proyecto] = []
    private let authRepository: AuthRepository
    private let proyectoRepository: ProyectoRepository
    
    init(authRepository: AuthRepository, proyectoRepository: ProyectoRepository) {
        self.authRepository = authRepository
        self.proyectoRepository = proyectoRepository
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
                    self?.proyectosCreados = proyectos.filter { $0.creadorID == userID }
                    self?.proyectosParticipando = proyectos.filter { $0.creadorID != userID }
                }
            } catch {
                print("Error al obtener proyectos del usuario: \(error.localizedDescription)")
            }
        }
    }
}
