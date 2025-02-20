import SwiftUI
import FirebaseAuth

struct CrearProyectoView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel = ViewModelProvider.shared.crearProyectoViewModel
    @Binding var isPresented: Bool  // Permite cerrar la vista desde dentro
    
    // Estados locales para el formulario
    @State private var nombre: String = ""
    @State private var descripcion: String = ""
    @State private var lenguajesSeleccionados: [LenguajeProgramacion] = []
    @State private var horasSemanales: String = ""
    @State private var tipoColaboracion: String = ""
    
    private let maxNombreLength = 25
    private let maxDescripcionLength = 150
    private let maxTipoColaboracionLength = 25
    
    // Enum para el foco
    enum Field: Hashable {
        case nombre, descripcion, horas, colaboracion
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { proxy in
                Form {
                    // MARK: - Sección: Información principal
                    Section {
                        // Campo: Nombre del proyecto
                        TextField(
                            "Nombre del proyecto (máx. \(maxNombreLength) caracteres)",
                            text: $nombre
                        )
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .nombre)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .descripcion
                        }
                        .onChange(of: nombre) { newValue in
                            if newValue.count > maxNombreLength {
                                nombre = String(newValue.prefix(maxNombreLength))
                            }
                        }
                        .id(Field.nombre)
                        
                        // Campo: Descripción (TextEditor con placeholder)
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $descripcion)
                                .frame(minHeight: 100, maxHeight: 200)
                                .focused($focusedField, equals: .descripcion)
                                .scrollContentBackground(.hidden)
                                .onChange(of: descripcion) { newValue in
                                    if newValue.count > maxDescripcionLength {
                                        descripcion = String(newValue.prefix(maxDescripcionLength))
                                    }
                                }
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(8)
                                .id(Field.descripcion)
                            
                            if descripcion.isEmpty {
                                Text("Descripción")
                                    .foregroundColor(Color(UIColor.placeholderText))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(.vertical, 8)
                        
                    } header: {
                        Text("Información principal")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    // MARK: - Sección: Detalles del proyecto
                    Section {
                        // Vista de selección de lenguajes
                        ProjectLanguageSelectionView(seleccionLenguajes: $lenguajesSeleccionados)
                            .id("lenguajes")
                        
                        // Campo: Horas semanales
                        TextField("Horas semanales", text: $horasSemanales)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .focused($focusedField, equals: .horas)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .colaboracion
                            }
                            .id(Field.horas)
                        
                        // Campo: Tipo de colaboración
                        TextField(
                            "Tipo de colaboración (máx. \(maxTipoColaboracionLength) caracteres)",
                            text: $tipoColaboracion
                        )
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .colaboracion)
                        .submitLabel(.done)
                        .onChange(of: tipoColaboracion) { newValue in
                            if newValue.count > maxTipoColaboracionLength {
                                tipoColaboracion = String(newValue.prefix(maxTipoColaboracionLength))
                            }
                        }
                        .id(Field.colaboracion)
                        
                    } header: {
                        Text("Detalles del proyecto")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    // MARK: - Sección: Botón de crear proyecto
                    Section {
                        Button(action: {
                            crearProyecto()
                        }) {
                            Text("Crear Proyecto")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.blue)
                    }
                    
                    // MARK: - Sección: Botón de cerrar
                    Section {
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Cerrar")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.gray)
                    }
                }
                .listStyle(InsetGroupedListStyle()) // Estilo similar a la vista de exploración
                .onChange(of: focusedField) { field in
                    // Desplaza la vista para enfocar el campo si es necesario
                    withAnimation {
                        proxy.scrollTo(field, anchor: .center)
                    }
                }
            }
        }
    }
    
    // MARK: - Función para crear el proyecto
    private func crearProyecto() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No hay usuario autenticado")
            return
        }
        viewModel.crearProyecto(
            nombre: nombre,
            descripcion: descripcion,
            lenguajes: lenguajesSeleccionados,
            horasSemanales: horasSemanales,
            tipoColaboracion: tipoColaboracion,
            creadorID: userID
        ) { success in
            if success {
                clearFields()
                isPresented = false
            }
        }
    }
    
    // MARK: - Limpiar campos
    private func clearFields() {
        nombre = ""
        descripcion = ""
        lenguajesSeleccionados = []
        horasSemanales = ""
        tipoColaboracion = ""
    }
}

