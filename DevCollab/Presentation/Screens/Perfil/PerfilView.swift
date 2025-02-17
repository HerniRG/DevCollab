import SwiftUI
import FirebaseAuth

struct PerfilView: View {
    @ObservedObject var viewModel: PerfilViewModel
    @State private var isEditing = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Content
            if let usuario = viewModel.usuario {
                List {
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
                            
                            Button {
                                isEditing = true
                            } label: {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 20, weight: .semibold))
                                    .padding(8)
                            }
                        }
                    }
                    
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
            }
            
            // Toast overlay
            if let toastMsg = viewModel.toastMessage {
                ToastView(message: toastMsg)
                    .padding(.top, 50)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: viewModel.toastMessage)
        .onAppear {
            viewModel.fetchUserProfile()
            if viewModel.toastMessage != nil {
                            // For example:
                            viewModel.toastMessage = nil
                        }
        }
    }
}
