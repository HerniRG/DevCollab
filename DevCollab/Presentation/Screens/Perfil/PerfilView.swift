import SwiftUI
import FirebaseAuth

struct PerfilView: View {
    @ObservedObject var viewModel: PerfilViewModel
    
    // Estado para navegación programática a EditarPerfilView
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let usuario = viewModel.usuario {
                List {
                    // Sección de Perfil
                    Section("Perfil") {
                        ZStack(alignment: .topTrailing) {
                            // Contenido principal: Info del usuario
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                            
                            // Botón para editar que activa la navegación programática
                            Button {
                                isEditing = true
                            } label: {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 20, weight: .semibold))
                                    .padding(8)
                            }
                        }
                    }
                    
                    // Sección de Proyectos Creados
                    Section("Mis proyectos creados") {
                        if viewModel.proyectosCreados.isEmpty {
                            Text("No tienes proyectos creados.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.proyectosCreados, id: \.id) { proyecto in
                                if proyecto.estado == "Cerrado" {
                                    ProyectoRowView(proyecto: proyecto, onDelete: {
                                        viewModel.deleteProject(proyecto: proyecto)
                                    })
                                } else {
                                    ProyectoRowView(proyecto: proyecto)
                                }
                            }
                        }
                    }
                    
                    // Sección de Proyectos en los que participas
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
                
                // NavigationLink "oculto" para presentar EditarPerfilView mediante push
                .background(
                    NavigationLink(
                        destination: EditarPerfilView(usuario: usuario, viewModel: viewModel),
                        isActive: $isEditing
                    ) {
                        EmptyView()
                    }
                    .hidden()
                )
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
