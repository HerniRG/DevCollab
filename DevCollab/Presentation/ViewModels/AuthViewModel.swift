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
                DispatchQueue.main.async { [weak self] in
                    self?.user = usuario
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func register(email: String, password: String, nombre: String, lenguajes: [LenguajeProgramacion], descripcion: String?) {
        // Validamos que todos los campos requeridos estén completos
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !lenguajes.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "Por favor, completa todos los campos."
            }
            return
        }
        
        Task {
            do {
                let usuario = try await authRepository.register(
                    email: email,
                    password: password,
                    nombre: nombre,
                    lenguajes: lenguajes,
                    descripcion: descripcion
                )
                
                DispatchQueue.main.async { [weak self] in
                    self?.user = usuario
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        Task {
            do {
                try await authRepository.logout()
                DispatchQueue.main.async { [weak self] in
                    self?.user = nil
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await authRepository.resetPassword(email: email)
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = nil // Limpiar errores previos
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "Error al enviar el correo de recuperación."
            }
        }
    }
    
    func fetchCurrentUser() {
        Task {
            do {
                let usuario = try await authRepository.getCurrentUser()
                DispatchQueue.main.async { [weak self] in
                    self?.user = usuario
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
