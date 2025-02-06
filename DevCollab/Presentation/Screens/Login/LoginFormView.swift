import SwiftUI

// MARK: - Vista de Login
struct LoginFormView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    @Binding var showSuccessResetAlert: Bool
    let viewModel: AuthViewModel
    
    // Enumeración para gestionar el enfoque de los campos en login
    enum LoginField: Hashable {
        case email
        case password
    }
    @FocusState private var focusedField: LoginField?
    
    var body: some View {
        VStack(spacing: 16) {
            CustomTextField(
                placeholder: "Correo electrónico",
                text: $email,
                keyboardType: .emailAddress
            )
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .password
            }
            .accessibilityLabel("Correo electrónico")
            
            CustomSecureField(
                placeholder: "Contraseña",
                text: $password,
                isPasswordVisible: $isPasswordVisible
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit {
                // Se puede optar por cerrar el teclado o ejecutar alguna acción adicional
                focusedField = nil
            }
            .accessibilityLabel("Contraseña")
            
            // Botón para resetear contraseña (solo en login)
            Button(action: {
                Task {
                    do {
                        try await viewModel.resetPassword(email: email)
                        showSuccessResetAlert = true
                    } catch {
                        viewModel.errorMessage = "No se pudo enviar el correo de recuperación."
                    }
                }
            }) {
                Text("¿Olvidaste tu contraseña?")
                    .font(.footnote)
                    .foregroundColor(email.isValidEmail ? .blue : .gray)
                    .padding(.top, -5)
            }
            .disabled(!email.isValidEmail)
            .accessibilityLabel("Restablecer contraseña")
        }
        .padding(.horizontal, 30)
    }
}
