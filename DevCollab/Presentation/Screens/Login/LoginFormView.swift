import SwiftUI

struct LoginFormView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    @Binding var showSuccessResetAlert: Bool
    let viewModel: LoginViewModel

    enum LoginField: Hashable {
        case email, password
    }
    @FocusState private var focusedField: LoginField?

    var body: some View {
        VStack(spacing: 16) {
            // Campo de Correo electrónico
            CustomTextField(
                placeholderKey: "login_email_placeholder",
                text: $email,
                keyboardType: .emailAddress
            )
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .textContentType(.username)
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .password
            }
            .accessibilityLabel(NSLocalizedString("login_email_accessibility", comment: "Etiqueta de accesibilidad para el email"))
            .accessibilityHint(NSLocalizedString("login_email_hint", comment: "Hint de accesibilidad para el email"))
            
            // Campo de Contraseña (con opción de ver u ocultar)
            CustomSecureField(
                placeholder: NSLocalizedString("login_password_placeholder", comment: "Placeholder para contraseña"),
                text: $password,
                isPasswordVisible: $isPasswordVisible
            )
            .textContentType(.password)
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit {
                // Se cierra el teclado al terminar
                focusedField = nil
            }
            .accessibilityLabel(NSLocalizedString("login_password_accessibility", comment: "Accesibilidad para campo de contraseña"))
            .accessibilityHint(NSLocalizedString("login_password_hint", comment: "Hint para contraseña"))

            // Botón para resetear la contraseña
            Button(action: {
                Task {
                    await viewModel.resetPassword()
                    showSuccessResetAlert = true
                }
            }) {
                Text(NSLocalizedString("forgot_password_button", comment: "¿Olvidaste tu contraseña?"))
                    .font(.footnote)
                    .foregroundColor(email.isValidEmail ? .blue : .gray)
                    .padding(.top, -5)
            }
            .disabled(!email.isValidEmail)
            .accessibilityLabel(NSLocalizedString("forgot_password_accessibility", comment: "Accesibilidad: Olvidé mi contraseña"))
            .accessibilityHint(NSLocalizedString("forgot_password_hint", comment: "Envía un correo de restablecimiento si el email es válido"))
            .transition(.opacity)
            
            // Botón para reenviar el correo de verificación
            if email.isValidEmail {
                Button(action: {
                    Task {
                        await viewModel.resendVerificationEmail()
                    }
                }) {
                    Text(NSLocalizedString("resend_verification_button", comment: "Reenviar correo de verificación"))
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .padding(.top, -5)
                }
                .accessibilityLabel(NSLocalizedString("resend_verification_accessibility", comment: "Reenviar correo de verificación"))
                .accessibilityHint(NSLocalizedString("resend_verification_hint", comment: "Solicita que se envíe nuevamente el correo para verificar tu dirección"))
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 30)
        .animation(.easeInOut, value: email.isValidEmail)
    }
}

// Mantén tu extensión para validar emails.
extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
}
