//
//  LoginRegisterScreen.swift
//  DevCollab
//
//  Created by Hernán Rodríguez on 3/3/25.
//


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
            
            // Alternar entre Login y Registro
            if isRegistering {
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
                    Text("Registrar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
            } else {
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
                    Text("Iniciar Sesión")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
            }
            
            // Botón de cambio entre Login y Registro
            Button(action: {
                withAnimation {
                    isRegistering.toggle()
                }
            }) {
                Text(isRegistering ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        
        .padding()
        // Cierra el teclado cuando se toca fuera
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
    }
    
}
