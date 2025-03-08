import SwiftUI

struct RegisterView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var nombre: String
    @Binding var descripcion: String
    @Binding var seleccionLenguajes: [LenguajeProgramacion]
    @Binding var isPasswordVisible: Bool
    @Binding var showSuccessResetAlert: Bool
    let viewModel: RegisterViewModel
    
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
                placeholderKey: "register_email_placeholder",
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
            .accessibilityLabel(NSLocalizedString("register_email_accessibility", comment: "Accesibilidad: campo de correo para registro"))
            .accessibilityHint(NSLocalizedString("register_email_hint", comment: "Hint: introduce tu correo para registrarte"))
            
            // MARK: - Campo de Contraseña (con visor)
            CustomSecureField(
                placeholder: NSLocalizedString("register_password_placeholder", comment: "Placeholder para contraseña"),
                text: $password,
                isPasswordVisible: $isPasswordVisible
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .nombre
            }
            .accessibilityLabel(NSLocalizedString("register_password_accessibility", comment: "Accesibilidad: campo de contraseña"))
            .accessibilityHint(NSLocalizedString("register_password_hint", comment: "Hint: introduce tu contraseña para registro"))
            
            // MARK: - Campo de Nombre
            CustomTextField(
                placeholderKey: "register_name_placeholder",
                text: $nombre
            )
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .focused($focusedField, equals: .nombre)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .descripcion
            }
            .accessibilityLabel(NSLocalizedString("register_name_accessibility", comment: "Accesibilidad: campo de nombre"))
            .accessibilityHint(NSLocalizedString("register_name_hint", comment: "Hint: introduce tu nombre o alias"))
            
            // MARK: - Campo de Descripción con contador de caracteres
            VStack(alignment: .trailing, spacing: 4) {
                CustomTextField(
                    placeholderKey: "register_description_placeholder",
                    text: $descripcion
                )
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: .descripcion)
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                }
                .onChange(of: descripcion) { oldValue, newValue in
                    if newValue.count > maxDescriptionLength {
                        descripcion = String(newValue.prefix(maxDescriptionLength))
                    }
                }
                .accessibilityLabel(NSLocalizedString("register_description_accessibility", comment: "Accesibilidad: campo de descripción"))
                .accessibilityHint(
                    String(
                        format: NSLocalizedString("register_description_hint", comment: "Hint: Máximo %d caracteres. Describe tu experiencia o rol."),
                        maxDescriptionLength
                    )
                )
                
                Text("\(descripcion.count)/\(maxDescriptionLength)")
                    .font(.caption)
                    .foregroundColor(descripcion.count >= maxDescriptionLength ? .red : .gray)
                    .accessibilityLabel(
                        String(
                            format: NSLocalizedString("register_description_counter_accessibility", comment: "Contador de descripción"),
                            descripcion.count,
                            maxDescriptionLength
                        )
                    )
            }
            
            // MARK: - Vista de selección de lenguajes
            LanguageSelectionView(seleccionLenguajes: $seleccionLenguajes)
        }
        .padding(.horizontal, 30)
    }
}

// MARK: - Vista de Selección de Lenguajes (Internacionalizada)
struct LanguageSelectionView: View {
    @Binding var seleccionLenguajes: [LenguajeProgramacion]
    @State private var showLanguageSheet = false

    var body: some View {
        Button(action: {
            showLanguageSheet = true
        }) {
            HStack {
                // Texto dinámico: si no hay lenguajes seleccionados → "select_languages"
                // si hay lenguajes → los traducimos uno a uno.
                Text(
                    seleccionLenguajes.isEmpty
                    ? NSLocalizedString("select_languages", comment: "Texto para seleccionar lenguajes")
                    : seleccionLenguajes
                        .map { NSLocalizedString($0.rawValue, comment: "Nombre de lenguaje") }
                        .joined(separator: ", ")
                )
                .foregroundColor(seleccionLenguajes.isEmpty ? .gray : .primary)

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .accessibilityHidden(true) // icono decorativo
            }
            .padding(8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
        .accessibilityLabel(
            NSLocalizedString("select_languages_accessibility", comment: "Accesibilidad: Botón para seleccionar lenguajes")
        )
        .accessibilityHint(
            NSLocalizedString("select_languages_hint", comment: "Abre la lista para elegir lenguajes de programación")
        )
        .sheet(isPresented: $showLanguageSheet) {
            NavigationView {
                List {
                    ForEach(LenguajeProgramacion.allCases, id: \.self) { lenguaje in
                        MultipleSelectionRow(
                            lenguaje: lenguaje,
                            isSelected: seleccionLenguajes.contains(lenguaje),
                            action: {
                                // Agregar o quitar lenguaje de la lista
                                if seleccionLenguajes.contains(lenguaje) {
                                    seleccionLenguajes.removeAll { $0 == lenguaje }
                                } else {
                                    seleccionLenguajes.append(lenguaje)
                                }
                            }
                        )
                    }
                }
                .navigationTitle(NSLocalizedString("languages_title", comment: "Título para la lista de lenguajes"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(NSLocalizedString("languages_done_button", comment: "Botón para cerrar la lista de lenguajes")) {
                            showLanguageSheet = false
                        }
                        .accessibilityLabel(NSLocalizedString("languages_done_button_accessibility", comment: "Accesibilidad: Hecho"))
                        .accessibilityHint(NSLocalizedString("languages_done_button_hint", comment: "Cierra la lista de lenguajes"))
                    }
                }
            }
        }
    }
}

// MARK: - Fila de Selección Múltiple (Internacionalizada)
struct MultipleSelectionRow: View {
    var lenguaje: LenguajeProgramacion
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                // Mostramos el lenguaje en su traducción, si existe
                Text(NSLocalizedString(lenguaje.rawValue, comment: "Nombre del lenguaje de programación"))
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
        .accessibilityLabel(
            NSLocalizedString(lenguaje.rawValue, comment: "Nombre del lenguaje de programación en accesibilidad")
        )
        .accessibilityHint(
            isSelected
            ? NSLocalizedString("language_selected_hint", comment: "Seleccionado. Pulsa para deseleccionar")
            : NSLocalizedString("language_unselected_hint", comment: "No seleccionado. Pulsa para seleccionar")
        )
    }
}
