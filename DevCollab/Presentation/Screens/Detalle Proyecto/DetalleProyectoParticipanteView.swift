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
                    ProgressView(NSLocalizedString("loading_info", comment: "Texto de carga"))
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityElement()
                .accessibilityLabel(NSLocalizedString("loading_project_info", comment: "Cargando información del proyecto"))
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
                            .accessibilityLabel(
                                String(format: NSLocalizedString("project_name", comment: "Nombre del proyecto"), proyecto.nombre)
                            )
                    }
                    
                    // MARK: - Sección: Información del Proyecto
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            infoLabel(NSLocalizedString("description", comment: "Descripción"), proyecto.descripcion)
                            
                            infoLabel(
                                NSLocalizedString("languages", comment: "Lenguajes"),
                                proyecto.lenguajes
                                    .map { NSLocalizedString($0.rawValue, comment: "Nombre del lenguaje") }
                                    .joined(separator: ", ")
                            )
                            
                            infoLabel(NSLocalizedString("weekly_hours", comment: "Horas semanales"), "\(proyecto.horasSemanales)")
                            
                            infoLabel(NSLocalizedString("collab_type", comment: "Tipo de colaboración"), proyecto.tipoColaboracion)
                            
                            // Estado
                            HStack {
                                Text(NSLocalizedString("status", comment: "Estado")).fontWeight(.semibold)
                                Text(NSLocalizedString(viewModel.estadoProyecto, comment: "Abierto o Cerrado"))
                                    .foregroundColor(viewModel.estadoProyecto == "Abierto" ? .green : .red)
                                    .accessibilityLabel(
                                        String(format: NSLocalizedString("project_status", comment: "Estado del proyecto"), viewModel.estadoProyecto)
                                    )
                            }
                        }
                        .transition(.opacity)
                        .padding(.vertical, 4)
                    } header: {
                        Text(NSLocalizedString("project_info", comment: "Información del proyecto"))
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
                    }
                    
                    // MARK: - Sección: Información del Creador
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            creadorRow(label: NSLocalizedString("creator_name", comment: "Nombre:"), value: viewModel.nombreCreador)
                                .accessibilityLabel(
                                    String(format: NSLocalizedString("creator_name_accessibility", comment: "Nombre del creador"), viewModel.nombreCreador)
                                )
                            
                            if !viewModel.descripcionCreador.isEmpty {
                                creadorRow(label: NSLocalizedString("creator_description", comment: "Descripción:"), value: viewModel.descripcionCreador)
                                    .accessibilityLabel(
                                        String(format: NSLocalizedString("creator_description_accessibility", comment: "Descripción del creador"), viewModel.descripcionCreador)
                                    )
                            }
                            
                            if !viewModel.lenguajesCreador.isEmpty {
                                let lenguajes = viewModel.lenguajesCreador.map {
                                    NSLocalizedString($0, comment: "Nombre de lenguaje del creador")
                                }.joined(separator: ", ")
                                
                                creadorRow(label: NSLocalizedString("creator_languages", comment: "Lenguajes:"), value: lenguajes)
                                    .accessibilityLabel(
                                        String(format: NSLocalizedString("creator_languages_accessibility", comment: "Lenguajes del creador"), lenguajes)
                                    )
                            }
                        }
                        .transition(.opacity)
                        .padding(.vertical, 4)
                    } header: {
                        Text(NSLocalizedString("creator_info", comment: "Información del Creador"))
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
                    }
                    
                    // MARK: - Sección: Acciones de Participación
                    Section {
                        if !viewModel.yaSolicitado {
                            // Botón para solicitar participación (cuando aún no se ha enviado solicitud)
                            Button(action: {
                                showSolicitudModal = true
                            }) {
                                Text(NSLocalizedString("request_participation", comment: "Solicitar Participación"))
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.blue)
                            .accessibilityLabel(NSLocalizedString("request_participation", comment: "Solicitar participación"))
                            .accessibilityHint(NSLocalizedString("request_participation_hint", comment: "Envía una solicitud al creador"))
                            .transition(.opacity)
                        } else {
                            // Si ya se solicitó
                            if viewModel.soyParticipante {
                                // Participante aprobado
                                VStack(spacing: 8) {
                                    Text(NSLocalizedString("request_approved", comment: "Solicitud Aprobada"))
                                        .foregroundColor(.green)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .accessibilityLabel(NSLocalizedString("request_approved_accessibility", comment: "Tu solicitud ha sido aprobada"))
                                    
                                    Button(action: {
                                        showAbandonConfirmation = true
                                    }) {
                                        Text(NSLocalizedString("abandon_project", comment: "Abandonar Proyecto"))
                                            .font(.headline)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.red)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                    .accessibilityLabel(NSLocalizedString("abandon_project", comment: "Abandonar proyecto"))
                                    .accessibilityHint(NSLocalizedString("abandon_project_hint", comment: "Dejas de participar en este proyecto"))
                                }.transition(.opacity)
                            } else if viewModel.estadoSolicitud == "Abandonado" {
                                // Nuevo: si la solicitud está en estado "Abandonado"
                                Text(NSLocalizedString("request_abandoned", comment: "Has abandonado este proyecto"))
                                    .foregroundColor(.orange)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .accessibilityLabel(NSLocalizedString("request_abandoned_accessibility", comment: "Tu solicitud ha quedado en estado abandonado"))
                            } else {
                                // Caso de solicitud rechazada o pendiente
                                if viewModel.estadoSolicitud == "Rechazada" {
                                    Text(NSLocalizedString("request_rejected", comment: "Solicitud Rechazada"))
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .accessibilityLabel(NSLocalizedString("request_rejected_accessibility", comment: "Tu solicitud ha sido rechazada"))
                                        .transition(.opacity)
                                } else {
                                    Text(NSLocalizedString("request_pending", comment: "Solicitud Pendiente"))
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .accessibilityLabel(NSLocalizedString("request_pending_accessibility", comment: "Tu solicitud está pendiente"))
                                        .transition(.opacity)
                                }
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: viewModel.estadoSolicitud)
                    
                    // MARK: - Sección: Lista de participantes
                    Section {
                        if viewModel.participantes.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "person.3")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                        .accessibilityHidden(true)
                                    Text(NSLocalizedString("no_approved_participants", comment: "No hay participantes aprobados."))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .accessibilityLabel(NSLocalizedString("no_approved_participants_accessibility", comment: "No hay participantes aprobados"))
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
                                        Text("(\(participante.lenguajes.map { NSLocalizedString($0.rawValue, comment: "Nombre de lenguaje") }.joined(separator: ", ")))")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .accessibilityLabel(
                                    String(
                                        format: NSLocalizedString("participant_info", comment: "Participante con lenguajes"),
                                        participante.nombre,
                                        participante.lenguajes.map { NSLocalizedString($0.rawValue, comment: "Nombre de lenguaje") }.joined(separator: ", ")
                                    )
                                )
                            }
                        }
                    } header: {
                        Text(NSLocalizedString("participants", comment: "Participantes"))
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
                    }
                    
                    // MARK: - Sección: Mensaje de error (si existe)
                    if let error = viewModel.errorMessage, !error.isEmpty {
                        Section {
                            Text(error)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .accessibilityLabel(String(format: NSLocalizedString("error_label", comment: "Error con formato"), error))
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
        .alert(NSLocalizedString("confirm_abandon", comment: "Confirmar abandono"), isPresented: $showAbandonConfirmation) {
            Button(NSLocalizedString("abandon", comment: "Abandonar"), role: .destructive) {
                Task {
                    await viewModel.abandonarProyecto(proyectoID: proyecto.id)
                    await viewModel.obtenerDatosAdicionales(proyectoID: proyecto.id)
                    await viewModel.fetchParticipantes(proyectoID: proyecto.id)
                    await viewModel.fetchSolicitudEstado(proyectoID: proyecto.id)
                }
            }
            Button(NSLocalizedString("cancel", comment: "Cancelar"), role: .cancel) { }
        } message: {
            Text(NSLocalizedString("confirm_abandon_message", comment: "¿Estás seguro de que deseas abandonar este proyecto?"))
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
            .accessibilityLabel("\(title) \(content)")
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
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(label) \(value)")
}
