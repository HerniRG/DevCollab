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
                    // Estado vacío + pequeño icono
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "doc.badge.plus")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No has creado ningún proyecto.")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 16)
                } else {
                    ForEach(misProyectos, id: \.id) { proyecto in
                        let tieneSolicitudPendiente = viewModel.solicitudesPendientesPorProyecto[proyecto.id]?.isEmpty == false
                        NavigationLink(destination: DetalleProyectoCreadorView(proyecto: proyecto)) {
                            ProyectoRowView(
                                proyecto: proyecto,
                                tieneSolicitudPendiente: tieneSolicitudPendiente
                            )
                        }
                    }
                }
            } header: {
                Text("Mis proyectos creados")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            // MARK: - Sección: Proyectos en los que participas
            Section {
                let proyectosParticipas = viewModel.proyectos.filter { proyecto in
                    proyecto.creadorID != userID && userEstaParticipando(proyecto: proyecto)
                }
                if proyectosParticipas.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "person.2.circle")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No participas en ningún proyecto.")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 16)
                } else {
                    ForEach(proyectosParticipas, id: \.id) { proyecto in
                        NavigationLink(destination: DetalleProyectoParticipanteView(proyecto: proyecto)) {
                            ProyectoRowView(proyecto: proyecto)
                        }
                    }
                }
            } header: {
                Text("Proyectos en los que participas")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            // MARK: - Sección: Proyectos Abiertos
            Section {
                // Filtro
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
                }
                .padding(.vertical, 4)
                
                let proyectosAbiertos = viewModel.proyectos.filter { proyecto in
                    proyecto.creadorID != userID &&
                    proyecto.estado == "Abierto" &&
                    !userEstaParticipando(proyecto: proyecto) &&
                    (selectedLanguage == nil || proyecto.lenguajes.contains(selectedLanguage!))
                }
                if proyectosAbiertos.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "rectangle.stack.badge.person.crop")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No hay proyectos abiertos disponibles.")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 16)
                } else {
                    ForEach(proyectosAbiertos, id: \.id) { proyecto in
                        NavigationLink(destination: DetalleProyectoParticipanteView(proyecto: proyecto)) {
                            ProyectoRowView(proyecto: proyecto)
                        }
                    }
                }
            } header: {
                Text("Proyectos Abiertos")
                    .font(.headline)
                    .foregroundColor(.primary)
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
    
    private func recargarDatos() {
        viewModel.fetchProyectos()
        viewModel.fetchSolicitudes()
        viewModel.fetchSolicitudesPendientesParaMisProyectos()
    }
    
    private func userEstaParticipando(proyecto: Proyecto) -> Bool {
        return viewModel.solicitudes.contains { solicitud in
            solicitud.proyectoID == proyecto.id && solicitud.estado == "Aceptada"
        }
    }
}
