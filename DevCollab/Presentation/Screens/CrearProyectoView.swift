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
                        .accessibilityLabel("Nombre del proyecto")
                        .accessibilityHint("Introduce el nombre del proyecto, máximo \(maxNombreLength) caracteres")
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
                                .accessibilityLabel("Descripción del proyecto")
                                .accessibilityHint("Máximo \(maxDescripcionLength) caracteres. Explica de qué trata el proyecto.")
                                .id(Field.descripcion)
                            
                            // Placeholder accesible
                            if descripcion.isEmpty {
                                Text("Descripción")
                                    .foregroundColor(Color(UIColor.placeholderText))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                                    .accessibilityHidden(true) // VoiceOver no debe leerlo como texto real
                            }
                        }
                        .padding(.vertical, 8)
                        
                    } header: {
                        Text("Información principal")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
                    }
                    
                    // MARK: - Sección: Detalles del proyecto
                    Section {
                        // Vista de selección de lenguajes
                        ProjectLanguageSelectionView(seleccionLenguajes: $lenguajesSeleccionados)
                            .id("lenguajes")
                            .accessibilityLabel("Lenguajes de programación")
                            .accessibilityHint("Selecciona los lenguajes necesarios para este proyecto")
                        
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
                            .onChange(of: horasSemanales) { newValue in
                                // Podrías aplicar validaciones extra en accesibilidad
                            }
                            .accessibilityLabel("Horas semanales")
                            .accessibilityHint("Número aproximado de horas que invertirás en el proyecto cada semana")
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
                        .accessibilityLabel("Tipo de colaboración")
                        .accessibilityHint("Ejemplo: remoto, presencial, híbrido, etc.")
                        .id(Field.colaboracion)
                        
                    } header: {
                        Text("Detalles del proyecto")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
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
                        .accessibilityLabel("Crear Proyecto")
                        .accessibilityHint("Guarda el proyecto y cierra la ventana")
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
                        .accessibilityLabel("Cerrar pantalla de creación")
                        .accessibilityHint("Cancela la creación de proyecto y vuelve atrás")
                        .listRowBackground(Color.gray)
                    }
                }
                .listStyle(InsetGroupedListStyle())
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
        // Etiquetamos la sección para VoiceOver
        Section("Información principal") {
            // Campo: Nombre del proyecto
            TextField(nombrePlaceholder, text: $nombre)
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
                .id(CrearProyectoView.Field.nombre)
                // Accesibilidad
                .accessibilityLabel("Nombre del proyecto")
                .accessibilityHint("Introduce el nombre, máximo \(maxNombreLength) caracteres")
            
            // Campo: Descripción con placeholder
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
                    // Accesibilidad
                    .accessibilityLabel("Descripción del proyecto")
                    .accessibilityHint("Explica de qué trata el proyecto, máximo \(maxDescripcionLength) caracteres")
                
                // Placeholder decorativo
                if descripcion.isEmpty {
                    Text(descripcionPlaceholder)
                        .foregroundColor(Color(UIColor.placeholderText))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true) // No lo anunciamos en VoiceOver
                }
            }
            .padding(.vertical, 8)
        }
        // Marca a VoiceOver que este 'Text("Información principal")' es cabecera
        .accessibilityAddTraits(.isHeader)
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
            // Vista de selección de lenguajes
            ProjectLanguageSelectionView(seleccionLenguajes: $lenguajesSeleccionados)
                .id("lenguajes")
                .accessibilityLabel("Lenguajes de programación")
                .accessibilityHint("Selecciona los lenguajes necesarios para este proyecto")
            
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
                .id(CrearProyectoView.Field.horas)
                // Accesibilidad
                .accessibilityLabel("Horas semanales")
                .accessibilityHint("Cuántas horas piensas dedicar al proyecto cada semana")
            
            // Campo: Tipo de colaboración
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
                // Accesibilidad
                .accessibilityLabel("Tipo de colaboración")
                .accessibilityHint("Por ejemplo remoto, presencial, híbrido...")
        }
        .accessibilityAddTraits(.isHeader)
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
                    creadorID: userID
                ) { success in
                    if success {
                        onSuccess()
                    }
                }
            }) {
                Text("Crear Proyecto")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
            }
            .accessibilityLabel("Crear Proyecto")
            .accessibilityHint("Guarda el proyecto con la información proporcionada")
            .listRowBackground(Color.blue)
        }
    }
}
