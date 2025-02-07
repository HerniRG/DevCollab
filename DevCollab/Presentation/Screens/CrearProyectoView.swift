import SwiftUI
import FirebaseAuth

struct CrearProyectoView: View {
    @ObservedObject var viewModel: CrearProyectoViewModel
    
    // Estados para los campos
    @State private var nombre: String = ""
    @State private var descripcion: String = ""
    @State private var lenguajesSeleccionados: [LenguajeProgramacion] = []
    @State private var horasSemanales: String = ""
    @State private var tipoColaboracion: String = ""
    @State private var estado: String = "Abierto"
    
    // Límites de caracteres
    private let maxNombreLength = 25
    private let maxDescripcionLength = 150
    private let maxTipoColaboracionLength = 25
    
    var body: some View {
        NavigationView {
            Form {
                // Sección 1: Información principal
                Section("Información principal") {
                    // Campo para el nombre con límite indicado en el placeholder
                    TextField("Nombre del proyecto (máx. \(maxNombreLength) caracteres)", text: $nombre)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .onChange(of: nombre) { newValue in
                            if newValue.count > maxNombreLength {
                                nombre = String(newValue.prefix(maxNombreLength))
                            }
                        }
                    
                    
                    
                    VStack(){
                        HStack(){
                            Text("Descripción  (máx. \(maxDescripcionLength) caracteres)")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.top, 8)
                            Spacer()
                        }
                        
                        
                        TextEditor(text: $descripcion)
                            .frame(minHeight: 100, maxHeight: 200)
                            .onChange(of: descripcion) { newValue in
                                if newValue.count > maxDescripcionLength {
                                    descripcion = String(newValue.prefix(maxDescripcionLength))
                                }
                            }
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 8)
                    
                    
                }
                
                // Sección 2: Detalles del proyecto
                Section("Detalles del proyecto") {
                    ProjectLanguageSelectionView(seleccionLenguajes: $lenguajesSeleccionados)
                    
                    TextField("Horas semanales", text: $horasSemanales)
                        .keyboardType(.numberPad)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                    
                    // Campo para el tipo de colaboración con límite en el placeholder
                    TextField("Tipo de colaboración (máx. \(maxTipoColaboracionLength) caracteres)", text: $tipoColaboracion)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .onChange(of: tipoColaboracion) { newValue in
                            if newValue.count > maxTipoColaboracionLength {
                                tipoColaboracion = String(newValue.prefix(maxTipoColaboracionLength))
                            }
                        }
                }
                
                // Sección 3: Botón para crear el proyecto
                Section {
                    Button(action: crearProyecto) {
                        Text("Crear Proyecto")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
                
                if viewModel.isSuccess {
                    Section {
                        Text("Proyecto creado exitosamente")
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
    
    private func crearProyecto() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No hay usuario autenticado")
            return
        }
        
        let proyecto = Proyecto(
            id: UUID().uuidString,
            nombre: nombre,
            descripcion: descripcion,
            lenguajes: lenguajesSeleccionados,
            horasSemanales: Int(horasSemanales) ?? 0,
            tipoColaboracion: tipoColaboracion,
            estado: estado,
            creadorID: userID
        )
        viewModel.crearProyecto(proyecto: proyecto)
    }
}
