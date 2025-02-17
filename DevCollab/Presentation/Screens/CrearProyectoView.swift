import SwiftUI
import FirebaseAuth

struct CrearProyectoView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // ObservedObject para el ViewModel (usamos el shared desde el provider)
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
            NavigationView {
                ScrollViewReader { proxy in
                    Form {
                        // Sección: Información principal
                        InformacionPrincipalSection(nombre: $nombre,
                                                    descripcion: $descripcion,
                                                    maxNombreLength: maxNombreLength,
                                                    maxDescripcionLength: maxDescripcionLength,
                                                    focusedField: $focusedField)
                        
                        // Sección: Detalles del proyecto
                        DetallesProyectoSection(lenguajesSeleccionados: $lenguajesSeleccionados,
                                                horasSemanales: $horasSemanales,
                                                tipoColaboracion: $tipoColaboracion,
                                                maxTipoColaboracionLength: maxTipoColaboracionLength,
                                                focusedField: $focusedField)
                        
                        // Sección: Botón de creación
                        CrearProyectoButtonSection(isPresented: $isPresented,
                                                   viewModel: viewModel,
                                                   nombre: nombre,
                                                   descripcion: descripcion,
                                                   lenguajesSeleccionados: lenguajesSeleccionados,
                                                   horasSemanales: horasSemanales,
                                                   tipoColaboracion: tipoColaboracion)
                    }
                    .onChange(of: focusedField) { field in
                        withAnimation {
                            proxy.scrollTo(field, anchor: .center)
                        }
                    }
                    .navigationTitle("Nuevo Proyecto")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cerrar") {
                                isPresented = false
                            }
                        }
                    }
                }
            }
            
            // Toast Overlay
            if let toastMsg = viewModel.toastMessage {
                ToastView(message: toastMsg)
                    .padding(.top, 50)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: viewModel.toastMessage)
        .onChange(of: viewModel.toastMessage) { msg in
            if let m = msg, m.contains("✅ Proyecto creado exitosamente.") {
                // Resetea los campos tras el éxito
                nombre = ""
                descripcion = ""
                horasSemanales = ""
                tipoColaboracion = ""
                lenguajesSeleccionados = []
            }
        }
        .onDisappear {
            viewModel.toastMessage = nil
        }
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
                    .background(
                        Color(UIColor.secondarySystemBackground)
                    )
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
                )
                // No se pasa trailing closure aquí, ya que el método no la espera.
            }) {
                Text("Crear Proyecto")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
            }
            .listRowBackground(Color.blue)
        }
    }
}
