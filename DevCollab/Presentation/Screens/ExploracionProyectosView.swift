import SwiftUI
import FirebaseAuth

struct ExploracionProyectosView: View {
    @StateObject private var viewModel = ViewModelProvider.shared.proyectosViewModel
    @State private var userID: String = Auth.auth().currentUser?.uid ?? ""
    @State private var selectedLanguage: LenguajeProgramacion? = nil
    
    var body: some View {
        List {
            // MARK: - Sección: Mis proyectos creados
            Section {
                let misProyectos = viewModel.proyectos.filter { $0.creadorID == userID }
                if misProyectos.isEmpty {
                    emptyStateView(
                        icon: "doc.badge.plus",
                        text: NSLocalizedString("explorar_no_created_projects", comment: "No has creado ningún proyecto.")
                    )
                } else {
                    ForEach(misProyectos, id: \.id) { proyecto in
                        let tieneSolicitudPendiente = viewModel.solicitudesPendientesPorProyecto[proyecto.id]?.isEmpty == false
                        NavigationLink(destination: DetalleProyectoCreadorView(proyecto: proyecto)) {
                            ProyectoRowView(
                                proyecto: proyecto,
                                tieneSolicitudPendiente: tieneSolicitudPendiente
                            )
                            // VoiceOver: qué pasará al pulsar
                            .accessibilityHint(NSLocalizedString("explorar_created_project_hint", comment: "Ver detalles del proyecto creado"))
                        }
                    }
                }
            } header: {
                Text(NSLocalizedString("explorar_created_projects_header", comment: "Mis proyectos creados"))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
            }
            
            // MARK: - Sección: Proyectos en los que participas
            Section {
                let proyectosParticipas = viewModel.proyectos.filter { proyecto in
                    proyecto.creadorID != userID && userEstaParticipando(proyecto: proyecto)
                }
                if proyectosParticipas.isEmpty {
                    emptyStateView(
                        icon: "person.2.circle",
                        text: NSLocalizedString("explorar_no_participation", comment: "No participas en ningún proyecto.")
                    )
                } else {
                    ForEach(proyectosParticipas, id: \.id) { proyecto in
                        NavigationLink(destination: DetalleProyectoParticipanteView(proyecto: proyecto)) {
                            ProyectoRowView(proyecto: proyecto)
                                .accessibilityHint(NSLocalizedString("explorar_participation_project_hint", comment: "Ver detalles del proyecto en el que participas"))
                        }
                    }
                }
            } header: {
                Text(NSLocalizedString("explorar_participation_header", comment: "Proyectos en los que participas"))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
            }
            
            // MARK: - Sección: Proyectos Abiertos
            Section {
                // Filtro por lenguaje
                HStack {
                    Text(NSLocalizedString("explorar_filter_language_label", comment: "Filtrar por lenguaje:"))
                        .font(.subheadline)
                    Spacer()
                    Menu {
                        Button(NSLocalizedString("explorar_filter_language_all", comment: "Todos"), action: { selectedLanguage = nil })
                        ForEach(LenguajeProgramacion.allCases, id: \.self) { lenguaje in
                            Button(lenguaje.rawValue) {
                                selectedLanguage = lenguaje
                            }
                        }
                    } label: {
                        Label(
                            selectedLanguage?.rawValue ?? NSLocalizedString("explorar_filter_language_all", comment: "Todos"),
                            systemImage: "line.horizontal.3.decrease.circle"
                        )
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    .accessibilityLabel(NSLocalizedString("explorar_filter_language_accessibility", comment: "Filtro de lenguaje"))
                    .accessibilityHint(NSLocalizedString("explorar_filter_language_hint", comment: "Selecciona el lenguaje para filtrar proyectos"))
                }
                .padding(.vertical, 4)
                
                let proyectosAbiertos = viewModel.proyectos.filter { proyecto in
                    proyecto.creadorID != userID &&
                    proyecto.estado == "Abierto" &&
                    !userEstaParticipando(proyecto: proyecto) &&
                    (selectedLanguage == nil || proyecto.lenguajes.contains(selectedLanguage!))
                }
                
                if proyectosAbiertos.isEmpty {
                    emptyStateView(
                        icon: "rectangle.stack.badge.person.crop",
                        text: NSLocalizedString("explorar_no_open_projects", comment: "No hay proyectos abiertos disponibles.")
                    )
                } else {
                    ForEach(proyectosAbiertos, id: \.id) { proyecto in
                        NavigationLink(destination: DetalleProyectoParticipanteView(proyecto: proyecto)) {
                            ProyectoRowView(proyecto: proyecto)
                                .accessibilityHint(NSLocalizedString("explorar_open_project_hint", comment: "Ver detalles del proyecto abierto"))
                        }
                    }
                }
            } header: {
                Text(NSLocalizedString("explorar_open_projects_header", comment: "Proyectos Abiertos"))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .refreshable {
            recargarDatos()
        }
        .onAppear {
            recargarDatos()
        }
        .animation(.easeInOut, value: viewModel.proyectos)
    }
    
    // MARK: - Recarga de datos
    private func recargarDatos() {
        viewModel.fetchProyectos()
        viewModel.fetchSolicitudes()
        viewModel.fetchSolicitudesPendientesParaMisProyectos()
    }
    
    // Comprueba si el usuario participa en el proyecto
    private func userEstaParticipando(proyecto: Proyecto) -> Bool {
        return viewModel.solicitudes.contains { solicitud in
            solicitud.proyectoID == proyecto.id && solicitud.estado == "Aceptada"
        }
    }
    
    // MARK: - Vista de estado vacío
    private func emptyStateView(icon: String, text: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .accessibilityHidden(true)
                
                Text(text)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel(text)
            }
            Spacer()
        }
        .padding(.vertical, 16)
    }
}
