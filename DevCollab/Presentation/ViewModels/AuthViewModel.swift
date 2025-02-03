import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: Usuario?
    @Published var errorMessage: String?
    @Published var isRegistering: Bool = false
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
        fetchCurrentUser()
    }
    
    func login(email: String, password: String) {
        Task {
            do {
                let usuario = try await authRepository.login(email: email, password: password)
                DispatchQueue.main.async {
                    self.user = usuario
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func register(email: String, password: String, nombre: String, lenguajes: [LenguajeProgramacion], disponibilidad: String, descripcion: String?) {
        Task {
            do {
                let usuario = try await authRepository.register(
                    email: email,
                    password: password,
                    nombre: nombre,
                    lenguajes: lenguajes,
                    disponibilidad: disponibilidad,
                    descripcion: descripcion
                )
                
                DispatchQueue.main.async {
                    self.user = usuario
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        Task {
            do {
                try await authRepository.logout()
                DispatchQueue.main.async {
                    self.user = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchCurrentUser() {
        Task {
            do {
                let usuario = try await authRepository.getCurrentUser()
                DispatchQueue.main.async {
                    self.user = usuario
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
