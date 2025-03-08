import Foundation
import Combine
import SwiftUI

class AuthContainerViewModel: ObservableObject {
    @Published var isRegistering: Bool = false

    /// Nuevo: aquí guardamos el usuario con `@Published` para que MainView detecte los cambios.
    @Published var user: Usuario? = nil
    
    @Published var loginVM: LoginViewModel
    @Published var registerVM: RegisterViewModel
    
    var toastManager: ToastManager {
        return loginVM.toastManager
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(authRepository: AuthRepository, toastManager: ToastManager) {
        self.loginVM = LoginViewModel(authRepository: authRepository, toastManager: toastManager)
        self.registerVM = RegisterViewModel(authRepository: authRepository, toastManager: toastManager)
        
        // 1) Escuchamos los cambios de loginVM.user
        loginVM.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newUser in
                self?.user = newUser
            }
            .store(in: &cancellables)
        
        // 2) Observamos cambios en isRegistered para cambiar a la vista de Login
        registerVM.$isRegistered
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRegistered in
                if isRegistered {
                    self?.switchToLogin()
                }
            }
            .store(in: &cancellables)
    }
    
    /// Verificar el usuario actual (ej: auto-login si ya estaba logueado)
    func fetchCurrentUser() async {
        await loginVM.fetchCurrentUser()
        // Cuando `loginVM.user` cambie, el sink de arriba asignará a self.user
    }

    func logout() async {
        do {
            try await loginVM.authRepository.logout()
            await MainActor.run {
                self.loginVM.user = nil
                self.isRegistering = false
            }
        } catch {
            await MainActor.run {
                let errorKey = String(
                    format: NSLocalizedString("auth_container_logout_error", comment: "Mensaje de error con descripción: %@"),
                    error.localizedDescription
                )
                self.toastManager.showToast(errorKey)
            }
        }
    }
    
    /// Alterna manualmente entre Login y Registro, limpiando campos
    func toggleRegistering() {
        DispatchQueue.main.async {
            self.toastManager.hideToast()
            self.loginVM.clearFields()
            self.registerVM.clearFields()
            self.isRegistering.toggle()
        }
    }
    
    /// Cambia a la vista de Login (tras registro exitoso)
    func switchToLogin() {
        DispatchQueue.main.async {
            self.toastManager.hideToast()
            self.registerVM.clearFields()
            self.isRegistering = false
            // Evitar que isRegistered quede en true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.registerVM.isRegistered = false
            }
        }
    }
}
