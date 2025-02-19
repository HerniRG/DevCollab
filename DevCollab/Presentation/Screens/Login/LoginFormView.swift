import SwiftUI

struct LoginFormView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    @Binding var showSuccessResetAlert: Bool
    let viewModel: AuthViewModel
    
    // Enumeración para gestionar el foco en los campos
    enum LoginField: Hashable {
        case email, password
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
                // Se cierra el teclado al terminar
                focusedField = nil
            }
            .accessibilityLabel("Contraseña")
            
            // Botón para resetear contraseña
            Button(action: {
                Task {
                    do {
                        try await viewModel.resetPassword(email: email)
                        showSuccessResetAlert = true
                    } catch {
                        // En esta versión, el ViewModel se encarga de mostrar el Toast de error
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
