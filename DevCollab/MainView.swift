import SwiftUI
import FirebaseAuth

struct MainView: View {
    // Ahora usamos directamente el LoginViewModel en lugar del contenedor completo.
    @StateObject var loginVM = ViewModelProvider.shared.loginVM
    @State private var isLoading = true
    
    // Variables para navegación a perfil y para mostrar el overlay de crear proyecto.
    @State private var showingProfile = false
    @State private var showCrearProyectoOverlay = false

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
            if isLoading {
                LoadingView()
                    .transition(.opacity)
            }
            else if loginVM.user != nil {
                // Usuario autenticado: se muestra la app principal.
                NavigationView {
                    ZStack(alignment: .bottomTrailing) {
                        ExploracionProyectosView()
                            .navigationTitle("DevCollab")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        showingProfile = true
                                    }) {
                                        Image(systemName: "person.crop.circle")
                                    }
                                }
                            }
                        
                        // Botón flotante para Crear Proyecto.
                        Button(action: {
                            withAnimation(.easeInOut) {
                                showCrearProyectoOverlay = true
                            }
                        }) {
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
                    // Navegación al Perfil.
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
            
            else {
                LoginRegisterScreen()
                    .onAppear {
                        showingProfile = false
                        showCrearProyectoOverlay = false
                    }
            }
            // Overlay para Crear Proyecto (si procede).
            if showCrearProyectoOverlay {
                CrearProyectoView(
                    viewModel: ViewModelProvider.shared.crearProyectoViewModel,
                    isPresented: $showCrearProyectoOverlay
                )
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
        .animation(.easeInOut, value: loginVM.user)
        .task {
            await loginVM.fetchCurrentUser()
            // Simulación de espera para mostrar la pantalla de carga.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}
