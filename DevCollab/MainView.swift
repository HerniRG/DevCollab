import SwiftUI
import FirebaseAuth

struct MainView: View {
    // Este es el que maneja Login, Registro y estado del usuario
    @StateObject var authContainerVM = ViewModelProvider.shared.authContainerVM
    
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
            // Si hay usuario, mostramos la app principal
            else if authContainerVM.user != nil {
                NavigationView {
                    ZStack(alignment: .bottomTrailing) {
                        ExploracionProyectosView()
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    HStack {
                                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                                            .foregroundColor(.accentColor)
                                        Text("DevCollab")
                                            .font(.headline)
                                    }
                                }
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        showingProfile = true
                                    }) {
                                        Image(systemName: "person.crop.circle")
                                    }
                                }
                            }
                        
                        // Botón flotante para "Crear Proyecto"
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
            // Si no hay usuario, mostramos la pantalla de login/registro
            else {
                // Aquí inyectas el MISMO authContainerVM
                LoginRegisterScreen(authContainerVM: authContainerVM)
                    .onAppear {
                        showingProfile = false
                        showCrearProyectoOverlay = false
                    }
            }
            
            // Overlay para Crear Proyecto (si procede)
            if showCrearProyectoOverlay {
                CrearProyectoView(
                    viewModel: ViewModelProvider.shared.crearProyectoViewModel,
                    isPresented: $showCrearProyectoOverlay
                )
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
        .animation(.easeInOut, value: authContainerVM.user)
        .task {
            // Cargamos el usuario actual (auto-login si ya existía sesión)
            await authContainerVM.fetchCurrentUser()
            // Pequeña simulación de carga
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}
