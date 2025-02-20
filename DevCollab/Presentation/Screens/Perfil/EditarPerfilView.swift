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
        // MARK: - Estructura principal sin NavigationView de raíz
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
                
                // Campo: Descripción con contador
                VStack(alignment: .leading, spacing: 6) {
                    Text("Descripción (máx. \(maxDescripcionLength) caracteres)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
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
                        
                        if descripcion.isEmpty {
                            Text("Ej. Mobile Developer, Backend, Diseño UX/UI...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
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
                    }
                }
                
                // Selector de lenguajes (subvista con fullScreenCover)
                LanguageSelectionWithReturnView(seleccionLenguajes: $lenguajesSeleccionados)
            } header: {
                Text("Editar Perfil")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            // MARK: - Sección: Botón Guardar
            Section {
                Button("Guardar Cambios") {
                    viewModel.updateUserProfile(
                        nombre: nombre,
                        descripcion: descripcion,
                        lenguajes: lenguajesSeleccionados
                    )
                    
                    // Opcional: puedes cerrar la vista tras guardar,
                    // si así lo deseas:
                    // presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
            }
            .listRowBackground(Color.blue)
        }
        .listStyle(InsetGroupedListStyle())
        // Ajusta la visualización del título si lo deseas:
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
            }
            .padding(8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
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
                    }
                }
                .navigationTitle("Lenguajes de Programación")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Hecho") {
                            showLanguageModal = false
                        }
                    }
                }
            }
            // Deshabilita el dismiss interactivo si no se ha pulsado "Hecho"
            // (depende de tus preferencias):
            .interactiveDismissDisabled(true)
        }
    }
}
