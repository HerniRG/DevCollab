import SwiftUI
import FirebaseAuth

struct ExploracionProyectosView: View {
    // Usa el shared ProyectosViewModel en lugar de crear uno nuevo
    @StateObject private var viewModel = ViewModelProvider.shared.proyectosViewModel
    @State private var userID: String = Auth.auth().currentUser?.uid ?? ""
    @State private var selectedLanguage: LenguajeProgramacion? = nil

    var body: some View {
        List {
            // Sección 1: Mis proyectos creados
            Section("Mis proyectos creados") {
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
            
            // Sección 3: Proyectos Abiertos
            Section("Proyectos Abiertos") {
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
        .onAppear {
            viewModel.fetchProyectos()
            viewModel.fetchSolicitudes()
        }
        .task {
            viewModel.fetchProyectos()
            viewModel.fetchSolicitudes()
        }
    }
    
    private func userEstaParticipando(proyecto: Proyecto) -> Bool {
        return viewModel.solicitudes.contains { solicitud in
            solicitud.proyectoID == proyecto.id && solicitud.estado == "Aceptada"
        }
    }
}
