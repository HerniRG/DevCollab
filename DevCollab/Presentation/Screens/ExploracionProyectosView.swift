import SwiftUI
import FirebaseAuth

struct ExploracionProyectosView: View {
    @StateObject private var viewModel = ProyectosViewModel()
    @State private var userID: String = Auth.auth().currentUser?.uid ?? ""
    // Estado para filtrar proyectos abiertos por lenguaje; nil = sin filtro.
    @State private var selectedLanguage: LenguajeProgramacion? = nil

    var body: some View {
        List {
            // Sección 1: Mis proyectos (creados por el usuario)
            Section("Mis proyectos") {
                let misProyectos = viewModel.proyectos.filter { $0.creadorID == userID }
                if misProyectos.isEmpty {
                    Text("No has creado ningún proyecto.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(misProyectos, id: \.id) { proyecto in
                        NavigationLink(destination: DetalleProyectoCreadorView(proyecto: proyecto)) {
                            ProyectoRowView(proyecto: proyecto)
                        }
                    }
                }
            }
            
            // Sección 2: Proyectos en los que participas (solicitud aceptada)
            Section("Proyectos en los que participas") {
                let proyectosParticipas = viewModel.proyectos.filter { proyecto in
                    proyecto.creadorID != userID && userEstaParticipando(proyecto: proyecto)
                }
                if proyectosParticipas.isEmpty {
                    Text("No participas en ningún proyecto.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(proyectosParticipas, id: \.id) { proyecto in
                        NavigationLink(destination: DetalleProyectoParticipanteView(proyecto: proyecto)) {
                            ProyectoRowView(proyecto: proyecto)
                        }
                    }
                }
            }
            
            // Sección 3: Proyectos Abiertos (no creados por el usuario, estado "Abierto", sin participación)
            Section("Proyectos Abiertos") {
                // Fila de filtro interno en la sección
                HStack {
                    Text("Filtrar por Lenguaje:")
                        .font(.caption)
                    Spacer()
                    Menu {
                        Button("Todos", action: { selectedLanguage = nil })
                        ForEach(LenguajeProgramacion.allCases, id: \.self) { lenguaje in
                            Button(lenguaje.rawValue) {
                                selectedLanguage = lenguaje
                            }
                        }
                    } label: {
                        Label(selectedLanguage?.rawValue ?? "Todos", systemImage: "line.horizontal.3.decrease.circle")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 4)
                
                // Lista de proyectos abiertos filtrados
                let proyectosAbiertos = viewModel.proyectos.filter { proyecto in
                    proyecto.creadorID != userID &&
                    proyecto.estado == "Abierto" &&
                    !userEstaParticipando(proyecto: proyecto) &&
                    (selectedLanguage == nil || proyecto.lenguajes.contains { $0 == selectedLanguage! })
                }
                if proyectosAbiertos.isEmpty {
                    Text("No hay proyectos abiertos disponibles.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(proyectosAbiertos, id: \.id) { proyecto in
                        NavigationLink(destination: DetalleProyectoParticipanteView(proyecto: proyecto)) {
                            ProyectoRowView(proyecto: proyecto)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .listSectionSpacing(20)
        .animation(.easeInOut, value: viewModel.proyectos)
        .refreshable {
            viewModel.fetchProyectos()
            viewModel.fetchSolicitudes()
        }
        .overlay {
            if viewModel.proyectos.isEmpty {
                ProgressView("Cargando proyectos...")
                    .padding()
            }
        }
        .task {
            viewModel.fetchProyectos()
            viewModel.fetchSolicitudes()
        }
    }
    
    /// Función auxiliar para determinar si el usuario participa en un proyecto (tiene solicitud aceptada).
    private func userEstaParticipando(proyecto: Proyecto) -> Bool {
        return viewModel.solicitudes.contains { solicitud in
            solicitud.proyectoID == proyecto.id && solicitud.estado == "Aceptada"
        }
    }
}
