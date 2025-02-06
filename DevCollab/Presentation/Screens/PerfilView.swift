import SwiftUI

struct PerfilView: View {
    @ObservedObject var viewModel: PerfilViewModel
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                
                if let usuario = viewModel.usuario {
                    // Información principal del usuario
                    VStack(alignment: .leading, spacing: 8) {
                        Text(usuario.nombre)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Lenguajes: \(usuario.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // LISTA con secciones para proyectos
                    List {
                        Section("Proyectos Creados") {
                            if viewModel.proyectosCreados.isEmpty {
                                Text("No tienes proyectos creados.")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(viewModel.proyectosCreados, id: \.id) { proyecto in
                                    ProyectoRowView(proyecto: proyecto)
                                }
                            }
                        }
                        
                        Section("Proyectos en los que participas") {
                            if viewModel.proyectosParticipando.isEmpty {
                                Text("No participas en ningún proyecto.")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(viewModel.proyectosParticipando, id: \.id) { proyecto in
                                    ProyectoRowView(proyecto: proyecto)
                                }
                            }
                        }
                    }
                    
                } else {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView("Cargando perfil...")
                        Spacer()
                    }
                    Spacer()
                }
            }
            .onAppear {
                viewModel.fetchUserProfile()
            }
        }
    }
}
