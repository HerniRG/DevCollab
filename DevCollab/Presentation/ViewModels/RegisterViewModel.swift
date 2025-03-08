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
    @Published var isRegistered: Bool = false

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
        
        // Validar campos obligatorios
        guard !trimmedEmail.isEmpty,
              !trimmedPassword.isEmpty,
              !trimmedNombre.isEmpty,
              !seleccionLenguajes.isEmpty else {
            // Antes: "❌ Por favor, completa todos los campos."
            let missingFields = NSLocalizedString("register_vm_missing_fields", comment: "Faltan campos por rellenar")
            toastManager.showToast("❌ \(missingFields)")
            return
        }
        
        Task {
            do {
                // Realizar registro en el repositorio de autenticación
                _ = try await authRepository.register(
                    email: trimmedEmail,
                    password: trimmedPassword,
                    nombre: trimmedNombre,
                    lenguajes: seleccionLenguajes,
                    descripcion: descripcion
                )
                
                await MainActor.run {
                    let successMessage = NSLocalizedString("register_vm_success", comment: "Registro exitoso, verifica tu correo.")
                    self.toastManager.showToast("✅ \(successMessage)")
                    self.isRegistered = true
                    self.clearFields()
                }
            } catch {
                await MainActor.run {
                    // Antes: "❌ \(error.localizedDescription)"
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
