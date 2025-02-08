import SwiftUI

struct EditarPerfilView: View {
    @State private var nombre: String
    @State private var descripcion: String
    
    @State private var oldDescripcion: String = ""
    @State private var lenguajesSeleccionados: [LenguajeProgramacion]
    
    private let maxNombreLength = 25
    private let maxDescripcionLength = 150
    
    @ObservedObject var viewModel: PerfilViewModel
    
    // Sin cerrar la vista completa al pulsar “Hecho” en lenguajes
    @Environment(\.presentationMode) var presentationMode
    
    init(usuario: Usuario, viewModel: PerfilViewModel) {
        self._nombre = State(initialValue: usuario.nombre)
        self._descripcion = State(initialValue: usuario.descripcion ?? "")
        self._lenguajesSeleccionados = State(initialValue: usuario.lenguajes)
        self.viewModel = viewModel
    }
    
    var body: some View {
        Form {
            Section("Editar Perfil") {
                TextField("Nombre (máx. \(maxNombreLength) caracteres)", text: $nombre)
                    .onChange(of: nombre) { newValue in
                        if newValue.count > maxNombreLength {
                            nombre = String(newValue.prefix(maxNombreLength))
                        }
                    }
                
                // Descripción
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
                    // Contador
                    HStack {
                        Spacer()
                        Text("\(descripcion.count)/\(maxDescripcionLength)")
                            .font(.caption)
                            .foregroundColor(descripcion.count >= maxDescripcionLength ? .red : .gray)
                    }
                }
                
                // Selector de lenguajes con el nuevo componente
                LanguageSelectionWithReturnView(seleccionLenguajes: $lenguajesSeleccionados)
            }
            
            Section {
                Button("Guardar Cambios") {
                    viewModel.updateUserProfile(
                        nombre: nombre,
                        descripcion: descripcion,
                        lenguajes: lenguajesSeleccionados
                    )
                }
            }
            
            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            
            if viewModel.isProfileUpdated {
                Section {
                    Text("Perfil actualizado con éxito")
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Editar Perfil")
    }
}

struct LanguageSelectionWithReturnView: View {
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
            .padding(8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
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
            .interactiveDismissDisabled(true)
        }
    }
}
