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
                // MARK: - Estado de carga
                if isLoading {
                    LoadingView()
                        .transition(.opacity)
                }
                // MARK: - Usuario autenticado
                else if authViewModel.user != nil {
                    NavigationView {
                        ZStack(alignment: .bottomTrailing) {
                            // Exploración de proyectos rediseñada
                            ExploracionProyectosView()
                                .navigationBarTitle("DevCollab", displayMode: .inline)
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        // Botón para ir al perfil
                                        Button {
                                            showingProfile = true
                                        } label: {
                                            Image(systemName: "person.crop.circle")
                                        }
                                    }
                                }
                            
                            // Botón flotante para Crear Proyecto
                            Button {
                                withAnimation(.easeInOut) {
                                    showCrearProyectoOverlay = true
                                }
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
                        // Navegación al Perfil
                        .background(
                            NavigationLink(
                                destination: PerfilView(viewModel: ViewModelProvider.shared.perfilViewModel),
                                isActive: $showingProfile
                            ) {
                                EmptyView()
                            }
                            .hidden()
                        )
                    }
                    .transition(.opacity)
                }
                // MARK: - Usuario no autenticado: Pantalla de login/registro
                else {
                    AuthMainView(viewModel: authViewModel)
                        .transition(.opacity)
                }
            }
            
            // MARK: - Overlay para CrearProyectoView
            if showCrearProyectoOverlay {
                CrearProyectoView(
                    viewModel: ViewModelProvider.shared.crearProyectoViewModel,
                    isPresented: Binding(
                        get: { showCrearProyectoOverlay },
                        set: { newValue in
                            withAnimation(.easeInOut) {
                                showCrearProyectoOverlay = newValue
                                // Al cerrar la vista, recarga la lista de proyectos
                                if !newValue {
                                    ViewModelProvider.shared.proyectosViewModel.fetchProyectos()
                                }
                            }
                        }
                    )
                )
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
        .animation(.easeInOut, value: authViewModel.user)
        // MARK: - Tarea asíncrona para verificar usuario al cargar la vista
        .task {
            await authViewModel.fetchCurrentUser()
            // Simulación de espera para mostrar la pantalla de carga
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}
