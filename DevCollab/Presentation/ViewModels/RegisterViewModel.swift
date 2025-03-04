import Foundation
import Combine
import FirebaseAuth
import SwiftUI

class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var nombre: String = ""
    @Published var descripcion: String = ""
    @Published var seleccionLenguajes: [LenguajeProgramacion] = []
    @Published var isPasswordVisible: Bool = false
    @Published var showSuccessResetAlert: Bool = false

    let authRepository: AuthRepository
    var toastManager: ToastManager

    init(authRepository: AuthRepository, toastManager: ToastManager) {
        self.authRepository = authRepository
        self.toastManager = toastManager
    }

    func register() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNombre = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty,
              !trimmedPassword.isEmpty,
              !trimmedNombre.isEmpty,
              !seleccionLenguajes.isEmpty else {
            toastManager.showToast("❌ Por favor, completa todos los campos.")
            return
        }
        Task {
            do {
                _ = try await authRepository.register(
                    email: trimmedEmail,
                    password: trimmedPassword,
                    nombre: trimmedNombre,
                    lenguajes: seleccionLenguajes,
                    descripcion: descripcion
                )
                DispatchQueue.main.async {
                    self.toastManager.showToast("✅ Registro exitoso. Verifica tu correo para confirmar tu cuenta.")
                    self.clearFields()
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
        nombre = ""
        descripcion = ""
        seleccionLenguajes = []
        isPasswordVisible = false
    }
}
