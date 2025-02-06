import SwiftUI

struct PerfilView: View {
    @ObservedObject var viewModel: PerfilViewModel
    
    var body: some View {
        VStack {
            if let usuario = viewModel.usuario {
                Text(usuario.nombre).font(.largeTitle).bold()
                Text("Lenguajes: \(usuario.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
                
                Divider()
                Text("Proyectos Creados").font(.headline)
                List(viewModel.proyectosCreados, id: \ .id) { proyecto in
                    ProyectoRowView(proyecto: proyecto)
                }
                
                Divider()
                Text("Proyectos en los que participas").font(.headline)
                List(viewModel.proyectosParticipando, id: \ .id) { proyecto in
                    ProyectoRowView(proyecto: proyecto)
                }
            } else {
                ProgressView("Cargando perfil...")
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchUserProfile()
        }
    }
}
