import SwiftUI
import FirebaseAuth

struct LoginRegisterScreen: View {
    @ObservedObject var authContainerVM: AuthContainerViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // --- Cabecera (siempre la misma vista) ---
            AuthHeaderView(isRegistering: authContainerVM.isRegistering)
                .transition(.opacity)
                .animation(.easeInOut, value: authContainerVM.isRegistering)
            
            // --- Formulario (cambia Login vs. Registro) ---
            ZStack {
                // Vista de Registro
                if authContainerVM.isRegistering {
                    RegisterView(
                        email: $authContainerVM.registerVM.email,
                        password: $authContainerVM.registerVM.password,
                        nombre: $authContainerVM.registerVM.nombre,
                        descripcion: $authContainerVM.registerVM.descripcion,
                        seleccionLenguajes: $authContainerVM.registerVM.seleccionLenguajes,
                        isPasswordVisible: $authContainerVM.registerVM.isPasswordVisible,
                        showSuccessResetAlert: $authContainerVM.registerVM.showSuccessResetAlert,
                        viewModel: authContainerVM.registerVM
                    )
                    .transition(.opacity) // Efecto de fade
                }
                // Vista de Login
                else {
                    LoginFormView(
                        email: $authContainerVM.loginVM.email,
                        password: $authContainerVM.loginVM.password,
                        isPasswordVisible: $authContainerVM.loginVM.isPasswordVisible,
                        showSuccessResetAlert: $authContainerVM.loginVM.showSuccessResetAlert,
                        viewModel: authContainerVM.loginVM
                    )
                    .transition(.opacity) // Efecto de fade
                }
            }
            .animation(.easeInOut, value: authContainerVM.isRegistering)

            // --- Botón principal (cambia texto y color según el modo) ---
            Button(action: {
                withAnimation {
                    if authContainerVM.isRegistering {
                        authContainerVM.registerVM.register()
                    } else {
                        authContainerVM.loginVM.login()
                    }
                }
            }) {
                Text(
                    authContainerVM.isRegistering
                    ? NSLocalizedString("register_button", comment: "Texto del botón para registrarse")
                    : NSLocalizedString("login_button", comment: "Texto del botón para iniciar sesión")
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(authContainerVM.isRegistering ? Color.blue : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal, 30)
            }
            .transition(.opacity)
            .animation(.easeInOut, value: authContainerVM.isRegistering)

            // --- Botón para alternar entre Login y Registro ---
            Button {
                withAnimation {
                    authContainerVM.toggleRegistering()
                }
            } label: {
                Text(
                    authContainerVM.isRegistering
                    ? NSLocalizedString("already_have_account", comment: "¿Ya tienes cuenta? Inicia sesión")
                    : NSLocalizedString("dont_have_account", comment: "¿No tienes cuenta? Regístrate")
                )
                .font(.footnote)
                .foregroundColor(.blue)
            }
            .transition(.opacity)
            .animation(.easeInOut, value: authContainerVM.isRegistering)
            
            Spacer()
        }
        .padding()
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
        }
    }
}
