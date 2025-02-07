import SwiftUI

struct PerfilView: View {
    @ObservedObject var viewModel: PerfilViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let usuario = viewModel.usuario {
                List {
                    Section("Perfil") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(usuario.nombre)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            if let descripcion = usuario.descripcion {
                                Text(descripcion)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if !usuario.lenguajes.isEmpty {
                                Text("Lenguajes: \(usuario.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
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
                .listStyle(InsetGroupedListStyle())
                .listSectionSpacing(20)
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
