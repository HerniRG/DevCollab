import SwiftUI
import FirebaseAuth

struct DetalleProyectoCreadorView: View {
    let proyecto: Proyecto
    @StateObject private var viewModel: DetalleProyectoViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(proyecto: Proyecto) {
        self.proyecto = proyecto
        let userID = Auth.auth().currentUser?.uid ?? ""
        _viewModel = StateObject(wrappedValue: DetalleProyectoViewModel(userID: userID))
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                // Vista de carga
                VStack {
                    Spacer()
                    ProgressView("Cargando información...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Vista principal (cuando ya está la información cargada)
                List {
                    // Sección 1: Información del Proyecto
                    Section("Información del Proyecto") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción:")
                                .fontWeight(.semibold)
                            Text(proyecto.descripcion)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("Lenguajes:")
                                .fontWeight(.semibold)
                            Text(proyecto.lenguajes.map { $0.rawValue }.joined(separator: ", "))
                            
                            Text("Horas semanales:")
                                .fontWeight(.semibold)
                            Text("\(proyecto.horasSemanales)")
                            
                            Text("Tipo de colaboración:")
                                .fontWeight(.semibold)
                            Text("\(proyecto.tipoColaboracion)")
                            
                            Text("Estado:")
                                .fontWeight(.semibold)
                            Text(viewModel.estadoProyecto)
                                .foregroundColor(viewModel.estadoProyecto == "Abierto" ? .green : .red)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Sección 2: Información del Creador
                    Section("Información del Creador") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Nombre:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(viewModel.nombreCreador)
                                    .foregroundColor(.primary)
                            }
                            if !viewModel.descripcionCreador.isEmpty {
                                HStack {
                                    Text("Descripción:")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(viewModel.descripcionCreador)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            if !viewModel.lenguajesCreador.isEmpty {
                                HStack {
                                    Text("Lenguajes:")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(viewModel.lenguajesCreador.joined(separator: ", "))
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Sección 3: Botones de acción
                    Section {
                        // Botón para alternar estado (abrir/cerrar)
                        Button(action: {
                            Task {
                                await viewModel.alternarEstadoProyecto(proyectoID: proyecto.id)
                            }
                        }) {
                            Text(viewModel.estadoProyecto == "Abierto" ? "Cerrar Proyecto" : "Reabrir Proyecto")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(viewModel.estadoProyecto == "Abierto" ? Color.red : Color.green)
                    }
                    
                    // Sección 4 eliminar proyecto si está cerrado
                    Section {
                        // Si el proyecto está cerrado, mostrar botón Eliminar
                        if viewModel.estadoProyecto == "Cerrado" {
                            Button(action: {
                                Task {
                                    await viewModel.eliminarProyecto(proyecto: proyecto)
                                    if viewModel.errorMessage == nil {
                                        // Significa que se eliminó sin error
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }) {
                                Text("Eliminar Proyecto")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.red)
                        }
                    }
                    
                    // Sección 5 (opcional): Mensaje de error
                    if let error = viewModel.errorMessage, !error.isEmpty {
                        Section {
                            Text(error)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .listSectionSpacing(20)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .task {
            await viewModel.obtenerDatosAdicionales(proyectoID: proyecto.id)
        }
    }
}
