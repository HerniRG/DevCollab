import SwiftUI
import FirebaseAuth

struct EditarPerfilView: View {
    @ObservedObject var viewModel: PerfilViewModel
    
    // Estados para campos
    @State private var nombre: String
    @State private var descripcion: String
    @State private var oldDescripcion: String = ""
    @State private var lenguajesSeleccionados: [LenguajeProgramacion]
    
    private let maxNombreLength = 25
    private let maxDescripcionLength = 150
    
    @Environment(\.presentationMode) var presentationMode
    
    // Inicializador que recibe el usuario a editar
    init(usuario: Usuario, viewModel: PerfilViewModel) {
        self._nombre = State(initialValue: usuario.nombre)
        self._descripcion = State(initialValue: usuario.descripcion ?? "")
        self._lenguajesSeleccionados = State(initialValue: usuario.lenguajes)
        self.viewModel = viewModel
    }
    
    var body: some View {
        Form {
            // MARK: - Sección: Editar Perfil
            Section {
                // Campo: Nombre con límite de caracteres
                TextField(
                    String(
                        format: NSLocalizedString("edit_profile_name_placeholder", comment: "Nombre (máx. %d caracteres)"),
                        maxNombreLength
                    ),
                    text: $nombre
                )
                .onChange(of: nombre) { oldValue, newValue in
                    if newValue.count > maxNombreLength {
                        nombre = String(newValue.prefix(maxNombreLength))
                    }
                }
                .accessibilityLabel(NSLocalizedString("edit_profile_name_accessibility", comment: "Nombre del perfil"))
                .accessibilityHint(
                    String(
                        format: NSLocalizedString("edit_profile_name_hint", comment: "Hint: Nombre máximo %d caracteres."),
                        maxNombreLength
                    )
                )
                
                // Campo: Descripción con contador
                VStack(alignment: .leading, spacing: 6) {
                    // Etiqueta "Descripción"
                    Text(
                        String(
                            format: NSLocalizedString("edit_profile_description_label", comment: "Descripción (máx. %d caracteres)"),
                            maxDescripcionLength
                        )
                    )
                    .font(.caption)
                    .foregroundColor(.gray)
                    .accessibilityHidden(true)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $descripcion)
                            .frame(minHeight: 80)
                            .onChange(of: descripcion) { oldValue, newValue in
                                if newValue.count > maxDescripcionLength {
                                    descripcion = oldDescripcion
                                } else {
                                    oldDescripcion = descripcion
                                }
                            }
                            .accessibilityLabel(NSLocalizedString("edit_profile_description_accessibility", comment: "Descripción del perfil"))
                            .accessibilityHint(
                                String(
                                    format: NSLocalizedString("edit_profile_description_hint", comment: "Máximo %d caracteres. Describe tu experiencia o rol"),
                                    maxDescripcionLength
                                )
                            )
                        
                        // Placeholder accesible: se oculta en VoiceOver con .accessibilityHidden(true)
                        if descripcion.isEmpty {
                            Text(NSLocalizedString("edit_profile_description_placeholder", comment: "Ejemplo de descripción"))
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                                .accessibilityHidden(true)
                        }
                    }
                    
                    // Contador de caracteres
                    HStack {
                        Spacer()
                        Text("\(descripcion.count)/\(maxDescripcionLength)")
                            .font(.caption)
                            .foregroundColor(descripcion.count >= maxDescripcionLength ? .red : .gray)
                            .accessibilityLabel(
                                String(
                                    format: NSLocalizedString("edit_profile_description_counter_accessibility", comment: "Carácteres usados: %d de %d"),
                                    descripcion.count,
                                    maxDescripcionLength
                                )
                            )
                    }
                }
                
                // Selector de lenguajes
                LanguageSelectionWithReturnView(seleccionLenguajes: $lenguajesSeleccionados)
                    .accessibilityLabel(NSLocalizedString("edit_profile_languages_accessibility", comment: "Lenguajes de programación"))
                    .accessibilityHint(NSLocalizedString("edit_profile_languages_hint", comment: "Selecciona lenguajes en los que trabajas"))
                
            } header: {
                Text(NSLocalizedString("edit_profile_section_header", comment: "Editar Perfil"))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
            }
            
            // MARK: - Sección: Botón Guardar
            Section {
                Button(NSLocalizedString("edit_profile_save_button", comment: "Guardar Cambios")) {
                    viewModel.updateUserProfile(
                        nombre: nombre,
                        descripcion: descripcion,
                        lenguajes: lenguajesSeleccionados
                    )
                    // Opcional: cerrar la vista tras guardar
                    // presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
                .accessibilityLabel(NSLocalizedString("edit_profile_save_accessibility", comment: "Guardar Cambios"))
                .accessibilityHint(NSLocalizedString("edit_profile_save_hint", comment: "Actualiza el perfil con los datos ingresados"))
            }
            .listRowBackground(Color.blue)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - LanguageSelectionWithReturnView Internacionalizado
struct LanguageSelectionWithReturnView: View {
    @Binding var seleccionLenguajes: [LenguajeProgramacion]
    @State private var showLanguageModal = false
    
    var body: some View {
        Button(action: {
            showLanguageModal = true
        }) {
            HStack {
                Text(
                    seleccionLenguajes.isEmpty
                    ? NSLocalizedString("select_languages", comment: "Seleccionar lenguajes")
                    : seleccionLenguajes
                        .map { NSLocalizedString($0.rawValue, comment: "Nombre de lenguaje") }
                        .joined(separator: ", ")
                )
                .foregroundColor(seleccionLenguajes.isEmpty ? .gray : .primary)
                
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .accessibilityHidden(true)
            }
            .padding(8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
        .accessibilityLabel(NSLocalizedString("select_languages_accessibility", comment: "Botón para seleccionar lenguajes"))
        .accessibilityHint(NSLocalizedString("select_languages_hint", comment: "Abre la lista de lenguajes de programación"))
        .fullScreenCover(isPresented: $showLanguageModal) {
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
                        .accessibilityLabel(NSLocalizedString(lenguaje.rawValue, comment: "Nombre del lenguaje"))
                        .accessibilityHint(
                            seleccionLenguajes.contains(lenguaje)
                            ? NSLocalizedString("language_selected_hint", comment: "Lenguaje seleccionado. Toca para deseleccionar")
                            : NSLocalizedString("language_unselected_hint", comment: "Lenguaje no seleccionado. Toca para seleccionar")
                        )
                    }
                }
                .navigationTitle(NSLocalizedString("languages_title", comment: "Lenguajes de Programación"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(NSLocalizedString("languages_done_button", comment: "Hecho")) {
                            showLanguageModal = false
                        }
                        .accessibilityLabel(NSLocalizedString("languages_done_button_accessibility", comment: "Hecho"))
                        .accessibilityHint(NSLocalizedString("languages_done_button_hint", comment: "Cierra la lista de lenguajes"))
                    }
                }
            }
            .interactiveDismissDisabled(true)
        }
    }
}
