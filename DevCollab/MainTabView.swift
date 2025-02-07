import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @StateObject var authViewModel = ViewModelProvider.shared.authViewModel
    @State private var isLoading = true // Estado de carga inicial
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else if authViewModel.user != nil {
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
                    // Título centralizado en la barra de navegación
                    .navigationBarTitle("DevCollab", displayMode: .inline)
                    // Botón de "Cerrar sesión"
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                authViewModel.logout()
                            }) {
                                Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        }
                    }
                    // Fondo opaco para iOS 16+
                    .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                }
            } else {
                AuthMainView(viewModel: authViewModel)
            }
        }
        .task {
            // Espera a la verificación de sesión antes de actualizar la UI
            await authViewModel.fetchCurrentUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}
