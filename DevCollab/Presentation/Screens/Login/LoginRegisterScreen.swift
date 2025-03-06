import SwiftUI
import FirebaseAuth

struct LoginRegisterScreen: View {
    @State private var isRegistering = false
    @StateObject var loginViewModel = ViewModelProvider.shared.loginVM
    @StateObject var registerViewModel = ViewModelProvider.shared.registerVM

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Cabecera dinámica
            AuthHeaderView(isRegistering: isRegistering)

            if isRegistering {
                // Vista de Registro
                RegisterView(
                    email: $registerViewModel.email,
                    password: $registerViewModel.password,
                    nombre: $registerViewModel.nombre,
                    descripcion: $registerViewModel.descripcion,
                    seleccionLenguajes: $registerViewModel.seleccionLenguajes,
                    isPasswordVisible: $registerViewModel.isPasswordVisible,
                    showSuccessResetAlert: $registerViewModel.showSuccessResetAlert,
                    viewModel: registerViewModel
                )

                // Botón de registro
                Button(action: {
                    withAnimation {
                        registerViewModel.register()
                    }
                }) {
                    Text(NSLocalizedString("register_button", comment: "Texto del botón para registrarse"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .accessibilityLabel(NSLocalizedString("register_button_accessibility", comment: "Accesibilidad: Botón para registrar"))
                .accessibilityHint(NSLocalizedString("register_button_hint", comment: "Crea una cuenta nueva"))
            } else {
                // Vista de Login
                LoginFormView(
                    email: $loginViewModel.email,
                    password: $loginViewModel.password,
                    isPasswordVisible: $loginViewModel.isPasswordVisible,
                    showSuccessResetAlert: $loginViewModel.showSuccessResetAlert,
                    viewModel: loginViewModel
                )

                // Botón de login
                Button(action: {
                    withAnimation {
                        loginViewModel.login()
                    }
                }) {
                    Text(NSLocalizedString("login_button", comment: "Texto del botón para iniciar sesión"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .accessibilityLabel(NSLocalizedString("login_button_accessibility", comment: "Accesibilidad: Botón para iniciar sesión"))
                .accessibilityHint(NSLocalizedString("login_button_hint", comment: "Accede a tu cuenta con tu email y contraseña"))
            }

            // Botón para alternar entre Login y Registro
            Button(action: {
                withAnimation {
                    isRegistering.toggle()
                }
            }) {
                Text(isRegistering
                     ? NSLocalizedString("already_have_account", comment: "¿Ya tienes cuenta? Inicia sesión")
                     : NSLocalizedString("dont_have_account", comment: "¿No tienes cuenta? Regístrate"))
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            .accessibilityLabel(
                isRegistering
                ? NSLocalizedString("already_have_account_accessibility", comment: "Accesibilidad: Ya tienes cuenta, inicia sesión")
                : NSLocalizedString("dont_have_account_accessibility", comment: "Accesibilidad: No tienes cuenta, regístrate")
            )

            Spacer()
        }
        .padding()
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
