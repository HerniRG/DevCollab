import Foundation
import Combine
import FirebaseAuth
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var user: Usuario?
    @Published var isRegistering: Bool = false
    
    private let authRepository: AuthRepository
    var toastManager: ToastManager
    
    init(authRepository: AuthRepository, toastManager: ToastManager = ToastManager()) {
        self.authRepository = authRepository
        self.toastManager = toastManager
        fetchCurrentUser()
    }
    
    func login(email: String, password: String) {
        Task {
            do {
                let usuario = try await authRepository.login(email: email, password: password)
                DispatchQueue.main.async { [weak self] in
                    self?.user = usuario
                    self?.toastManager.showToast("✅ Login exitoso.")
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.toastManager.showToast("❌ \(error.localizedDescription)")
                }
            }
        }
    }
    
    func register(email: String, password: String, nombre: String, lenguajes: [LenguajeProgramacion], descripcion: String?) {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !lenguajes.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                self?.toastManager.showToast("❌ Por favor, completa todos los campos.")
            }
            return
        }
        
        Task {
            do {
                let usuario = try await authRepository.register(email: email, password: password, nombre: nombre, lenguajes: lenguajes, descripcion: descripcion)
                DispatchQueue.main.async { [weak self] in
                    self?.user = usuario
                    self?.toastManager.showToast("✅ Registro exitoso.")
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.toastManager.showToast("❌ \(error.localizedDescription)")
                }
            }
        }
    }
    
    func resendVerificationEmail() {
        Task {
            do {
                try await authRepository.resendVerificationEmail()
                DispatchQueue.main.async { [weak self] in
                    self?.toastManager.showToast("✅ Correo de verificación reenviado.")
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.toastManager.showToast("❌ \(error.localizedDescription)")
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
                    self?.toastManager.showToast("✅ Sesión cerrada.")
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.toastManager.showToast("❌ \(error.localizedDescription)")
                }
            }
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await authRepository.resetPassword(email: email)
            DispatchQueue.main.async { [weak self] in
                self?.toastManager.showToast("✅ Correo de recuperación enviado.")
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.toastManager.showToast("❌ Error al enviar el correo de recuperación.")
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
                    debugPrint("❌ Error al obtener el usuario: \(error.localizedDescription)")
                }
            }
        }
    }
}
