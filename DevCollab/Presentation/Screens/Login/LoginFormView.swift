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
            // Campo de Correo electrónico
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
            .accessibilityHint("Introduce tu correo para iniciar sesión")
            
            // Campo de Contraseña (con opción de ver u ocultar)
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
            .accessibilityHint("Introduce tu contraseña de acceso")
            
            // Botón para resetear la contraseña
            Button(action: {
                Task {
                    do {
                        try await viewModel.resetPassword(email: email)
                        showSuccessResetAlert = true
                    } catch {
                        // El ViewModel se encarga de mostrar el Toast de error
                    }
                }
            }) {
                Text("¿Olvidaste tu contraseña?")
                    .font(.footnote)
                    .foregroundColor(email.isValidEmail ? .blue : .gray)
                    .padding(.top, -5)
            }
            .disabled(!email.isValidEmail)
            .accessibilityLabel("Olvidé mi contraseña")
            .accessibilityHint("Envía un correo de restablecimiento si el email es válido")
            .transition(.opacity)
            
            // Botón para reenviar el correo de verificación
            if email.isValidEmail {
                Button(action: {
                    Task {
                        do {
                            try await viewModel.resendVerificationEmail()
                        } catch {
                            // Manejar el error (por ejemplo, mostrar un Toast)
                        }
                    }
                }) {
                    Text("Reenviar correo de verificación")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .padding(.top, -5)
                }
                .accessibilityLabel("Reenviar correo de verificación")
                .accessibilityHint("Solicita que se envíe nuevamente el correo para verificar tu dirección")
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 30)
        .animation(.easeInOut, value: email.isValidEmail)
    }
}
