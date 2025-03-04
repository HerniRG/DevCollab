import Foundation
import Combine
import SwiftUI

class AuthContainerViewModel: ObservableObject {
    @Published var isRegistering: Bool = false
    @Published var loginVM: LoginViewModel
    @Published var registerVM: RegisterViewModel

    var user: Usuario? {
        loginVM.user
    }

    var toastManager: ToastManager {
        return loginVM.toastManager
    }

    init(authRepository: AuthRepository, toastManager: ToastManager) {
        self.loginVM = LoginViewModel(authRepository: authRepository, toastManager: toastManager)
        self.registerVM = RegisterViewModel(authRepository: authRepository, toastManager: toastManager)
    }

    func fetchCurrentUser() async {
        await loginVM.fetchCurrentUser()
    }

    func logout() async {
        do {
            try await loginVM.authRepository.logout()
            DispatchQueue.main.async {
                self.loginVM.user = nil
                self.isRegistering = false
            }
        } catch {
            DispatchQueue.main.async {
                self.toastManager.showToast("❌ Error al cerrar sesión: \(error.localizedDescription)")
            }
        }
    }

    /// **🔥 Nueva función para cambiar entre Login y Registro limpiando los Toasts**
    func toggleRegistering() {
        DispatchQueue.main.async {
            self.toastManager.hideToast() // Ocultar TOAST antes de cambiar
            self.loginVM.clearFields()
            self.registerVM.clearFields()
            self.isRegistering.toggle()
        }
    }
}
