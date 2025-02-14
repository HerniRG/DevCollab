import SwiftUI
import FirebaseAuth

struct DetalleProyectoCreadorView: View {
    let proyecto: Proyecto
    @StateObject private var viewModel: DetalleProyectoViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Estados para la solicitud seleccionada
    @State private var selectedSolicitud: Solicitud? = nil
    @State private var selectedUsuario: Usuario? = nil
    @State private var showSolicitudDetail = false
    
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
                    // Nueva sección: Título del Proyecto
                    Section {
                        Text(proyecto.nombre)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
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
                    
                    // Sección 2: Gestión del estado del proyecto
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
                    
                    // Sección 3: Gestión de solicitudes
                    Section("Solicitudes de Participación") {
                        if viewModel.solicitudesPendientes.isEmpty {
                            Text("No hay solicitudes pendientes.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.solicitudesPendientes, id: \.id) { solicitud in
                                // Resumen de la solicitud: mostramos el nombre del usuario con UserNameView y el mensaje.
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
                                                Text("Usuario:")
                                                    .fontWeight(.semibold)
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
                    
                    // Sección 4: Participantes aprobados
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
                    
                    // Sección 5: Opción para eliminar el proyecto (si está cerrado)
                    if viewModel.estadoProyecto == "Cerrado" {
                        Section {
                            Button(action: {
                                Task {
                                    await viewModel.eliminarProyecto(proyecto: proyecto)
                                    if viewModel.errorMessage == nil {
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
                    
                    // Sección 6: Mensaje de error
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
            SolicitudDetailModalContainerView(selectedSolicitud: $selectedSolicitud,
                                              selectedUsuario: $selectedUsuario) { decision in
                print("onDecision llamado con decision: \(decision)")
                Task {
                    if let solicitud = selectedSolicitud {
                        if decision {
                            let nuevoEstado = "Aceptada"
                            await viewModel.actualizarEstadoSolicitud(solicitudID: solicitud.id, estado: nuevoEstado)
                            await viewModel.agregarParticipante(solicitud: solicitud)
                        } else {
                            let nuevoEstado = "Rechazada"
                            await viewModel.actualizarEstadoSolicitud(solicitudID: solicitud.id, estado: nuevoEstado)
                        }
                        await viewModel.fetchSolicitudesPorProyecto(proyectoID: proyecto.id)
                        await viewModel.fetchParticipantes(proyectoID: proyecto.id)
                    }
                }
            }
        }
    }
}

// Contenedor para el modal de detalle que muestra un ProgressView mientras se cargan los datos
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

struct UserNameView: View {
    let userID: String
    @State private var nombre: String = ""
    
    var body: some View {
        Text(nombre)
            .opacity(nombre.isEmpty ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: nombre)
            .onAppear {
                Task {
                    // Usamos el repositorio de usuario ya implementado
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

