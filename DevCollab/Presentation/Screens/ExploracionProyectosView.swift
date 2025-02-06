import SwiftUI
import FirebaseAuth

struct ExploracionProyectosView: View {
    @StateObject private var viewModel = ProyectosViewModel()
    @State private var userID: String = Auth.auth().currentUser?.uid ?? ""

    var body: some View {
        NavigationView {
            List {
                // Sección principal con el encabezado "Proyectos Disponibles"
                Section(
                    header: Text("Proyectos Disponibles")
                        .font(.headline)
                        .fontWeight(.bold)
                ) {
                    // Subsección: Mis proyectos
                    Section("Mis proyectos") {
                        ForEach(viewModel.proyectos.filter { $0.creadorID == userID }, id: \.id) { proyecto in
                            NavigationLink(destination: DetalleProyectoCreadorView(proyecto: proyecto)) {
                                ProyectoRowView(proyecto: proyecto)
                            }
                        }
                    }
                    
                    // Subsección: Otros proyectos
                    Section("Otros proyectos") {
                        ForEach(viewModel.proyectos.filter { $0.creadorID != userID }, id: \.id) { proyecto in
                            NavigationLink(destination: DetalleProyectoParticipanteView(proyecto: proyecto)) {
                                ProyectoRowView(proyecto: proyecto)
                            }
                        }
                    }
                }
            }
            .task {
                viewModel.fetchProyectos()
            }
        }
    }
}
