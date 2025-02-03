import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var nombre: String = ""
    @State private var seleccionLenguajes: Set<LenguajeProgramacion> = []
    @State private var disponibilidad: String = ""
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Text("DevCollab").font(.largeTitle).bold()
            TextField("Correo electrónico", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Contraseña", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if viewModel.isRegistering {
                TextField("Nombre", text: $nombre)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Text("Lenguajes de Programación")
                    .font(.headline)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(LenguajeProgramacion.allCases, id: \ .self) { lenguaje in
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
                
                TextField("Disponibilidad", text: $disponibilidad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            
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
            
            Button(action: {
                viewModel.isRegistering.toggle()
            }) {
                Text(viewModel.isRegistering ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate")
                    .foregroundColor(.blue)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red).padding()
            }
        }
        .padding()
    }
}
