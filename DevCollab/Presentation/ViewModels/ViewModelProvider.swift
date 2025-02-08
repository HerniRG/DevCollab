class ViewModelProvider {
    static let shared = ViewModelProvider()
    private init() {}
    
    let authViewModel = AuthViewModel(authRepository: DependencyManager.shared.authRepository)
    let proyectosViewModel = ProyectosViewModel()
    
    let crearProyectoViewModel = CrearProyectoViewModel(
        crearProyectoUseCase: UseCaseProvider.shared.crearProyectoUseCase,
        proyectoRepository: DependencyManager.shared.proyectoRepository
    )
    
    let solicitudesViewModel = SolicitudesViewModel(
        obtenerSolicitudesUseCase: UseCaseProvider.shared.obtenerSolicitudesUseCase
    )

    // Aquí inyectamos el updatePerfilUseCase también:
    let perfilViewModel = PerfilViewModel(
        authRepository: DependencyManager.shared.authRepository,
        proyectoRepository: DependencyManager.shared.proyectoRepository,
        solicitudRepository: DependencyManager.shared.solicitudRepository,
        updatePerfilUseCase: UseCaseProvider.shared.updatePerfilUseCase
    )
}
