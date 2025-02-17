import SwiftUI
import FirebaseAuth

struct MainView: View {
    @StateObject var authViewModel = ViewModelProvider.shared.authViewModel
    @State private var isLoading = true
    
    // Controlar navegación al perfil
    @State private var showingProfile = false
    
    // Controlar navegación a "CrearProyectoView"
    @State private var showingCrearProyecto = false
    
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
                    .transition(.opacity)
            }
            else if authViewModel.user != nil {
                NavigationView {
                    ZStack(alignment: .bottomTrailing) {
                        ExploracionProyectosView() // Ahora usará el shared proyectosViewModel
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
                        
                        // Botón flotante "Crear Proyecto"
                        Button {
                            showingCrearProyecto = true
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
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    )
                    // Presentación modal para CrearProyectoView con onDismiss que actualiza la lista
                    .sheet(isPresented: $showingCrearProyecto, onDismiss: {
                        ViewModelProvider.shared.proyectosViewModel.fetchProyectos()
                    }) {
                        CrearProyectoView(viewModel: ViewModelProvider.shared.crearProyectoViewModel, isPresented: $showingCrearProyecto)
                    }
                }
                .transition(.opacity)
            }
            else {
                AuthMainView(viewModel: authViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: authViewModel.user)
        .task {
            await authViewModel.fetchCurrentUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isLoading = false
                }
            }
        }
        .onChange(of: authViewModel.user) { newUser in
            showingProfile = false
            showingCrearProyecto = false
        }
    }
}
