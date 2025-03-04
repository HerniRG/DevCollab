import Foundation
import Combine
import FirebaseAuth
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var showSuccessResetAlert: Bool = false
    @Published var user: Usuario? = nil
    
    let authRepository: AuthRepository
    var toastManager: ToastManager

    init(authRepository: AuthRepository, toastManager: ToastManager) {
        self.authRepository = authRepository
        self.toastManager = toastManager
    }
    
    func fetchCurrentUser() async {
        do {
            let usuario = try await authRepository.getCurrentUser()
            DispatchQueue.main.async {
                self.user = usuario
            }
        } catch {
            DispatchQueue.main.async {
                self.toastManager.showToast("❌ Error al obtener el usuario.")
            }
        }
    }
    
    func login() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            DispatchQueue.main.async {
                self.toastManager.showToast("❌ Por favor, introduce tu email y contraseña.")
            }
            return
        }
        
        Task {
            do {
                let usuario = try await authRepository.login(email: trimmedEmail, password: trimmedPassword)
                DispatchQueue.main.async {
                    self.user = usuario
                    self.toastManager.showToast("✅ Login exitoso.")
                }
            } catch {
                DispatchQueue.main.async {
                    self.toastManager.showToast("❌ \(error.localizedDescription)")
                }
            }
        }
    }
    
    func clearFields() {
        email = ""
        password = ""
        isPasswordVisible = false
        showSuccessResetAlert = false
    }
    
    func resetPassword() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try await authRepository.resetPassword(email: trimmedEmail)
            DispatchQueue.main.async {
                self.toastManager.showToast("✅ Correo de recuperación enviado.")
            }
        } catch {
            DispatchQueue.main.async {
                self.toastManager.showToast("❌ Error al enviar el correo de recuperación.")
            }
        }
    }
    
    func resendVerificationEmail() async {
        do {
            try await authRepository.resendVerificationEmail()
            DispatchQueue.main.async {
                self.toastManager.showToast("✅ Correo de verificación reenviado.")
            }
        } catch {
            DispatchQueue.main.async {
                self.toastManager.showToast("❌ Error al reenviar el correo de verificación.")
            }
        }
    }
    
    func logout() async {
            do {
                try await authRepository.logout()
                DispatchQueue.main.async {
                    self.user = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.toastManager.showToast("❌ Error al cerrar sesión.")
                }
            }
        }
}
