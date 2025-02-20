import SwiftUI
import FirebaseAuth

struct DetalleProyectoParticipanteView: View {
    let proyecto: Proyecto
    @StateObject private var viewModel: DetalleProyectoViewModel
    
    @State private var showSolicitudModal = false
    @State private var showAbandonConfirmation = false  // Confirmar abandono
    
    init(proyecto: Proyecto) {
        self.proyecto = proyecto
        let userID = Auth.auth().currentUser?.uid ?? ""
        _viewModel = StateObject(wrappedValue: DetalleProyectoViewModel(userID: userID))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Estado de carga
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Cargando información...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            // MARK: - Contenido principal
            else {
                List {
                    // MARK: - Sección: Nombre del Proyecto
                    Section {
                        Text(proyecto.nombre)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    // MARK: - Sección: Información del Proyecto
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            infoLabel("Descripción:", proyecto.descripcion)
                            infoLabel(
                                "Lenguajes:",
                                proyecto.lenguajes.map { $0.rawValue }.joined(separator: ", ")
                            )
                            infoLabel("Horas semanales:", "\(proyecto.horasSemanales)")
                            infoLabel("Tipo de colaboración:", proyecto.tipoColaboracion)
                            
                            HStack {
                                Text("Estado:").fontWeight(.semibold)
                                Text(viewModel.estadoProyecto)
                                    .foregroundColor(viewModel.estadoProyecto == "Abierto" ? .green : .red)
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Información del Proyecto")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    // MARK: - Sección: Información del Creador
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            creadorRow(label: "Nombre:", value: viewModel.nombreCreador)
                            
                            if !viewModel.descripcionCreador.isEmpty {
                                creadorRow(label: "Descripción:", value: viewModel.descripcionCreador)
                            }
                            
                            if !viewModel.lenguajesCreador.isEmpty {
                                creadorRow(
                                    label: "Lenguajes:",
                                    value: viewModel.lenguajesCreador.joined(separator: ", ")
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Información del Creador")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    // MARK: - Sección: Acciones de Participación
                    Section {
                        if !viewModel.yaSolicitado {
                            // Botón para solicitar participación
                            Button(action: {
                                showSolicitudModal = true
                            }) {
                                Text("Solicitar Participación")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.blue)
                        } else {
                            // Si ya se solicitó
                            if viewModel.soyParticipante {
                                // Participante aprobado
                                VStack(spacing: 8) {
                                    Text("Solicitud Aprobada")
                                        .foregroundColor(.green)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    Button(action: {
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
                                // Solicitud rechazada o pendiente
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
                    
                    // MARK: - Sección: Lista de participantes
                    Section {
                        if viewModel.participantes.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "person.3")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("No hay participantes aprobados.")
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)
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
                    } header: {
                        Text("Participantes")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    // MARK: - Sección: Mensaje de error (si existe)
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
            }
        }
        // MARK: - Modal para solicitar participación
        .fullScreenCover(isPresented: $showSolicitudModal) {
            SolicitudModalView(proyectoID: proyecto.id) { mensaje in
                Task {
                    await viewModel.solicitarParticipacion(proyectoID: proyecto.id, mensaje: mensaje)
                }
            }
        }
        // MARK: - Alerta para abandonar proyecto
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
        // MARK: - Carga inicial de datos
        .task {
            await viewModel.obtenerDatosAdicionales(proyectoID: proyecto.id)
            await viewModel.fetchParticipantes(proyectoID: proyecto.id)
            await viewModel.fetchSolicitudEstado(proyectoID: proyecto.id)
        }
    }
}

// MARK: - Helper genérico para mostrar campos con su etiqueta
private func infoLabel(_ title: String, _ content: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
        Text(title).fontWeight(.semibold)
        Text(content)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Helper para presentar la info del creador con label + valor
private func creadorRow(label: String, value: String) -> some View {
    HStack(alignment: .top) {
        Text(label).fontWeight(.semibold)
        Spacer()
        Text(value)
            .multilineTextAlignment(.trailing)
    }
}
