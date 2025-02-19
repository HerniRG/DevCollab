import SwiftUI
import FirebaseAuth

struct DetalleProyectoCreadorView: View {
    let proyecto: Proyecto
    @StateObject private var viewModel: DetalleProyectoViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSolicitud: Solicitud? = nil
    @State private var selectedUsuario: Usuario? = nil
    @State private var showSolicitudDetail = false
    
    // Nuevo estado para controlar la alerta de confirmación de eliminación
    @State private var showingDeleteConfirmation = false
    
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
                    Section {
                        Text(proyecto.nombre)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    Section("Información del Proyecto") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción:").fontWeight(.semibold)
                            Text(proyecto.descripcion)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("Lenguajes:").fontWeight(.semibold)
                            Text(proyecto.lenguajes.map { $0.rawValue }.joined(separator: ", "))
                            
                            Text("Horas semanales:").fontWeight(.semibold)
                            Text("\(proyecto.horasSemanales)")
                            
                            Text("Tipo de colaboración:").fontWeight(.semibold)
                            Text(proyecto.tipoColaboracion)
                            
                            Text("Estado:").fontWeight(.semibold)
                            Text(viewModel.estadoProyecto)
                                .foregroundColor(viewModel.estadoProyecto == "Abierto" ? .green : .red)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Section {
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
                    
                    Section("Solicitudes de Participación") {
                        if viewModel.solicitudesPendientes.isEmpty {
                            Text("No hay solicitudes pendientes.")
                                .foregroundColor(.gray)
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
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    
                    Section("Participantes") {
                        if viewModel.participantes.isEmpty {
                            Text("No hay participantes aprobados.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.participantes, id: \.id) { participante in
                                HStack {
                                    Text(participante.nombre).fontWeight(.semibold)
                                    if !participante.lenguajes.isEmpty {
                                        Text("(\(participante.lenguajes.map { $0.rawValue }.joined(separator: ", ")))")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    
                    if viewModel.estadoProyecto == "Cerrado" {
                        Section {
                            Button(action: {
                                // Mostrar la alerta de confirmación
                                showingDeleteConfirmation = true
                            }) {
                                Text("Eliminar Proyecto")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.red)
                        }
                    }
                    
                    // Sección para mostrar errores (si los hay)
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
            await viewModel.fetchSolicitudesPorProyecto(proyectoID: proyecto.id)
        }
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
        .alert("Confirmar eliminación", isPresented: $showingDeleteConfirmation) {
            Button("Eliminar", role: .destructive) {
                Task {
                    await viewModel.eliminarProyecto(proyecto: proyecto)
                    if viewModel.errorMessage == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("¿Estás seguro de que deseas eliminar este proyecto? Esta acción no se puede deshacer.")
        }
    }
}

// MARK: - SolicitudDetailModalContainerView (sin cambios)
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
        }
    }
}

// MARK: - Simple UserNameView (sin cambios)
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
