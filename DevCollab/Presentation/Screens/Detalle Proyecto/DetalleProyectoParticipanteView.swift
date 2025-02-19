import SwiftUI
import FirebaseAuth

struct DetalleProyectoParticipanteView: View {
    let proyecto: Proyecto
    @StateObject private var viewModel: DetalleProyectoViewModel
    @State private var showSolicitudModal = false
    @State private var showAbandonConfirmation = false  // Nueva variable para confirmar abandono
    
    init(proyecto: Proyecto) {
        self.proyecto = proyecto
        let userID = Auth.auth().currentUser?.uid ?? ""
        _viewModel = StateObject(wrappedValue: DetalleProyectoViewModel(userID: userID))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
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
                    // Sección 1: Nombre del Proyecto
                    Section {
                        Text(proyecto.nombre)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    // Sección 2: Información del Proyecto
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
                            Text(proyecto.tipoColaboracion)
                            
                            Text("Estado:")
                                .fontWeight(.semibold)
                            Text(viewModel.estadoProyecto)
                                .foregroundColor(viewModel.estadoProyecto == "Abierto" ? .green : .red)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Sección 3: Información del Creador
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
                    
                    // Sección 4: Acciones de Participación
                    Section {
                        if !viewModel.yaSolicitado {
                            Button(action: {
                                showSolicitudModal = true
                            }) {
                                Text("Solicitar Participación")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.blue)
                        } else {
                            if viewModel.soyParticipante {
                                VStack(spacing: 8) {
                                    Text("Solicitud Aprobada")
                                        .foregroundColor(.green)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    Button(action: {
                                        // En lugar de ejecutar directamente, mostramos el alert de confirmación
                                        showAbandonConfirmation = true
                                    }) {
                                        Text("Abandonar Proyecto")
                                            .font(.headline)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.red)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                            } else {
                                if viewModel.estadoSolicitud == "Rechazada" {
                                    Text("Solicitud Rechazada")
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    Text("Solicitud Pendiente")
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                        }
                    }
                    
                    // Sección 5: Lista de Participantes
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
                    
                    // Sección 6: Mensaje de error (si existe)
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
        .fullScreenCover(isPresented: $showSolicitudModal) {
            SolicitudModalView(proyectoID: proyecto.id) { mensaje in
                Task {
                    await viewModel.solicitarParticipacion(proyectoID: proyecto.id, mensaje: mensaje)
                }
            }
        }
        .alert("Confirmar abandono", isPresented: $showAbandonConfirmation) {
            Button("Abandonar", role: .destructive) {
                Task {
                    await viewModel.abandonarProyecto(proyectoID: proyecto.id)
                    await viewModel.obtenerDatosAdicionales(proyectoID: proyecto.id)
                    await viewModel.fetchParticipantes(proyectoID: proyecto.id)
                    await viewModel.fetchSolicitudEstado(proyectoID: proyecto.id)
                }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("¿Estás seguro de que deseas abandonar este proyecto?")
        }
        .task {
            await viewModel.obtenerDatosAdicionales(proyectoID: proyecto.id)
            await viewModel.fetchParticipantes(proyectoID: proyecto.id)
            await viewModel.fetchSolicitudEstado(proyectoID: proyecto.id)
        }
    }
}
