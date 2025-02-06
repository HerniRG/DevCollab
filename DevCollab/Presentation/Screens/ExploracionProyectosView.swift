import SwiftUI
import FirebaseAuth

struct ExploracionProyectosView: View {
    @StateObject private var viewModel = ProyectosViewModel()
    @State private var userID: String = Auth.auth().currentUser?.uid ?? "" // Obtiene el usuario autenticado

    var body: some View {
        NavigationView {
            List(viewModel.proyectos, id: \.id) { proyecto in
                NavigationLink(destination:
                    proyecto.creadorID == userID
                        ? AnyView(DetalleProyectoCreadorView(proyecto: proyecto))
                        : AnyView(DetalleProyectoParticipanteView(proyecto: proyecto))
                ) {
                    ProyectoRowView(proyecto: proyecto)
                }
            }
            .navigationTitle("Proyectos Disponibles")
            .task {
                viewModel.fetchProyectos()
            }
        }
    }
}
