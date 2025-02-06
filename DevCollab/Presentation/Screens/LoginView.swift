import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var nombre: String = ""
    @State private var seleccionLenguajes: [LenguajeProgramacion] = []
    @State private var isPasswordVisible: Bool = false
    @State private var showLanguageMenu = false // Este estado ya no se usa en LanguageSelectionView
    @State private var showSuccessResetAlert = false // ✅ Nueva alerta de éxito
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                // 🔹 CABECERA DEL LOGIN/REGISTRO
                LoginHeaderView(isRegistering: viewModel.isRegistering)

                // 🔹 CAMPOS DE TEXTO
                LoginTextFieldsView(
                    email: $email,
                    password: $password,
                    isPasswordVisible: $isPasswordVisible,
                    isRegistering: viewModel.isRegistering,
                    nombre: $nombre,
                    seleccionLenguajes: $seleccionLenguajes,
                    showLanguageMenu: $showLanguageMenu, // Se mantiene aquí, pero ya no se utiliza en la subvista
                    showSuccessResetAlert: $showSuccessResetAlert,
                    viewModel: viewModel
                )
                
                // 🔹 BOTÓN LOGIN/REGISTRO
                Button(action: {
                    withAnimation(.easeInOut) {
                        if viewModel.isRegistering {
                            viewModel.register(
                                email: email,
                                password: password,
                                nombre: nombre,
                                lenguajes: seleccionLenguajes,
                                descripcion: nil
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
                
                // 🔹 BOTÓN PARA CAMBIAR ENTRE LOGIN/REGISTRO
                Button(action: {
                    withAnimation(.easeInOut) {
                        viewModel.isRegistering.toggle()
                        viewModel.errorMessage = nil  // Limpiar el mensaje de error al cambiar de modo
                    }
                }) {
                    Text(viewModel.isRegistering ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                
                // 🔹 MENSAJE DE ERROR
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                        .font(.footnote)
                }
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onTapGesture {
                withAnimation {
                    showLanguageMenu = false
                }
            }
            // 🔥 ALERTA DE CONFIRMACIÓN CUANDO EL CORREO SE ENVÍA
            .alert("Correo enviado", isPresented: $showSuccessResetAlert, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text("Se ha enviado un enlace de recuperación a \(email). Revisa tu bandeja de entrada o spam.")
            })
        }
    }
}

// 🔹 SUBVISTA: CABECERA (Título y Descripción)
struct LoginHeaderView: View {
    let isRegistering: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            Text("DevCollab")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.blue)
            
            Text(isRegistering ? "Crea tu cuenta" : "Inicia sesión")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
        }
    }
}

// 🔹 SUBVISTA: CAMPOS DE TEXTO
struct LoginTextFieldsView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    let isRegistering: Bool
    @Binding var nombre: String
    @Binding var seleccionLenguajes: [LenguajeProgramacion]
    @Binding var showLanguageMenu: Bool // Este binding se conserva en el LoginTextFieldsView (aunque ya no se use en LanguageSelectionView)
    @Binding var showSuccessResetAlert: Bool // ✅ Añadir Binding
    let viewModel: AuthViewModel

    var body: some View {
        Group {
            CustomTextField(placeholder: "Correo electrónico", text: $email, keyboardType: .emailAddress)

            CustomSecureField(placeholder: "Contraseña", text: $password, isPasswordVisible: $isPasswordVisible)

            if !isRegistering {
                Button(action: {
                    Task {
                        do {
                            try await viewModel.resetPassword(email: email)
                            showSuccessResetAlert = true // ✅ Ahora sí está en scope
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
            }

            if isRegistering {
                CustomTextField(placeholder: "Nombre", text: $nombre)
                
                // Llamada a LanguageSelectionView sin pasar el binding showLanguageMenu
                LanguageSelectionView(seleccionLenguajes: $seleccionLenguajes)
            }
        }
        .padding(.horizontal, 30)
    }
}

// 🔹 SUBVISTA: SELECCIÓN DE LENGUAJES
struct LanguageSelectionView: View {
    @Binding var seleccionLenguajes: [LenguajeProgramacion]
    @State private var showLanguageSheet = false

    var body: some View {
        Button(action: {
            showLanguageSheet = true
        }) {
            HStack {
                Text(seleccionLenguajes.isEmpty
                     ? "Seleccionar lenguajes"
                     : seleccionLenguajes.map { $0.rawValue }.joined(separator: ", "))
                    .foregroundColor(seleccionLenguajes.isEmpty ? .gray : .primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
        .sheet(isPresented: $showLanguageSheet) {
            NavigationView {
                List {
                    ForEach(LenguajeProgramacion.allCases, id: \.self) { lenguaje in
                        MultipleSelectionRow(
                            lenguaje: lenguaje,
                            isSelected: seleccionLenguajes.contains(lenguaje),
                            action: {
                                if seleccionLenguajes.contains(lenguaje) {
                                    seleccionLenguajes.removeAll { $0 == lenguaje }
                                } else {
                                    seleccionLenguajes.append(lenguaje)
                                }
                            }
                        )
                    }
                }
                .navigationTitle("Lenguajes de Programación")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Hecho") {
                            showLanguageSheet = false
                        }
                    }
                }
            }
        }
    }
}

struct MultipleSelectionRow: View {
    var lenguaje: LenguajeProgramacion
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(lenguaje.rawValue)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
}
