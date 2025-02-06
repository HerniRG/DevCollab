import SwiftUI

struct MainTabView: View {
    @StateObject var authViewModel = ViewModelProvider.shared.authViewModel
    @State private var isLoading = true // 🔥 Estado de carga inicial

    var body: some View {
        Group {
            if isLoading {
                // 🔥 Nueva pantalla de carga personalizada
                LoadingView()
            } else if authViewModel.user != nil {
                // 🔹 Usuario autenticado: Muestra la app
                NavigationView {
                    TabView {
                        ExploracionProyectosView()
                            .tabItem {
                                Label("Explorar", systemImage: "magnifyingglass")
                            }

                        CrearProyectoView(viewModel: ViewModelProvider.shared.crearProyectoViewModel)
                            .tabItem {
                                Label("Crear Proyecto", systemImage: "plus.circle")
                            }

                        PerfilView(viewModel: ViewModelProvider.shared.perfilViewModel)
                            .tabItem {
                                Label("Perfil", systemImage: "person.crop.circle")
                            }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                authViewModel.logout()
                            }) {
                                Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        }
                    }
                    .navigationTitle("DevCollab")
                }
            } else {
                // 🔹 Si no hay sesión, muestra el login
                AuthMainView(viewModel: authViewModel)
            }
        }
        .task {
            // ✅ Esperar la verificación de sesión antes de actualizar la UI
            await authViewModel.fetchCurrentUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}
