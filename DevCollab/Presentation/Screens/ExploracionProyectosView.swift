import SwiftUI
import FirebaseAuth

struct ExploracionProyectosView: View {
    @StateObject private var viewModel = ProyectosViewModel()
    @State private var userID: String = Auth.auth().currentUser?.uid ?? ""
    
    var body: some View {
        List {
            // Sección 1: Mis proyectos
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
            
            // Sección 2: Proyectos en los que participas
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
                let proyectosAbiertos = viewModel.proyectos.filter { proyecto in
                    proyecto.creadorID != userID &&
                    proyecto.estado == "Abierto" &&
                    !userEstaParticipando(proyecto: proyecto)
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
        .task {
            viewModel.fetchProyectos()
            viewModel.fetchSolicitudes()
        }
    }
    
    // Función auxiliar para determinar si el usuario participa en un proyecto.
    private func userEstaParticipando(proyecto: Proyecto) -> Bool {
        // Aquí se asume que viewModel.solicitudes ya contiene las solicitudes del usuario.
        return viewModel.solicitudes.contains { solicitud in
            solicitud.proyectoID == proyecto.id && solicitud.estado == "Aceptada"
        }
    }
}
