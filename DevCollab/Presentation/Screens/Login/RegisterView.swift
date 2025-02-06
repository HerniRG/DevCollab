import SwiftUI

// MARK: - Vista de Registro
struct RegisterView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var nombre: String
    @Binding var seleccionLenguajes: [LenguajeProgramacion]
    @Binding var isPasswordVisible: Bool
    @Binding var showSuccessResetAlert: Bool
    let viewModel: AuthViewModel
    
    // Enumeración para gestionar el enfoque de los campos en registro
    enum RegisterField: Hashable {
        case email
        case password
        case nombre
    }
    @FocusState private var focusedField: RegisterField?
    
    var body: some View {
        VStack(spacing: 16) {
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
            
            CustomSecureField(
                placeholder: "Contraseña",
                text: $password,
                isPasswordVisible: $isPasswordVisible
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .nombre
            }
            .accessibilityLabel("Contraseña")
            
            CustomTextField(
                placeholder: "Nombre",
                text: $nombre
            )
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .focused($focusedField, equals: .nombre)
            .submitLabel(.done)
            .onSubmit {
                focusedField = nil
            }
            .accessibilityLabel("Nombre")
            
            // Vista de selección de lenguajes
            LanguageSelectionView(seleccionLenguajes: $seleccionLenguajes)
        }
        .padding(.horizontal, 30)
    }
}

// MARK: - Vista de Selección de Lenguajes
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
        .accessibilityLabel("Seleccionar lenguajes")
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

// MARK: - Fila de Selección Múltiple
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(lenguaje.rawValue)
        .accessibilityHint(isSelected ? "Seleccionado" : "No seleccionado")
    }
}
