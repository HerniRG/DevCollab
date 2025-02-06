import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @StateObject var authViewModel = ViewModelProvider.shared.authViewModel
    @State private var isLoading = true // 🔥 Estado de carga inicial
    
    // Ajustes para la barra de navegación (iOS < 16)
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        // Opcional: cambiar color del título y botones
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        // Asigna la apariencia a los distintos estados de la barra
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        Group {
            if isLoading {
                // 🔥 Nueva pantalla de carga personalizada
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
                    // Título en modo inline (pequeño)
                    .navigationBarTitle("DevCollab")
                    .navigationBarTitleDisplayMode(.inline)
                    
                    // Botón de "Cerrar sesión" en la barra superior derecha
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                authViewModel.logout()
                            }) {
                                Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        }
                    }
                    // Para iOS 16+: color de fondo opaco en la barra
                    .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                }
            } else {
                // 🔹 Si no hay sesión, muestra la vista de autenticación
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
