import SwiftUI
import FirebaseAuth

struct PerfilView: View {
    @ObservedObject var viewModel: PerfilViewModel
    @State private var isEditing = false
    @State private var showDeleteSheet = false
    @State private var password = ""
    @State private var usuarioParaEditar: Usuario?
    
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
                                    .accessibilityLabel(
                                        String(
                                            format: NSLocalizedString("profile_user_name", comment: "Nombre de usuario con formato: %@"),
                                            usuario.nombre
                                        )
                                    )
                                    .accessibilityHint(NSLocalizedString("profile_user_name_hint", comment: "Este es tu nombre de perfil"))
                                
                                // Descripción del usuario (si existe)
                                if let descripcion = usuario.descripcion {
                                    Text(descripcion)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .accessibilityLabel(
                                            String(
                                                format: NSLocalizedString("profile_user_description", comment: "Descripción del usuario: %@"),
                                                descripcion
                                            )
                                        )
                                }
                                
                                // Lenguajes del usuario
                                if !usuario.lenguajes.isEmpty {
                                    let lenguajesTexto = usuario.lenguajes
                                        .map { NSLocalizedString($0.rawValue, comment: "Nombre del lenguaje") }
                                        .joined(separator: ", ")
                                    
                                    Text(String(format: NSLocalizedString("profile_user_languages", comment: "Lenguajes: %@"), lenguajesTexto))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .accessibilityLabel(String(format: NSLocalizedString("profile_user_languages_accessibility", comment: "Lenguajes con formato: %@"), lenguajesTexto))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                            
                            // Botón de editar (activar vista EditarPerfilView)
                            Button {
                                usuarioParaEditar = usuario
                            } label: {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 20, weight: .semibold))
                                    .padding(8)
                            }
                            .accessibilityLabel(NSLocalizedString("edit_profile_button", comment: "Editar perfil"))
                            .accessibilityHint(NSLocalizedString("edit_profile_button_hint", comment: "Abre la pantalla de edición de tu perfil"))
                        }
                    } header: {
                        Text(NSLocalizedString("profile_section_header", comment: "Encabezado: Perfil"))
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
                                    
                                    Text(NSLocalizedString("profile_no_created_projects", comment: "No tienes proyectos creados."))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .accessibilityLabel(NSLocalizedString("profile_no_created_projects_accessibility", comment: "No tienes proyectos creados"))
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
                                    .accessibilityHint(NSLocalizedString("closed_project_delete_hint", comment: "Proyecto cerrado, puedes eliminarlo"))
                                } else {
                                    ProyectoRowView(proyecto: proyecto)
                                }
                            }
                        }
                    } header: {
                        Text(NSLocalizedString("profile_created_projects_header", comment: "Mis proyectos creados"))
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
                                    
                                    Text(NSLocalizedString("profile_no_participations", comment: "No participas en ningún proyecto."))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .accessibilityLabel(NSLocalizedString("profile_no_participations_accessibility", comment: "No participas en ningún proyecto"))
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
                        Text(NSLocalizedString("profile_participations_header", comment: "Proyectos en los que participas"))
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
                    }
                    
                    // MARK: - Sección: Cerrar sesión
                    Section {
                        Button(action: {
                            Task {
                                await ViewModelProvider.shared.authContainerVM.loginVM.logout()
                            }
                        }) {
                            Text(NSLocalizedString("logout_button", comment: "Cerrar sesión"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                        }
                        .accessibilityLabel(NSLocalizedString("logout_button_accessibility", comment: "Cerrar sesión"))
                        .accessibilityHint(NSLocalizedString("logout_button_hint", comment: "Se cerrará tu sesión en la aplicación"))
                        .listRowBackground(Color.red)
                    }
                    
                    // 🔴 Sección: Eliminar cuenta
                    Section {
                        Button(role: .destructive) {
                            showDeleteSheet = true
                        } label: {
                            Text(NSLocalizedString("delete_account_confirm", comment: "Eliminar cuenta"))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .accessibilityLabel(NSLocalizedString("delete_account_confirm", comment: "Eliminar cuenta"))
                        .accessibilityHint(NSLocalizedString("delete_account_message", comment: "Eliminará todos tus datos de la app"))
                        .listRowBackground(Color.red.opacity(0.1))
                    }
                }
                .listStyle(InsetGroupedListStyle())
                // Navegación a EditarPerfilView
                .navigationDestination(item: $usuarioParaEditar) { usuario in
                    EditarPerfilView(usuario: usuario, viewModel: viewModel)
                }
                // Actualiza el perfil al aparecer
                .onAppear {
                    viewModel.fetchUserProfile()
                }
            } else {
                // MARK: - Estado de carga
                VStack {
                    Spacer()
                    ProgressView(NSLocalizedString("loading_profile", comment: "Cargando perfil..."))
                    Spacer()
                }
                .accessibilityElement()
                .accessibilityLabel(NSLocalizedString("loading_profile_accessibility", comment: "Cargando el perfil del usuario"))
                .onAppear {
                    viewModel.fetchUserProfile()
                }
            }
        }
        .sheet(isPresented: $showDeleteSheet) {
            DeleteAccountView(viewModel: viewModel, showDeleteSheet: $showDeleteSheet)
        }
    }
}

struct DeleteAccountView: View {
    @ObservedObject var viewModel: PerfilViewModel
    @Binding var showDeleteSheet: Bool
    @State private var password: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text(NSLocalizedString("delete_account_message", comment: "Esta acción eliminará tu cuenta y todos tus datos. No podrás recuperarlos."))
                    .multilineTextAlignment(.center)
                    .padding()

                SecureField(NSLocalizedString("password_placeholder", comment: "Introduce tu contraseña"), text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(role: .destructive) {
                    Task {
                        try await ViewModelProvider.shared.authContainerVM.loginVM.authRepository.deleteAccount(password: password)
                        showDeleteSheet = false
                        DispatchQueue.main.async {
                            ViewModelProvider.shared.authContainerVM.user = nil
                        }
                    }
                } label: {
                    Text(NSLocalizedString("delete_account_confirm", comment: "Eliminar cuenta"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)

                Button {
                    showDeleteSheet = false
                } label: {
                    Text(NSLocalizedString("delete_account_cancel", comment: "Cancelar"))
                }
                .padding(.top, 10)

                Spacer()
            }
            .navigationTitle(NSLocalizedString("delete_account_title", comment: "¿Eliminar cuenta?"))
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }
}
