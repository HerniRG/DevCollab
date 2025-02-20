import SwiftUI

struct RegisterView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var nombre: String
    @Binding var descripcion: String
    @Binding var seleccionLenguajes: [LenguajeProgramacion]
    @Binding var isPasswordVisible: Bool
    @Binding var showSuccessResetAlert: Bool
    let viewModel: AuthViewModel
    
    // Número máximo de caracteres para la descripción
    let maxDescriptionLength = 25
    
    // Enumeración para gestionar el enfoque de los campos
    enum RegisterField: Hashable {
        case email, password, nombre, descripcion
    }
    @FocusState private var focusedField: RegisterField?
    
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Campo de Correo
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
            // Accesibilidad
            .accessibilityLabel("Correo electrónico")
            .accessibilityHint("Introduce tu correo para registrarte")
            
            // MARK: - Campo de Contraseña (con visor)
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
            .accessibilityHint("Introduce tu contraseña de registro")
            
            // MARK: - Campo de Nombre
            CustomTextField(
                placeholder: "Nombre",
                text: $nombre
            )
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .focused($focusedField, equals: .nombre)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .descripcion
            }
            .accessibilityLabel("Nombre")
            .accessibilityHint("Introduce tu nombre o alias en la plataforma")
            
            // MARK: - Campo de Descripción con contador de caracteres
            VStack(alignment: .trailing, spacing: 4) {
                CustomTextField(
                    placeholder: "Descripción (ej. Mobile Developer, Backend, Diseño UX/UI)",
                    text: $descripcion
                )
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: .descripcion)
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                }
                .onChange(of: descripcion) { newValue in
                    if newValue.count > maxDescriptionLength {
                        descripcion = String(newValue.prefix(maxDescriptionLength))
                    }
                }
                // Accesibilidad
                .accessibilityLabel("Descripción")
                .accessibilityHint("Máximo \(maxDescriptionLength) caracteres. Describe brevemente tu experiencia o rol.")
                
                Text("\(descripcion.count)/\(maxDescriptionLength)")
                    .font(.caption)
                    .foregroundColor(descripcion.count >= maxDescriptionLength ? .red : .gray)
                    .accessibilityLabel("Caracteres usados: \(descripcion.count) de \(maxDescriptionLength)")
            }
            
            // MARK: - Vista de selección de lenguajes
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
                    .accessibilityHidden(true) // Icono decorativo
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
        .accessibilityLabel("Seleccionar lenguajes")
        .accessibilityHint("Abre la lista para elegir lenguajes de programación")
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
                        .accessibilityLabel("Hecho")
                        .accessibilityHint("Cierra la lista de lenguajes seleccionados")
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
        .accessibilityHint(
            isSelected
            ? "Actualmente seleccionado. Pulsa para deseleccionar"
            : "No seleccionado. Pulsa para seleccionar"
        )
    }
}
