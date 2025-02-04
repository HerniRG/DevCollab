import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var nombre: String = ""
    @State private var seleccionLenguajes: Set<LenguajeProgramacion> = []
    @State private var disponibilidad: String = ""
    @State private var isPasswordVisible: Bool = false
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Text("DevCollab")
                .font(.largeTitle)
                .bold()
            
            // Campo de Correo Electrónico
            TextField("Correo electrónico", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Campo de Contraseña con opción de ver/ocultar
            HStack {
                if isPasswordVisible {
                    TextField("Contraseña", text: $password)
                } else {
                    SecureField("Contraseña", text: $password)
                }
                
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            .textContentType(.password)
            .autocapitalization(.none)
            .padding()
            
            if viewModel.isRegistering {
                // Campo de Nombre
                TextField("Nombre", text: $nombre)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Selección de Lenguajes de Programación
                Text("Lenguajes de Programación")
                    .font(.headline)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(LenguajeProgramacion.allCases, id: \.self) { lenguaje in
                            Button(action: {
                                if seleccionLenguajes.contains(lenguaje) {
                                    seleccionLenguajes.remove(lenguaje)
                                } else {
                                    seleccionLenguajes.insert(lenguaje)
                                }
                            }) {
                                Text(lenguaje.rawValue)
                                    .padding()
                                    .background(seleccionLenguajes.contains(lenguaje) ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                
                // Campo de Disponibilidad
                TextField("Disponibilidad", text: $disponibilidad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            
            // Botón de Registro/Login
            Button(action: {
                if viewModel.isRegistering {
                    viewModel.register(email: email, password: password, nombre: nombre, lenguajes: Array(seleccionLenguajes), disponibilidad: disponibilidad, descripcion: nil)
                } else {
                    viewModel.login(email: email, password: password)
                }
            }) {
                Text(viewModel.isRegistering ? "Registrar" : "Iniciar Sesión")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            // Opción de cambiar entre Login/Registro
            Button(action: {
                viewModel.isRegistering.toggle()
            }) {
                Text(viewModel.isRegistering ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate")
                    .foregroundColor(.blue)
            }
            
            // Mensaje de error si hay problemas
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}
