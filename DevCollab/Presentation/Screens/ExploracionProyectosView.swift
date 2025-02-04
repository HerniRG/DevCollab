import SwiftUI

import SwiftUI

struct ExploracionProyectosView: View {
    @StateObject private var viewModel = ProyectosViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.proyectos, id: \.id) { proyecto in
                NavigationLink(destination: DetalleProyectoView(proyecto: proyecto)) {
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
