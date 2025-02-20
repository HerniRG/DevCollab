import SwiftUI
import FirebaseAuth

struct AuthMainView: View {
    @ObservedObject var viewModel: AuthViewModel

    // Estados locales para el formulario
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var nombre: String = ""
    @State private var descripcion: String = ""
    @State private var seleccionLenguajes: [LenguajeProgramacion] = []
    @State private var isPasswordVisible: Bool = false
    @State private var showSuccessResetAlert: Bool = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                // Cabecera común con etiquetado de accesibilidad
                AuthHeaderView(isRegistering: viewModel.isRegistering)
                
                // Contenido: Registro o Login según el estado
                if viewModel.isRegistering {
                    RegisterView(
                        email: $email,
                        password: $password,
                        nombre: $nombre,
                        descripcion: $descripcion,
                        seleccionLenguajes: $seleccionLenguajes,
                        isPasswordVisible: $isPasswordVisible,
                        showSuccessResetAlert: $showSuccessResetAlert,
                        viewModel: viewModel
                    )
                    .accessibilityLabel("Formulario de registro")
                    .accessibilityHint("Introduce tus datos para crear una cuenta")
                } else {
                    LoginFormView(
                        email: $email,
                        password: $password,
                        isPasswordVisible: $isPasswordVisible,
                        showSuccessResetAlert: $showSuccessResetAlert,
                        viewModel: viewModel
                    )
                    .accessibilityLabel("Formulario de inicio de sesión")
                    .accessibilityHint("Introduce tus credenciales para acceder a la aplicación")
                }
                
                // Botón de acción: Login o Registrar
                Button(action: {
                    withAnimation(.easeInOut) {
                        if viewModel.isRegistering {
                            viewModel.register(
                                email: email,
                                password: password,
                                nombre: nombre,
                                lenguajes: seleccionLenguajes,
                                descripcion: descripcion
                            )
                        } else {
                            viewModel.login(email: email, password: password)
                        }
                    }
                }) {
                    Text(viewModel.isRegistering ? "Registrar" : "Iniciar Sesión")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .accessibilityLabel(viewModel.isRegistering ? "Botón registrar" : "Botón iniciar sesión")
                .accessibilityHint(viewModel.isRegistering
                                   ? "Crea tu cuenta con los datos proporcionados"
                                   : "Inicia sesión con el email y la contraseña introducidos")
                
                // Botón para cambiar entre Login y Registro
                Button(action: {
                    withAnimation(.easeInOut) {
                        viewModel.isRegistering.toggle()
                    }
                }) {
                    Text(viewModel.isRegistering ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .accessibilityLabel(
                    viewModel.isRegistering
                    ? "Cambiar a iniciar sesión"
                    : "Cambiar a registro de cuenta"
                )
                .accessibilityHint(
                    viewModel.isRegistering
                    ? "Te lleva al formulario para iniciar sesión"
                    : "Te lleva al formulario para crear una cuenta nueva"
                )
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            // Cierra el teclado al tocar fuera
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        // Overlay para mostrar el Toast usando el ToastManager
        .overlay(
            Group {
                if let toast = viewModel.toastManager.message {
                    ToastView(message: toast)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 20)
                        .accessibilityElement()
                        .accessibilityLabel("Mensaje: \(toast)")
                }
            },
            alignment: .top
        )
    }
}

// MARK: - Cabecera Común
struct AuthHeaderView: View {
    let isRegistering: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            Text("DevCollab")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.blue)
                // VoiceOver: nombre de la app
                .accessibilityLabel("DevCollab")
                .accessibilityAddTraits(.isHeader)
            
            Text(isRegistering ? "Crea tu cuenta" : "Inicia sesión")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
                // VoiceOver: subtítulo
                .accessibilityLabel(isRegistering ? "Crea tu cuenta" : "Inicia sesión")
        }
        // Esto actúa como un bloque de encabezado
        .accessibilityElement(children: .combine)
    }
}

extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
}
