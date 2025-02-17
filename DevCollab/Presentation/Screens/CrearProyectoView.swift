import SwiftUI
import FirebaseAuth

struct CrearProyectoView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // 1. ObservedObject for the ViewModel
    @ObservedObject var viewModel = ViewModelProvider.shared.crearProyectoViewModel
    
    // 2. Local states for form fields
    @State private var nombre: String = ""
    @State private var descripcion: String = ""
    @State private var lenguajesSeleccionados: [LenguajeProgramacion] = []
    @State private var horasSemanales: String = ""
    @State private var tipoColaboracion: String = ""
    
    private let maxNombreLength = 25
    private let maxDescripcionLength = 150
    private let maxTipoColaboracionLength = 25
    
    enum Field: Hashable {
        case nombre, descripcion, horas, colaboracion
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ZStack (alignment: .top) {
            // Main Content
            NavigationView {
                ScrollViewReader { proxy in
                    Form {
                        Section("Información principal") {
                            TextField("Nombre del proyecto (máx. \(maxNombreLength) caracteres)",
                                      text: $nombre
                            )
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
                            .id(Field.nombre)
                            
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
                                    .background(colorScheme == .dark
                                                ? Color(UIColor.systemGray5)
                                                : Color(UIColor.secondarySystemBackground))
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
                        }
                        
                        Section("Detalles del proyecto") {
                            // Lenguajes
                            ProjectLanguageSelectionView(seleccionLenguajes: $lenguajesSeleccionados)
                                .id("lenguajes")
                            
                            // Horas semanales
                            TextField("Horas semanales", text: $horasSemanales)
                                .keyboardType(.numberPad)
                                .autocorrectionDisabled(true)
                                .textInputAutocapitalization(.never)
                                .focused($focusedField, equals: .horas)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .colaboracion }
                                .id(Field.horas)
                            
                            // Tipo Colaboración
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
                        }
                        
                        // Botón para crear el proyecto
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
                            }) {
                                Text("Crear Proyecto")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.blue)
                        }
                    }
                    .onChange(of: focusedField) { field in
                        withAnimation {
                            proxy.scrollTo(field, anchor: .center)
                        }
                    }
                }
            }
            
            // Toast Overlay (if toastMessage is not nil)
            if let toastMsg = viewModel.toastMessage {
                ToastView(message: toastMsg)
                    // Position near the top if desired
                    .padding(.top, 50)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: viewModel.toastMessage)
        // Limpiar campos tras éxito => detect "Proyecto creado exitosamente."
        .onChange(of: viewModel.toastMessage) { msg in
            if let m = msg, m.contains("✅ Proyecto creado exitosamente.") {
                // If we want to reset fields after a success
                nombre = ""
                descripcion = ""
                horasSemanales = ""
                tipoColaboracion = ""
                lenguajesSeleccionados = []
            }
        }
        .onDisappear {
            // Clear any potential toast
            viewModel.toastMessage = nil
        }
    }
}
