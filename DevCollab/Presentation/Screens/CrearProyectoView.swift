import SwiftUI
import FirebaseAuth

struct CrearProyectoView: View {
    @ObservedObject var viewModel: CrearProyectoViewModel
    @Environment(\.colorScheme) var colorScheme  // Para detectar modo oscuro/claro

    // Estados para los campos
    @State private var nombre: String = ""
    @State private var descripcion: String = ""
    @State private var lenguajesSeleccionados: [LenguajeProgramacion] = []
    @State private var horasSemanales: String = ""
    @State private var tipoColaboracion: String = ""

    // Límites de caracteres
    private let maxNombreLength = 25
    private let maxDescripcionLength = 150
    private let maxTipoColaboracionLength = 25

    // FocusState para navegar entre campos con el teclado
    enum Field: Hashable {
        case nombre, descripcion, horas, colaboracion
    }
    @FocusState private var focusedField: Field?

    // Computed property para el fondo del TextEditor
    var editorBackground: Color {
        if colorScheme == .dark {
            return Color(UIColor.systemGray5)
        } else {
            return Color(UIColor.secondarySystemBackground)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Sección 1: Información principal
                Section("Información principal") {
                    TextField("Nombre del proyecto (máx. \(maxNombreLength) caracteres)", text: $nombre)
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
                        .accessibilityLabel("Nombre del proyecto")
                        .accessibilityHint("Introduce el nombre del proyecto, máximo \(maxNombreLength) caracteres.")

                    // Campo para la descripción con TextEditor y placeholder simulado
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $descripcion)
                            .frame(minHeight: 100, maxHeight: 200)
                            .focused($focusedField, equals: .descripcion)
                            // Ocultar el fondo predeterminado (disponible en iOS 16+)
                            .scrollContentBackground(.hidden)
                            .onChange(of: descripcion) { newValue in
                                if newValue.count > maxDescripcionLength {
                                    descripcion = String(newValue.prefix(maxDescripcionLength))
                                }
                            }
                            .background(editorBackground)
                            .cornerRadius(8)
                        if descripcion.isEmpty {
                            Text("Descripción")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
                    .padding(.vertical, 8)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Descripción del proyecto")
                    .accessibilityHint("Introduce la descripción del proyecto, máximo \(maxDescripcionLength) caracteres.")
                }
                
                // Sección 2: Detalles del proyecto
                Section("Detalles del proyecto") {
                    ProjectLanguageSelectionView(seleccionLenguajes: $lenguajesSeleccionados)
                        .accessibilityLabel("Lenguajes de programación")
                        .accessibilityHint("Selecciona los lenguajes de programación para el proyecto. Puedes usar el teclado para navegar si es compatible.")

                    TextField("Horas semanales", text: $horasSemanales)
                        .keyboardType(.numberPad)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .horas)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .colaboracion }
                        .accessibilityLabel("Horas semanales")
                        .accessibilityHint("Introduce el número de horas semanales dedicadas al proyecto.")
                    
                    TextField("Tipo de colaboración (máx. \(maxTipoColaboracionLength) caracteres)", text: $tipoColaboracion)
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
                        .accessibilityHint("Introduce el tipo de colaboración para el proyecto, máximo \(maxTipoColaboracionLength) caracteres.")
                }
                
                // Sección 3: Botón para crear el proyecto
                Section {
                    Button(action: {
                        guard let userID = Auth.auth().currentUser?.uid else {
                            print("Error: No hay usuario autenticado")
                            return
                        }
                        viewModel.crearProyecto(nombre: nombre,
                                                descripcion: descripcion,
                                                lenguajes: lenguajesSeleccionados,
                                                horasSemanales: horasSemanales,
                                                tipoColaboracion: tipoColaboracion,
                                                creadorID: userID)
                    }) {
                        Text("Crear Proyecto")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                    }
                    .accessibilityLabel("Crear proyecto")
                    .accessibilityHint("Toca para crear el proyecto con los datos introducidos.")
                    .listRowBackground(Color.blue)
                }
                
                // Sección 4: Mensaje de estado (error o éxito)
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                    .accessibilityLabel("Error")
                } else if viewModel.isSuccess {
                    Section {
                        Text("Proyecto creado exitosamente")
                            .foregroundColor(.green)
                    }
                    .accessibilityLabel("Proyecto creado exitosamente")
                }
            }
        }
        // Limpieza de campos al crear el proyecto exitosamente
        .onChange(of: viewModel.isSuccess) { success in
            if success {
                nombre = ""
                descripcion = ""
                horasSemanales = ""
                tipoColaboracion = ""
                lenguajesSeleccionados = []
                viewModel.isSuccess = false
            }
        }
        // Al salir de la vista se limpia el mensaje de error
        .onDisappear {
            viewModel.errorMessage = nil
        }
    }
}
