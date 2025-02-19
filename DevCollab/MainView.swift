import SwiftUI
import FirebaseAuth

struct MainView: View {
    @StateObject var authViewModel = ViewModelProvider.shared.authViewModel
    @State private var isLoading = true
    
    // Controlar navegación a Perfil y a CrearProyecto
    @State private var showingProfile = false
    @State private var showCrearProyectoOverlay = false  // Controla la superposición personalizada

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
        ZStack {
            Group {
                if isLoading {
                    LoadingView()
                        .transition(.opacity)
                } else if authViewModel.user != nil {
                    NavigationView {
                        ZStack(alignment: .bottomTrailing) {
                            ExploracionProyectosView()
                                .navigationBarTitle("DevCollab", displayMode: .inline)
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button {
                                            showingProfile = true
                                        } label: {
                                            Image(systemName: "person.crop.circle")
                                        }
                                    }
                                }
                            
                            Button {
                                // Activa la superposición personalizada con animación desde abajo
                                withAnimation(.easeInOut) { showCrearProyectoOverlay = true }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 56, height: 56)
                                            .shadow(radius: 5)
                                    )
                            }
                            .padding(.trailing, 24)
                            .padding(.bottom, 24)
                        }
                        .background(
                            NavigationLink(
                                destination: PerfilView(viewModel: ViewModelProvider.shared.perfilViewModel),
                                isActive: $showingProfile
                            ) { EmptyView() }
                            .hidden()
                        )
                    }
                    .transition(.opacity)
                } else {
                    AuthMainView(viewModel: authViewModel)
                        .transition(.opacity)
                }
            }
            
            
            // Overlay personalizado para CrearProyectoView con animación desde abajo
            if showCrearProyectoOverlay {
                CrearProyectoView(viewModel: ViewModelProvider.shared.crearProyectoViewModel, isPresented: Binding(
                    get: { showCrearProyectoOverlay },
                    set: { newValue in
                        withAnimation(.easeInOut) {
                            showCrearProyectoOverlay = newValue
                            
                            // Si se cierra la vista de creación, recargar proyectos
                            if !newValue {
                                ViewModelProvider.shared.proyectosViewModel.fetchProyectos()
                            }
                        }
                    }
                ))
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
        .animation(.easeInOut, value: authViewModel.user)
        .task {
            await authViewModel.fetchCurrentUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation { isLoading = false }
            }
        }
    }
}
