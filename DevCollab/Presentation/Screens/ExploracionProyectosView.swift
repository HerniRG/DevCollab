import SwiftUI

struct ExploracionProyectosView: View {
    @ObservedObject var viewModel: ProyectosViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.proyectos, id: \ .id) { proyecto in
                NavigationLink(destination: DetalleProyectoView(proyecto: proyecto)) {
                    ProyectoRowView(proyecto: proyecto)
                }
            }
            .navigationTitle("Proyectos Disponibles")
            .onAppear {
                viewModel.fetchProyectos()
            }
        }
    }
}
