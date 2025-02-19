class ViewModelProvider {
    static let shared = ViewModelProvider()
    
    // Declaramos las propiedades sin inicializarlas aún
    let toastManager: ToastManager
    let authViewModel: AuthViewModel
    let crearProyectoViewModel: CrearProyectoViewModel
    let proyectosViewModel: ProyectosViewModel
    let solicitudesViewModel: SolicitudesViewModel
    let perfilViewModel: PerfilViewModel

    private init() {
        // Inicializamos la instancia compartida de ToastManager
        self.toastManager = ToastManager()
        
        // Ahora, usando self.toastManager ya inicializado, inyectamos las dependencias
        self.authViewModel = AuthViewModel(
            authRepository: DependencyManager.shared.authRepository,
            toastManager: self.toastManager
        )
        
        self.crearProyectoViewModel = CrearProyectoViewModel(
            crearProyectoUseCase: UseCaseProvider.shared.crearProyectoUseCase,
            proyectoRepository: DependencyManager.shared.proyectoRepository,
            toastManager: self.toastManager
        )
        
        self.proyectosViewModel = ProyectosViewModel(toastManager: self.toastManager)
        
        self.solicitudesViewModel = SolicitudesViewModel(
            obtenerSolicitudesUseCase: UseCaseProvider.shared.obtenerSolicitudesUseCase,
            toastManager: self.toastManager
        )
        
        self.perfilViewModel = PerfilViewModel(
            authRepository: DependencyManager.shared.authRepository,
            proyectoRepository: DependencyManager.shared.proyectoRepository,
            solicitudRepository: DependencyManager.shared.solicitudRepository,
            updatePerfilUseCase: UseCaseProvider.shared.updatePerfilUseCase,
            toastManager: self.toastManager
        )
    }
}
