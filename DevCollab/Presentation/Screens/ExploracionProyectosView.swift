import SwiftUI
import FirebaseAuth

struct ExploracionProyectosView: View {
    // Usa el shared ProyectosViewModel
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
                        text: "No has creado ningún proyecto."
                    )
                } else {
                    ForEach(misProyectos, id: \.id) { proyecto in
                        let tieneSolicitudPendiente = viewModel.solicitudesPendientesPorProyecto[proyecto.id]?.isEmpty == false
                        NavigationLink(destination: DetalleProyectoCreadorView(proyecto: proyecto)) {
                            ProyectoRowView(
                                proyecto: proyecto,
                                tieneSolicitudPendiente: tieneSolicitudPendiente
                            )
                            // Indica a VoiceOver qué pasará al pulsar
                            .accessibilityHint("Ver detalles del proyecto creado")
                        }
                    }
                }
            } header: {
                Text("Mis proyectos creados")
                    .font(.headline)
                    .foregroundColor(.primary)
                    // Hace que VoiceOver lo trate como cabecera
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
                        text: "No participas en ningún proyecto."
                    )
                } else {
                    ForEach(proyectosParticipas, id: \.id) { proyecto in
                        NavigationLink(destination: DetalleProyectoParticipanteView(proyecto: proyecto)) {
                            ProyectoRowView(proyecto: proyecto)
                                .accessibilityHint("Ver detalles del proyecto en el que participas")
                        }
                    }
                }
            } header: {
                Text("Proyectos en los que participas")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
            }
            
            // MARK: - Sección: Proyectos Abiertos
            Section {
                // Filtro con VoiceOver optimizado
                HStack {
                    Text("Filtrar por lenguaje:")
                        .font(.subheadline)
                    Spacer()
                    Menu {
                        Button("Todos", action: { selectedLanguage = nil })
                        ForEach(LenguajeProgramacion.allCases, id: \.self) { lenguaje in
                            Button(lenguaje.rawValue) {
                                selectedLanguage = lenguaje
                            }
                        }
                    } label: {
                        Label(
                            selectedLanguage?.rawValue ?? "Todos",
                            systemImage: "line.horizontal.3.decrease.circle"
                        )
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Filtro de lenguaje")
                    .accessibilityHint("Selecciona el lenguaje para filtrar proyectos")
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
                        text: "No hay proyectos abiertos disponibles."
                    )
                } else {
                    ForEach(proyectosAbiertos, id: \.id) { proyecto in
                        NavigationLink(destination: DetalleProyectoParticipanteView(proyecto: proyecto)) {
                            ProyectoRowView(proyecto: proyecto)
                                .accessibilityHint("Ver detalles del proyecto abierto")
                        }
                    }
                }
            } header: {
                Text("Proyectos Abiertos")
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
                    // Puro icono decorativo
                    .accessibilityHidden(true)
                
                Text(text)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    // VoiceOver leerá el texto
                    .accessibilityLabel(text)
            }
            Spacer()
        }
        .padding(.vertical, 16)
    }
}
