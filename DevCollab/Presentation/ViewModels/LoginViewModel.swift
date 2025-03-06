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
                // Antes: "❌ Error al obtener el usuario."
                let msg = NSLocalizedString("login_vm_error_fetch_user", comment: "Error al obtener el usuario")
                self.toastManager.showToast(msg)
            }
        }
    }
    
    func login() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            DispatchQueue.main.async {
                // Antes: "❌ Por favor, introduce tu email y contraseña."
                let msg = NSLocalizedString("login_vm_missing_email_password", comment: "Faltan email o contraseña")
                self.toastManager.showToast(msg)
            }
            return
        }
        
        Task {
            do {
                let usuario = try await authRepository.login(email: trimmedEmail, password: trimmedPassword)
                DispatchQueue.main.async {
                    self.user = usuario
                    // Antes: "✅ Login exitoso."
                    let successMsg = NSLocalizedString("login_vm_login_successful", comment: "Login exitoso")
                    self.toastManager.showToast(successMsg)
                }
            } catch {
                DispatchQueue.main.async {
                    let errorMsg = error.localizedDescription
                    // Antes: "❌ \(error.localizedDescription)"
                    self.toastManager.showToast("❌ \(errorMsg)")
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
                // Antes: "✅ Correo de recuperación enviado."
                let msg = NSLocalizedString("login_vm_reset_mail_sent", comment: "Correo de recuperación enviado.")
                self.toastManager.showToast(msg)
            }
        } catch {
            DispatchQueue.main.async {
                // Antes: "❌ Error al enviar el correo de recuperación."
                let errMsg = NSLocalizedString("login_vm_reset_mail_error", comment: "Error al enviar el correo de recuperación.")
                self.toastManager.showToast(errMsg)
            }
        }
    }
    
    func resendVerificationEmail() async {
        do {
            try await authRepository.resendVerificationEmail()
            DispatchQueue.main.async {
                // Antes: "✅ Correo de verificación reenviado."
                let msg = NSLocalizedString("login_vm_verification_resent", comment: "Correo de verificación reenviado.")
                self.toastManager.showToast(msg)
            }
        } catch {
            DispatchQueue.main.async {
                // Antes: "❌ Error al reenviar el correo de verificación."
                let errMsg = NSLocalizedString("login_vm_verification_resent_error", comment: "Error al reenviar el correo de verificación.")
                self.toastManager.showToast(errMsg)
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
                // Antes: "❌ Error al cerrar sesión."
                let errMsg = NSLocalizedString("login_vm_logout_error", comment: "Error al cerrar sesión")
                self.toastManager.showToast(errMsg)
            }
        }
    }
}
