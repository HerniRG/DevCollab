import SwiftUI

struct PerfilView: View {
    @ObservedObject var viewModel: PerfilViewModel
    @State private var isEditing = false
    
    var body: some View {
        Group {
            if let usuario = viewModel.usuario {
                List {
                    // MARK: - Sección: Perfil
                    Section {
                        ZStack(alignment: .topTrailing) {
                            VStack(alignment: .leading, spacing: 8) {
                                // Nombre del usuario
                                Text(usuario.nombre)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                // Descripción del usuario
                                if let descripcion = usuario.descripcion {
                                    Text(descripcion)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                // Lenguajes del usuario
                                if !usuario.lenguajes.isEmpty {
                                    Text("Lenguajes: \(usuario.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                            
                            // Botón de editar (activar vista EditarPerfilView)
                            Button {
                                isEditing = true
                            } label: {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 20, weight: .semibold))
                                    .padding(8)
                            }
                        }
                    } header: {
                        Text("Perfil")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    // MARK: - Sección: Mis proyectos creados
                    Section {
                        if viewModel.proyectosCreados.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "doc.badge.plus")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("No tienes proyectos creados.")
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 12)
                        } else {
                            ForEach(viewModel.proyectosCreados, id: \.id) { proyecto in
                                // Si el proyecto está cerrado, se permite borrar con onDelete
                                if proyecto.estado == "Cerrado" {
                                    ProyectoRowView(
                                        proyecto: proyecto,
                                        onDelete: {
                                            viewModel.deleteProject(proyecto: proyecto)
                                        }
                                    )
                                } else {
                                    ProyectoRowView(proyecto: proyecto)
                                }
                            }
                        }
                    } header: {
                        Text("Mis proyectos creados")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    // MARK: - Sección: Proyectos en los que participas
                    Section {
                        if viewModel.proyectosParticipando.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "person.2.circle")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("No participas en ningún proyecto.")
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 12)
                        } else {
                            ForEach(viewModel.proyectosParticipando, id: \.id) { proyecto in
                                ProyectoRowView(proyecto: proyecto)
                            }
                        }
                    } header: {
                        Text("Proyectos en los que participas")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    // MARK: - Sección: Cerrar sesión
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
                // Recargamos el perfil si fuera necesario:
                .onAppear {
                    viewModel.fetchUserProfile()
                }
                
            } else {
                // MARK: - Estado de carga
                VStack {
                    Spacer()
                    ProgressView("Cargando perfil...")
                    Spacer()
                }
                .onAppear {
                    viewModel.fetchUserProfile()
                }
            }
        }
    }
}
