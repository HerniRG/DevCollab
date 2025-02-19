import SwiftUI

struct PerfilView: View {
    @ObservedObject var viewModel: PerfilViewModel
    @State private var isEditing = false
    
    var body: some View {
        
        if let usuario = viewModel.usuario {
            List {
                // Sección: Datos del perfil
                Section("Perfil") {
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(usuario.nombre)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
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
                        
                        // Botón para editar el perfil
                        Button {
                            isEditing = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 20, weight: .semibold))
                                .padding(8)
                        }
                    }
                }
                
                // Sección: Proyectos creados
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
                
                // Sección: Proyectos en los que participas
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
                
                // Sección: Cerrar sesión
                Section {
                    Button(action: {
                        Task {
                            ViewModelProvider.shared.authViewModel.logout()
                        }
                    }) {
                        Text("Cerrar sesión")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                    }
                    // Puedes elegir el color que desees para el fondo, en este ejemplo se usa rojo.
                    .listRowBackground(Color.red)
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            // Navegación a EditarPerfilView
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
            // Loading
            VStack {
                Spacer()
                ProgressView("Cargando perfil...")
                Spacer()
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchUserProfile()
            }
        }
    }
}
