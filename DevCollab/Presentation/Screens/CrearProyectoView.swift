import SwiftUI
import FirebaseAuth

struct CrearProyectoView: View {
    @ObservedObject var viewModel: CrearProyectoViewModel
    
    @State private var nombre: String = ""
    @State private var descripcion: String = ""
    @State private var lenguajesSeleccionados: [LenguajeProgramacion] = []
    @State private var horasSemanales: String = ""
    @State private var tipoColaboracion: String = ""
    @State private var estado: String = "Abierto"
    
    var body: some View {
        NavigationView {
            List {
                Section(
                    header: Text("Crear Proyecto")
                        .font(.headline)
                        .fontWeight(.bold)
                ) {
                    Section("Información principal") {
                        TextField("Nombre del proyecto", text: $nombre)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                        
                        TextField("Descripción", text: $descripcion)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                    }
                    .headerProminence(.increased) // Más notorio el título "Información principal"
                    .listSectionSeparator(.visible, edges: .bottom)
                    
                    Section("Detalles del proyecto") {
                        ProjectLanguageSelectionView(seleccionLenguajes: $lenguajesSeleccionados)
                        TextField("Horas semanales", text: $horasSemanales)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                        
                        TextField("Tipo de colaboración", text: $tipoColaboracion)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                    }
                    
                    
                    Button(action: crearProyecto) {
                        Text("Crear Proyecto")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                    
                    if viewModel.isSuccess {
                        Text("Proyecto creado exitosamente")
                            .foregroundColor(.green)
                    }
                }
                .headerProminence(.increased)
            }
            // 🔹 Estilo de lista con secciones separadas
            .listStyle(InsetGroupedListStyle())
            // 🔹 iOS 16: Ajustar espacio vertical entre secciones
            .listSectionSpacing(20)
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

// MARK: - Vista de Selección de Lenguajes (renombrada)
struct ProjectLanguageSelectionView: View {
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
                        ProjectMultipleSelectionRow(
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
        }
    }
}

// MARK: - Fila de Selección Múltiple (renombrada)
struct ProjectMultipleSelectionRow: View {
    var lenguaje: LenguajeProgramacion
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(lenguaje.rawValue)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
