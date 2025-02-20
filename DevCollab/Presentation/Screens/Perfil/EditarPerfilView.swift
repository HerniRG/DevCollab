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
                    "Nombre (máx. \(maxNombreLength) caracteres)",
                    text: $nombre
                )
                .onChange(of: nombre) { newValue in
                    if newValue.count > maxNombreLength {
                        nombre = String(newValue.prefix(maxNombreLength))
                    }
                }
                // Accesibilidad
                .accessibilityLabel("Nombre del perfil")
                .accessibilityHint("Introduce tu nombre, máximo de \(maxNombreLength) caracteres.")
                
                // Campo: Descripción con contador
                VStack(alignment: .leading, spacing: 6) {
                    Text("Descripción (máx. \(maxDescripcionLength) caracteres)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .accessibilityHidden(true) // Texto meramente informativo (puedes exponerlo si lo prefieres)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $descripcion)
                            .frame(minHeight: 80)
                            .onChange(of: descripcion) { newValue in
                                if newValue.count > maxDescripcionLength {
                                    // Si supera el máximo, volvemos al valor anterior
                                    descripcion = oldDescripcion
                                } else {
                                    oldDescripcion = descripcion
                                }
                            }
                            // Accesibilidad
                            .accessibilityLabel("Descripción del perfil")
                            .accessibilityHint("Cuéntanos un poco sobre ti, máximo \(maxDescripcionLength) caracteres")
                        
                        // Placeholder accesible: se oculta con .accessibilityHidden(true)
                        if descripcion.isEmpty {
                            Text("Ej. Mobile Developer, Backend, Diseño UX/UI...")
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
                            .foregroundColor(
                                descripcion.count >= maxDescripcionLength ? .red : .gray
                            )
                            .accessibilityLabel(
                                "Caracteres usados: \(descripcion.count) de \(maxDescripcionLength)"
                            )
                    }
                }
                
                // Selector de lenguajes (subvista con fullScreenCover)
                LanguageSelectionWithReturnView(seleccionLenguajes: $lenguajesSeleccionados)
                    .accessibilityLabel("Lenguajes de programación")
                    .accessibilityHint("Selecciona los lenguajes en los que sueles trabajar")
                
            } header: {
                Text("Editar Perfil")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
            }
            
            // MARK: - Sección: Botón Guardar
            Section {
                Button("Guardar Cambios") {
                    viewModel.updateUserProfile(
                        nombre: nombre,
                        descripcion: descripcion,
                        lenguajes: lenguajesSeleccionados
                    )
                    
                    // Opcional: cerrar la vista tras guardar:
                    // presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
                // Accesibilidad del botón
                .accessibilityLabel("Guardar Cambios")
                .accessibilityHint("Actualiza tu perfil con los datos ingresados")
            }
            .listRowBackground(Color.blue)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitleDisplayMode(.inline)
        // Si quisieras un botón "Cerrar" arriba a la izquierda,
        // podrías añadir un .toolbar{} con un ToolbarItem (como en otras vistas).
    }
}

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
                    ? "Seleccionar lenguajes"
                    : seleccionLenguajes.map { $0.rawValue }.joined(separator: ", ")
                )
                .foregroundColor(seleccionLenguajes.isEmpty ? .gray : .primary)
                
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .accessibilityHidden(true) // es un icono decorativo
            }
            .padding(8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
        .accessibilityLabel("Seleccionar lenguajes")
        .accessibilityHint("Abre la lista de lenguajes de programación disponibles")
        // Usamos fullScreenCover para el selector de lenguajes
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
                        .accessibilityLabel("\(lenguaje.rawValue)")
                        .accessibilityHint(
                            seleccionLenguajes.contains(lenguaje)
                            ? "Actualmente seleccionado. Activa para deseleccionar"
                            : "No seleccionado. Activa para seleccionar"
                        )
                    }
                }
                .navigationTitle("Lenguajes de Programación")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Hecho") {
                            showLanguageModal = false
                        }
                        .accessibilityLabel("Hecho")
                        .accessibilityHint("Cierra la lista de lenguajes")
                    }
                }
            }
            // Deshabilita el dismiss interactivo si no se ha pulsado "Hecho"
            .interactiveDismissDisabled(true)
        }
    }
}
