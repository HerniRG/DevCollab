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
            // Usamos ScrollViewReader solo si necesitamos desplazar el foco al campo
            ScrollViewReader { proxy in
                Form {
                    // MARK: - Sección: Información principal
                    Section {
                        // Campo: Nombre del proyecto
                        TextField(
                            String(
                                format: NSLocalizedString("crear_proyecto_nombre_placeholder", comment: "Placeholder nombre con max %d caracteres"),
                                maxNombreLength
                            ),
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
                        .accessibilityLabel(
                            String(format: NSLocalizedString("crear_proyecto_nombre_accessibility", comment: "Accesibilidad para nombre"), maxNombreLength)
                        )
                        .accessibilityHint(
                            String(format: NSLocalizedString("crear_proyecto_nombre_hint", comment: "Hint para nombre"), maxNombreLength)
                        )
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
                                .accessibilityLabel(NSLocalizedString("crear_proyecto_descripcion_accessibility", comment: "Descripción del proyecto"))
                                .accessibilityHint(
                                    String(
                                        format: NSLocalizedString("crear_proyecto_descripcion_hint", comment: "Máximo %d caracteres"),
                                        maxDescripcionLength
                                    )
                                )
                                .id(Field.descripcion)
                            
                            // Placeholder accesible (pero oculto a VoiceOver)
                            if descripcion.isEmpty {
                                Text(NSLocalizedString("crear_proyecto_descripcion_placeholder", comment: "Ej. Una app para..."))
                                    .foregroundColor(Color(UIColor.placeholderText))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                                    .accessibilityHidden(true)
                            }
                        }
                        .padding(.vertical, 8)
                        
                    } header: {
                        Text(NSLocalizedString("crear_proyecto_informacion_principal", comment: "Encabezado: Información principal"))
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
                    }
                    
                    // MARK: - Sección: Detalles del proyecto
                    Section {
                        // Vista de selección de lenguajes
                        ProjectLanguageSelectionView(seleccionLenguajes: $lenguajesSeleccionados)
                            .id("lenguajes")
                            .accessibilityLabel(NSLocalizedString("crear_proyecto_lenguajes_accessibility", comment: "Lenguajes de programación"))
                            .accessibilityHint(NSLocalizedString("crear_proyecto_lenguajes_hint", comment: "Selecciona los lenguajes necesarios para este proyecto"))
                        
                        // Campo: Horas semanales
                        TextField(
                            NSLocalizedString("crear_proyecto_horas_placeholder", comment: "Placeholder para horas semanales"),
                            text: $horasSemanales
                        )
                        .keyboardType(.numberPad)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .horas)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .colaboracion
                        }
                        .onChange(of: horasSemanales) { _ in
                            // Validaciones extra si lo deseas
                        }
                        .accessibilityLabel(NSLocalizedString("crear_proyecto_horas_accessibility", comment: "Accesibilidad: Horas semanales"))
                        .accessibilityHint(NSLocalizedString("crear_proyecto_horas_hint", comment: "Cuántas horas dedicarás"))
                        .id(Field.horas)
                        
                        // Campo: Tipo de colaboración
                        TextField(
                            String(
                                format: NSLocalizedString("crear_proyecto_colaboracion_placeholder", comment: "Tipo de colaboración con max %d caracteres"),
                                maxTipoColaboracionLength
                            ),
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
                        .accessibilityLabel(NSLocalizedString("crear_proyecto_colaboracion_accessibility", comment: "Accesibilidad: Tipo de colaboración"))
                        .accessibilityHint(NSLocalizedString("crear_proyecto_colaboracion_hint", comment: "Ejemplo: remoto, presencial, híbrido"))
                        .id(Field.colaboracion)
                        
                    } header: {
                        Text(NSLocalizedString("crear_proyecto_detalles_header", comment: "Encabezado: Detalles del proyecto"))
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
                    }
                    
                    // MARK: - Sección: Botón de crear proyecto
                    Section {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                crearProyecto()
                            }
                        }) {
                            Text(NSLocalizedString("crear_proyecto_boton", comment: "Crear Proyecto"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                        }
                        .accessibilityLabel(NSLocalizedString("crear_proyecto_boton_accessibility", comment: "Accesibilidad: Crear proyecto"))
                        .accessibilityHint(NSLocalizedString("crear_proyecto_boton_hint", comment: "Guarda el proyecto y cierra la ventana"))
                        .listRowBackground(Color.blue)
                    }
                    
                    // MARK: - Sección: Botón de cerrar
                    Section {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isPresented = false
                            }
                        }) {
                            Text(NSLocalizedString("crear_proyecto_cerrar_boton", comment: "Cerrar"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                        }
                        .accessibilityLabel(NSLocalizedString("crear_proyecto_cerrar_accessibility", comment: "Cerrar pantalla de creación"))
                        .accessibilityHint(NSLocalizedString("crear_proyecto_cerrar_hint", comment: "Cancela la creación de proyecto y vuelve atrás"))
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
                ViewModelProvider.shared.proyectosViewModel.fetchProyectos()
                withAnimation(.easeInOut) {
                    isPresented = false
                }
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

// MARK: - Subvista: Información Principal (Internacionalizada)
private struct InformacionPrincipalSection: View {
    @Binding var nombre: String
    @Binding var descripcion: String
    let maxNombreLength: Int
    let maxDescripcionLength: Int
    @FocusState.Binding var focusedField: CrearProyectoView.Field?
    
    private var nombrePlaceholder: String {
        String(format: NSLocalizedString("crear_proyecto_nombre_placeholder", comment: "Placeholder para el nombre con max %d caracteres"), maxNombreLength)
    }
    
    private var descripcionPlaceholder: String {
        NSLocalizedString("crear_proyecto_descripcion_placeholder", comment: "Placeholder para la descripción del proyecto")
    }
    
    var body: some View {
        Section(header: Text(NSLocalizedString("crear_proyecto_informacion_principal", comment: "Encabezado: Información principal"))
                    .accessibilityAddTraits(.isHeader)) {
            
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
                .accessibilityLabel(
                    String(format: NSLocalizedString("crear_proyecto_nombre_accessibility", comment: "Accesibilidad para nombre"), maxNombreLength)
                )
                .accessibilityHint(
                    String(format: NSLocalizedString("crear_proyecto_nombre_hint", comment: "Hint para nombre"), maxNombreLength)
                )
            
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
                    .accessibilityLabel(NSLocalizedString("crear_proyecto_descripcion_accessibility", comment: "Descripción del proyecto"))
                    .accessibilityHint(
                        String(format: NSLocalizedString("crear_proyecto_descripcion_hint", comment: "Hint para la descripción con max %d caracteres"), maxDescripcionLength)
                    )
                
                // Placeholder decorativo (oculto a VoiceOver)
                if descripcion.isEmpty {
                    Text(descripcionPlaceholder)
                        .foregroundColor(Color(UIColor.placeholderText))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Subvista: Detalles del Proyecto (Internacionalizada)
private struct DetallesProyectoSection: View {
    @Binding var lenguajesSeleccionados: [LenguajeProgramacion]
    @Binding var horasSemanales: String
    @Binding var tipoColaboracion: String
    let maxTipoColaboracionLength: Int
    @FocusState.Binding var focusedField: CrearProyectoView.Field?
    
    private var colaboracionPlaceholder: String {
        String(
            format: NSLocalizedString("crear_proyecto_colaboracion_placeholder", comment: "Tipo de colaboración con max %d caracteres"),
            maxTipoColaboracionLength
        )
    }
    
    var body: some View {
        Section(header: Text(NSLocalizedString("crear_proyecto_detalles_header", comment: "Encabezado: Detalles del proyecto"))
                    .accessibilityAddTraits(.isHeader)) {
            
            // Vista de selección de lenguajes
            ProjectLanguageSelectionView(seleccionLenguajes: $lenguajesSeleccionados)
                .id("lenguajes")
                .accessibilityLabel(NSLocalizedString("crear_proyecto_lenguajes_accessibility", comment: "Lenguajes de programación"))
                .accessibilityHint(NSLocalizedString("crear_proyecto_lenguajes_hint", comment: "Selecciona los lenguajes necesarios para este proyecto"))
            
            // Campo: Horas semanales
            TextField(
                NSLocalizedString("crear_proyecto_horas_placeholder", comment: "Placeholder para horas semanales"),
                text: $horasSemanales
            )
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
            .accessibilityLabel(NSLocalizedString("crear_proyecto_horas_accessibility", comment: "Accesibilidad: Horas semanales"))
            .accessibilityHint(NSLocalizedString("crear_proyecto_horas_hint", comment: "Cuántas horas piensas dedicar al proyecto cada semana"))
            
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
                .accessibilityLabel(NSLocalizedString("crear_proyecto_colaboracion_accessibility", comment: "Tipo de colaboración"))
                .accessibilityHint(NSLocalizedString("crear_proyecto_colaboracion_hint", comment: "Ejemplo: remoto, presencial, híbrido"))
        }
    }
}
