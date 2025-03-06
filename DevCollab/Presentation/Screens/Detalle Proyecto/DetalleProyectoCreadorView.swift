import SwiftUI
import FirebaseAuth

struct DetalleProyectoCreadorView: View {
    let proyecto: Proyecto
    @StateObject private var viewModel: DetalleProyectoViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSolicitud: Solicitud? = nil
    @State private var selectedUsuario: Usuario? = nil
    @State private var showSolicitudDetail = false
    
    // Control para la alerta de confirmación de eliminación
    @State private var showingDeleteConfirmation = false
    
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
                // Accesibilidad para el estado de carga
                .accessibilityElement()
                .accessibilityLabel(NSLocalizedString("loading_project_info", comment: "Cargando información del proyecto"))
            }
            // MARK: - Contenido principal
            else {
                List {
                    // MARK: - Sección: Título del proyecto
                    Section {
                        Text(proyecto.nombre)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .accessibilityLabel(String(format: NSLocalizedString("project_name", comment: "Nombre del proyecto con formato: %@"), proyecto.nombre))
                    }
                    
                    // MARK: - Sección: Información del proyecto
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            infoLabel(NSLocalizedString("description", comment: "Descripción"), proyecto.descripcion)
                            
                            infoLabel(
                                NSLocalizedString("languages", comment: "Lenguajes"),
                                proyecto.lenguajes
                                    .map { NSLocalizedString($0.rawValue, comment: "Nombre de lenguaje") }
                                    .joined(separator: ", ")
                            )
                            
                            infoLabel(NSLocalizedString("weekly_hours", comment: "Horas semanales"), "\(proyecto.horasSemanales)")
                            infoLabel(NSLocalizedString("collab_type", comment: "Tipo de colaboración"), proyecto.tipoColaboracion)
                            
                            HStack {
                                Text(NSLocalizedString("status", comment: "Estado"))
                                    .fontWeight(.semibold)
                                
                                Text(NSLocalizedString(viewModel.estadoProyecto, comment: "Abierto o Cerrado"))
                                    .foregroundColor(viewModel.estadoProyecto == "Abierto" ? .green : .red)
                                    .accessibilityLabel(
                                        String(format: NSLocalizedString("project_status", comment: "Estado del proyecto: %@"),
                                               viewModel.estadoProyecto)
                                    )
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text(NSLocalizedString("project_info", comment: "Información del proyecto"))
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
                    }
                    
                    // MARK: - Sección: Botón para abrir/cerrar proyecto
                    Section {
                        Button(action: {
                            Task {
                                await viewModel.alternarEstadoProyecto(proyectoID: proyecto.id)
                            }
                        }) {
                            Text(NSLocalizedString(viewModel.estadoProyecto == "Abierto" ? "close_project" : "reopen_project", comment: "Botón para cerrar o reabrir proyecto"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(viewModel.estadoProyecto == "Abierto" ? Color.red : Color.green)
                        .accessibilityLabel(NSLocalizedString(viewModel.estadoProyecto == "Abierto" ? "close_project" : "reopen_project", comment: "Cambia el estado del proyecto"))
                        .accessibilityHint(NSLocalizedString("toggle_project_status", comment: "Hint para cambiar estado del proyecto"))
                    }
                    
                    // MARK: - Sección: Solicitudes pendientes
                    Section {
                        if viewModel.solicitudesPendientes.isEmpty {
                            emptyStateView(icon: "envelope.badge", messageKey: "no_pending_requests")
                        } else {
                            ForEach(viewModel.solicitudesPendientes, id: \.id) { solicitud in
                                Button(action: {
                                    Task {
                                        if let usuario = await viewModel.fetchUsuario(for: solicitud) {
                                            await MainActor.run {
                                                selectedUsuario = usuario
                                                selectedSolicitud = solicitud
                                                showSolicitudDetail = true
                                            }
                                        }
                                    }
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(NSLocalizedString("user", comment: "Usuario"))
                                                    .fontWeight(.semibold)
                                                UserNameView(userID: solicitud.usuarioID)
                                            }
                                            
                                            Text(String(
                                                format: NSLocalizedString("message_format", comment: "Mensaje: %@"),
                                                solicitud.mensaje ?? NSLocalizedString("no_message", comment: "Sin mensaje")))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .accessibilityHidden(true)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .accessibilityLabel(NSLocalizedString("participation_request", comment: "Solicitud de participación"))
                                .accessibilityHint(NSLocalizedString("view_request_details", comment: "Ver detalles de la solicitud"))
                            }
                        }
                    } header: {
                        Text(NSLocalizedString("participation_requests", comment: "Solicitudes de participación"))
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
                    }
                    
                    // MARK: - Sección: Participantes
                    Section {
                        if viewModel.participantes.isEmpty {
                            emptyStateView(icon: "person.3", messageKey: "no_approved_participants")
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
                                        format: NSLocalizedString("participant_info", comment: "Información del participante con formato"),
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
                    
                    // MARK: - Sección: Eliminar proyecto si está cerrado
                    if viewModel.estadoProyecto == "Cerrado" {
                        Section {
                            Button(action: {
                                showingDeleteConfirmation = true
                            }) {
                                Text(NSLocalizedString("delete_project_button", comment: "Eliminar proyecto"))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.red)
                            .accessibilityLabel(NSLocalizedString("delete_project", comment: "Eliminar proyecto"))
                            .accessibilityHint(NSLocalizedString("delete_project_hint", comment: "Borra permanentemente el proyecto"))
                        }
                    }
                    
                    // MARK: - Sección: Errores (si los hay)
                    if let error = viewModel.errorMessage, !error.isEmpty {
                        Section {
                            Text(error)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .accessibilityLabel(String(format: NSLocalizedString("error_label", comment: "Error: %@"), error))
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .listSectionSpacing(20)
            }
        }
        // Carga asíncrona y actualización
        .task {
            await viewModel.obtenerDatosAdicionales(proyectoID: proyecto.id)
            await viewModel.fetchParticipantes(proyectoID: proyecto.id)
            await viewModel.fetchSolicitudesPorProyecto(proyectoID: proyecto.id)
        }
        // Modal para ver/gestionar solicitud
        .fullScreenCover(isPresented: $showSolicitudDetail) {
            SolicitudDetailModalContainerView(
                selectedSolicitud: $selectedSolicitud,
                selectedUsuario: $selectedUsuario
            ) { decision in
                Task {
                    if let solicitud = selectedSolicitud {
                        let nuevoEstado = decision ? "Aceptada" : "Rechazada"
                        await viewModel.actualizarEstadoSolicitud(solicitudID: solicitud.id, estado: nuevoEstado)
                        if decision {
                            await viewModel.agregarParticipante(solicitud: solicitud)
                        }
                        await viewModel.fetchSolicitudesPorProyecto(proyectoID: proyecto.id)
                        await viewModel.fetchParticipantes(proyectoID: proyecto.id)
                    }
                }
            }
        }
        // Alerta de confirmación de eliminación
        .alert(NSLocalizedString("confirm_delete", comment: "Confirmar eliminación"), isPresented: $showingDeleteConfirmation) {
            Button(NSLocalizedString("delete", comment: "Eliminar"), role: .destructive) {
                Task {
                    await viewModel.eliminarProyecto(proyecto: proyecto)
                    if viewModel.errorMessage == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            Button(NSLocalizedString("cancel", comment: "Cancelar"), role: .cancel) { }
        } message: {
            Text(NSLocalizedString("confirm_delete_message", comment: "Mensaje de alerta para eliminación"))
        }
    }
}

fileprivate func infoLabel(_ title: String, _ content: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
        Text(title)
            .fontWeight(.semibold)
        Text(content)
            .fixedSize(horizontal: false, vertical: true)
            // Accesibilidad: Unifica el contenido para VoiceOver
            .accessibilityLabel("\(title) \(content)")
    }
}

// MARK: - Vista de estado vacío
fileprivate func emptyStateView(icon: String, messageKey: String) -> some View {
    HStack {
        Spacer()
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.gray)
                .accessibilityHidden(true)
            Text(NSLocalizedString(messageKey, comment: "Texto vacío"))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .accessibilityLabel(NSLocalizedString(messageKey, comment: "Accesibilidad: Estado vacío"))
        }
        Spacer()
    }
    .padding(.vertical, 8)
}

struct SolicitudDetailModalContainerView: View {
    @Binding var selectedSolicitud: Solicitud?
    @Binding var selectedUsuario: Usuario?
    var onDecision: (Bool) -> Void
    
    var body: some View {
        if let solicitud = selectedSolicitud, let usuario = selectedUsuario {
            SolicitudDetailModalView(solicitud: solicitud, usuario: usuario, onDecision: onDecision)
        } else {
            VStack {
                ProgressView(NSLocalizedString("loading_details", comment: "Cargando detalles"))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
            .accessibilityElement()
            .accessibilityLabel(NSLocalizedString("loading_request_details", comment: "Cargando detalles de la solicitud"))
        }
    }
}

struct UserNameView: View {
    let userID: String
    @State private var nombre: String = ""
    
    var body: some View {
        Text(nombre)
            .onAppear {
                Task {
                    let repository = FirebaseUserRepository()
                    if let usuario = try? await repository.obtenerUsuario(usuarioID: userID) {
                        await MainActor.run {
                            self.nombre = usuario.nombre
                        }
                    }
                }
            }
    }
}
