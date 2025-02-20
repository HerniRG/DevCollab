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
                    ProgressView("Cargando información...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Accesibilidad para el estado de carga
                .accessibilityElement()
                .accessibilityLabel("Cargando información del proyecto")
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
                            .accessibilityLabel("Nombre del proyecto: \(proyecto.nombre)")
                    }
                    
                    // MARK: - Sección: Información del proyecto
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
                                    .accessibilityLabel("Estado del proyecto: \(viewModel.estadoProyecto)")
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Información del Proyecto")
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
                            Text(viewModel.estadoProyecto == "Abierto"
                                 ? "Cerrar Proyecto"
                                 : "Reabrir Proyecto")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(
                            viewModel.estadoProyecto == "Abierto" ? Color.red : Color.green
                        )
                        .accessibilityLabel(viewModel.estadoProyecto == "Abierto"
                                            ? "Cerrar proyecto"
                                            : "Reabrir proyecto")
                        .accessibilityHint("Cambia el estado del proyecto")
                    }
                    
                    // MARK: - Sección: Solicitudes pendientes
                    Section {
                        if viewModel.solicitudesPendientes.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "envelope.badge")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                        .accessibilityHidden(true)
                                    Text("No hay solicitudes pendientes.")
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .accessibilityLabel("No hay solicitudes pendientes")
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)
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
                                                Text("Usuario:").fontWeight(.semibold)
                                                UserNameView(userID: solicitud.usuarioID)
                                            }
                                            Text("Mensaje: \(solicitud.mensaje ?? "Sin mensaje")")
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
                                .accessibilityLabel("Solicitud de participación")
                                .accessibilityHint("Ver detalles de la solicitud")
                            }
                        }
                    } header: {
                        Text("Solicitudes de Participación")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
                    }
                    
                    // MARK: - Sección: Participantes
                    Section {
                        if viewModel.participantes.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "person.3")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                        .accessibilityHidden(true)
                                    Text("No hay participantes aprobados.")
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .accessibilityLabel("No hay participantes aprobados")
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
                                .accessibilityLabel(
                                    "Participante: \(participante.nombre). Lenguajes: \(participante.lenguajes.map { $0.rawValue }.joined(separator: ", "))"
                                )
                            }
                        }
                    } header: {
                        Text("Participantes")
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
                                Text("Eliminar Proyecto")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.red)
                            .accessibilityLabel("Eliminar proyecto")
                            .accessibilityHint("Borra permanentemente este proyecto")
                        }
                    }
                    
                    // MARK: - Sección: Errores (si los hay)
                    if let error = viewModel.errorMessage, !error.isEmpty {
                        Section {
                            Text(error)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .accessibilityLabel("Error: \(error)")
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
        .alert("Confirmar eliminación", isPresented: $showingDeleteConfirmation) {
            Button("Eliminar", role: .destructive) {
                Task {
                    await viewModel.eliminarProyecto(proyecto: proyecto)
                    if viewModel.errorMessage == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("¿Estás seguro de que deseas eliminar este proyecto? Esta acción no se puede deshacer.")
        }
    }
}

// MARK: - Helper para mostrar un label con un título en negrita y el contenido
private func infoLabel(_ title: String, _ content: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
        Text(title)
            .fontWeight(.semibold)
        Text(content)
            .fixedSize(horizontal: false, vertical: true)
            // Accesibilidad: Unifica el contenido para VoiceOver
            .accessibilityLabel("\(title) \(content)")
    }
}

// MARK: - SolicitudDetailModalContainerView (igual que tu código original)
struct SolicitudDetailModalContainerView: View {
    @Binding var selectedSolicitud: Solicitud?
    @Binding var selectedUsuario: Usuario?
    var onDecision: (Bool) -> Void
    
    var body: some View {
        if let solicitud = selectedSolicitud, let usuario = selectedUsuario {
            SolicitudDetailModalView(solicitud: solicitud, usuario: usuario, onDecision: onDecision)
        } else {
            VStack {
                ProgressView("Cargando detalles...")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
            .accessibilityElement()
            .accessibilityLabel("Cargando detalles de la solicitud")
        }
    }
}

// MARK: - UserNameView (igual que tu código original)
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
