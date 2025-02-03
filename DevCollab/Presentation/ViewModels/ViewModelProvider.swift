class ViewModelProvider {
    static let shared = ViewModelProvider()
    private init() {}
    
    let authViewModel = AuthViewModel(authRepository: DependencyManager.shared.authRepository)
    let proyectosViewModel = ProyectosViewModel(obtenerProyectosUseCase: UseCaseProvider.shared.obtenerProyectosUseCase)
    let crearProyectoViewModel = CrearProyectoViewModel(crearProyectoUseCase: UseCaseProvider.shared.crearProyectoUseCase)
    let solicitudesViewModel = SolicitudesViewModel(obtenerSolicitudesUseCase: UseCaseProvider.shared.obtenerSolicitudesUseCase)
    let perfilViewModel = PerfilViewModel(authRepository: DependencyManager.shared.authRepository, proyectoRepository: DependencyManager.shared.proyectoRepository)
}