// MARK: - Subvista: Información Principal
private struct InformacionPrincipalSection: View {
    @Binding var nombre: String
    @Binding var descripcion: String
    let maxNombreLength: Int
    let maxDescripcionLength: Int
    @FocusState.Binding var focusedField: CrearProyectoView.Field?
    
    private var nombrePlaceholder: String {
        "Nombre del proyecto (máx. \(maxNombreLength) caracteres)"
    }
    private var descripcionPlaceholder: String {
        "Descripción"
    }
    
    var body: some View {
        Section("Información principal") {
            TextField(nombrePlaceholder, text: $nombre)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: .nombre)
                .submitLabel(.next)
                .onSubmit { focusedField = .descripcion }
                .onChange(of: nombre) { newValue in
                    if newValue.count > maxNombreLength {
                        nombre = String(newValue.prefix(maxNombreLength))
                    }
                }
                .id(CrearProyectoView.Field.nombre)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $descripcion)
                    .frame(minHeight: 100, maxHeight: 200)
                    .focused($focusedField, equals: .descripcion)
                    .scrollContentBackground(.hidden)
                    .onChange(of: descripcion) { newValue in
                        if newValue.count > maxDescripcionLength {
                            descripcion = String(newValue.prefix(maxDescripcionLength))
                        }
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .id(CrearProyectoView.Field.descripcion)
                if descripcion.isEmpty {
                    Text(descripcionPlaceholder)
                        .foregroundColor(Color(UIColor.placeholderText))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Subvista: Detalles del Proyecto
private struct DetallesProyectoSection: View {
    @Binding var lenguajesSeleccionados: [LenguajeProgramacion]
    @Binding var horasSemanales: String
    @Binding var tipoColaboracion: String
    let maxTipoColaboracionLength: Int
    @FocusState.Binding var focusedField: CrearProyectoView.Field?
    
    private var colaboracionPlaceholder: String {
        "Tipo de colaboración (máx. \(maxTipoColaboracionLength) caracteres)"
    }
    
    var body: some View {
        Section("Detalles del proyecto") {
            ProjectLanguageSelectionView(seleccionLenguajes: $lenguajesSeleccionados)
                .id("lenguajes")
            TextField("Horas semanales", text: $horasSemanales)
                .keyboardType(.numberPad)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: .horas)
                .submitLabel(.next)
                .onSubmit { focusedField = .colaboracion }
                .id(CrearProyectoView.Field.horas)
            TextField(colaboracionPlaceholder, text: $tipoColaboracion)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: .colaboracion)
                .submitLabel(.done)
                .onChange(of: tipoColaboracion) { newValue in
                    if newValue.count > maxTipoColaboracionLength {
                        tipoColaboracion = String(newValue.prefix(maxTipoColaboracionLength))
                    }
                }
                .id(CrearProyectoView.Field.colaboracion)
        }
    }
}

// MARK: - Subvista: Botón de Crear Proyecto
private struct CrearProyectoButtonSection: View {
    @Binding var isPresented: Bool
    var viewModel: CrearProyectoViewModel
    let nombre: String
    let descripcion: String
    let lenguajesSeleccionados: [LenguajeProgramacion]
    let horasSemanales: String
    let tipoColaboracion: String
    let onSuccess: () -> Void
    
    var body: some View {
        Section {
            Button(action: {
                guard let userID = Auth.auth().currentUser?.uid else {
                    print("Error: No hay usuario autenticado")
                    return
                }
                viewModel.crearProyecto(
                    nombre: nombre,
                    descripcion: descripcion,
                    lenguajes: lenguajesSeleccionados,
                    horasSemanales: horasSemanales,
                    tipoColaboracion: tipoColaboracion,
                    creadorID: userID,
                    completion: { success in
                        if success {
                            onSuccess()
                        }
                    }
                )
            }) {
                Text("Crear Proyecto")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
            }
            .listRowBackground(Color.blue)
        }
    }
}
