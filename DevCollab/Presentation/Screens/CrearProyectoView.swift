import SwiftUI
import FirebaseAuth

struct CrearProyectoView: View {
    @ObservedObject var viewModel: CrearProyectoViewModel
    @Environment(\.colorScheme) var colorScheme  // Para detectar modo oscuro/claro

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
        NavigationView {
            ScrollViewReader { proxy in
                Form {
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
                            .id(Field.nombre)  // Asigna un ID único para desplazamiento

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
                                .background(colorScheme == .dark ? Color(UIColor.systemGray5) : Color(UIColor.secondarySystemBackground))
                                .cornerRadius(8)
                                .id(Field.descripcion)  // Asigna un ID único para desplazamiento
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
                        ProjectLanguageSelectionView(seleccionLenguajes: $lenguajesSeleccionados)
                            .id("lenguajes")

                        TextField("Horas semanales", text: $horasSemanales)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .focused($focusedField, equals: .horas)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .colaboracion }
                            .id(Field.horas)

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
                            .id(Field.colaboracion)
                    }
                    
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
                        .listRowBackground(Color.blue)
                    }
                    
                    if let error = viewModel.errorMessage {
                        Section {
                            Text(error)
                                .foregroundColor(.red)
                        }
                    } else if viewModel.isSuccess {
                        Section {
                            Text("Proyecto creado exitosamente")
                                .foregroundColor(.green)
                        }
                    }
                }
                .onChange(of: focusedField) { field in
                    withAnimation {
                        proxy.scrollTo(field, anchor: .center)
                    }
                }
            }
        }
        .onChange(of: viewModel.isSuccess) { success in
            if success {
                nombre = ""
                descripcion = ""
                horasSemanales = ""
                tipoColaboracion = ""
                lenguajesSeleccionados = []
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    viewModel.isSuccess = false
                }
            }
        }
        .onDisappear {
            viewModel.errorMessage = nil
        }
    }
}
