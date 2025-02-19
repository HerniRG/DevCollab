import SwiftUI
import FirebaseAuth

struct EditarPerfilView: View {
    @State private var nombre: String
    @State private var descripcion: String
    @State private var oldDescripcion: String = ""
    @State private var lenguajesSeleccionados: [LenguajeProgramacion]
    
    private let maxNombreLength = 25
    private let maxDescripcionLength = 150
    
    @ObservedObject var viewModel: PerfilViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(usuario: Usuario, viewModel: PerfilViewModel) {
        self._nombre = State(initialValue: usuario.nombre)
        self._descripcion = State(initialValue: usuario.descripcion ?? "")
        self._lenguajesSeleccionados = State(initialValue: usuario.lenguajes)
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Editar Perfil") {
                    // Campo Nombre
                    TextField("Nombre (máx. \(maxNombreLength) caracteres)", text: $nombre)
                        .onChange(of: nombre) { newValue in
                            if newValue.count > maxNombreLength {
                                nombre = String(newValue.prefix(maxNombreLength))
                            }
                        }
                    
                    // Campo Descripción con contador
                    VStack(alignment: .leading) {
                        Text("Descripción (máx. \(maxDescripcionLength) caracteres)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $descripcion)
                                .frame(minHeight: 80)
                                .onChange(of: descripcion) { newValue in
                                    if newValue.count > maxDescripcionLength {
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
                        HStack {
                            Spacer()
                            Text("\(descripcion.count)/\(maxDescripcionLength)")
                                .font(.caption)
                                .foregroundColor(descripcion.count >= maxDescripcionLength ? .red : .gray)
                        }
                    }
                    
                    // Selector de lenguajes
                    LanguageSelectionWithReturnView(seleccionLenguajes: $lenguajesSeleccionados)
                }
                
                Section {
                    Button("Guardar Cambios") {
                        viewModel.updateUserProfile(
                            nombre: nombre,
                            descripcion: descripcion,
                            lenguajes: lenguajesSeleccionados
                        )
                        // Se recomienda que la vista principal (MainView) se encargue de mostrar el toast globalmente.
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
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
                Text(seleccionLenguajes.isEmpty
                     ? "Seleccionar lenguajes"
                     : seleccionLenguajes.map { $0.rawValue }.joined(separator: ", "))
                    .foregroundColor(seleccionLenguajes.isEmpty ? .gray : .primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
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
            .interactiveDismissDisabled(true)
        }
    }
}
