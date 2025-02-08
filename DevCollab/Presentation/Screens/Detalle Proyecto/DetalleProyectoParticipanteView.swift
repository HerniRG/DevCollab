import SwiftUI
import FirebaseAuth

struct DetalleProyectoParticipanteView: View {
    let proyecto: Proyecto
    @StateObject private var viewModel: DetalleProyectoViewModel

    init(proyecto: Proyecto) {
        self.proyecto = proyecto
        let userID = Auth.auth().currentUser?.uid ?? ""
        _viewModel = StateObject(wrappedValue: DetalleProyectoViewModel(userID: userID))
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Cargando información...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
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
                    
                    // Sección 3: Botón para solicitar participación o mostrar estado
                    Section {
                        if !viewModel.yaSolicitado {
                            Button(action: {
                                Task {
                                    await viewModel.solicitarParticipacion(proyectoID: proyecto.id)
                                }
                            }) {
                                Text("Solicitar Participación")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.blue)
                        } else {
                            Text("Solicitud Pendiente o Aprobada")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    
                    // Sección 4: Lista de Participantes (nuevamente)
                    Section("Participantes") {
                        if viewModel.participantes.isEmpty {
                            Text("No hay participantes aprobados.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.participantes, id: \.id) { participante in
                                HStack {
                                    Text(participante.nombre)
                                        .fontWeight(.semibold)
                                    if !participante.lenguajes.isEmpty {
                                        Text("(\(participante.lenguajes.map { $0.rawValue }.joined(separator: ", ")))")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Sección 5: Mensaje de error (solo si hay error)
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
            await viewModel.fetchParticipantes(proyectoID: proyecto.id)
        }
    }
}
