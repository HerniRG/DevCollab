import SwiftUI
import FirebaseAuth

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
                                    .accessibilityLabel("Nombre de usuario: \(usuario.nombre)")
                                    .accessibilityHint("Este es tu nombre de perfil")
                                
                                // Descripción del usuario (si existe)
                                if let descripcion = usuario.descripcion {
                                    Text(descripcion)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .accessibilityLabel("Descripción: \(descripcion)")
                                }
                                
                                // Lenguajes del usuario
                                if !usuario.lenguajes.isEmpty {
                                    Text("Lenguajes: \(usuario.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .accessibilityLabel(
                                            "Lenguajes: \(usuario.lenguajes.map { $0.rawValue }.joined(separator: ", "))"
                                        )
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
                            .accessibilityLabel("Editar perfil")
                            .accessibilityHint("Abre la pantalla de edición de tu perfil")
                        }
                    } header: {
                        Text("Perfil")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
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
                                        .accessibilityHidden(true)
                                    
                                    Text("No tienes proyectos creados.")
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .accessibilityLabel("No tienes proyectos creados")
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
                                    .accessibilityHint("Proyecto cerrado, puedes borrarlo con un deslizamiento o pulsando el botón eliminar")
                                } else {
                                    ProyectoRowView(proyecto: proyecto)
                                }
                            }
                        }
                    } header: {
                        Text("Mis proyectos creados")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
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
                                        .accessibilityHidden(true)
                                    
                                    Text("No participas en ningún proyecto.")
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .accessibilityLabel("No participas en ningún proyecto")
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
                            .accessibilityAddTraits(.isHeader)
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
                        .accessibilityLabel("Cerrar sesión")
                        .accessibilityHint("Se cerrará tu sesión en la aplicación")
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
                // Actualiza el perfil al aparecer
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
                .accessibilityElement()
                .accessibilityLabel("Cargando el perfil del usuario")
                .onAppear {
                    viewModel.fetchUserProfile()
                }
            }
        }
    }
}
