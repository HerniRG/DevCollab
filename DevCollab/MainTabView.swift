import SwiftUI

struct MainTabView: View {
    @StateObject var authViewModel = ViewModelProvider.shared.authViewModel
    
    var body: some View {
        if authViewModel.user != nil {
            TabView {
                ExploracionProyectosView(viewModel: ViewModelProvider.shared.proyectosViewModel)
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
        } else {
            LoginView(viewModel: authViewModel)
        }
    }
}
