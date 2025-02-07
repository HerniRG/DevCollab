import SwiftUI

struct AuthMainView: View {
    @ObservedObject var viewModel: AuthViewModel
    // Estados compartidos
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var nombre: String = ""
    @State private var description: String = ""
    @State private var seleccionLenguajes: [LenguajeProgramacion] = []
    @State private var isPasswordVisible: Bool = false
    @State private var showSuccessResetAlert: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                // CABECERA COMÚN
                AuthHeaderView(isRegistering: viewModel.isRegistering)
                
                // Contenido: Login o Registro
                if viewModel.isRegistering {
                    RegisterView(
                        email: $email,
                        password: $password,
                        nombre: $nombre,
                        descripcion: $description,
                        seleccionLenguajes: $seleccionLenguajes,
                        isPasswordVisible: $isPasswordVisible,
                        showSuccessResetAlert: $showSuccessResetAlert,
                        viewModel: viewModel
                    )
                } else {
                    LoginFormView(
                        email: $email,
                        password: $password,
                        isPasswordVisible: $isPasswordVisible,
                        showSuccessResetAlert: $showSuccessResetAlert,
                        viewModel: viewModel
                    )
                }
                
                // BOTÓN DE ACCIÓN (LOGIN o REGISTRAR)
                Button(action: {
                    withAnimation(.easeInOut) {
                        if viewModel.isRegistering {
                            viewModel.register(
                                email: email,
                                password: password,
                                nombre: nombre,
                                lenguajes: seleccionLenguajes,
                                descripcion: description
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
                .accessibilityLabel(viewModel.isRegistering ? "Registrar" : "Iniciar Sesión")
                
                // BOTÓN PARA CAMBIAR ENTRE LOGIN Y REGISTRO
                Button(action: {
                    withAnimation(.easeInOut) {
                        viewModel.isRegistering.toggle()
                        viewModel.errorMessage = nil  // Limpiar mensajes de error
                    }
                }) {
                    Text(viewModel.isRegistering ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .accessibilityLabel(viewModel.isRegistering ? "Ir a iniciar sesión" : "Ir a registrarse")
                
                // MENSAJE DE ERROR
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                        .font(.footnote)
                        .accessibilityLabel("Error: \(errorMessage)")
                }
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            // Al tocar fuera se cierra el teclado
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            // ALERTA DE CONFIRMACIÓN CUANDO SE ENVÍA UN CORREO (en caso de reset)
            .alert("Correo enviado", isPresented: $showSuccessResetAlert, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text("Se ha enviado un enlace de recuperación a \(email). Revisa tu bandeja de entrada o spam.")
            })
        }
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
                .accessibilityAddTraits(.isHeader)
            Text(isRegistering ? "Crea tu cuenta" : "Inicia sesión")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
                .accessibilityLabel(isRegistering ? "Crea tu cuenta" : "Inicia sesión")
        }
    }
}

extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
}
