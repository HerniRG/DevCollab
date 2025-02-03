class UseCaseProvider {
    static let shared = UseCaseProvider()
    private init() {}
    
    let obtenerProyectosUseCase: ObtenerProyectosUseCase = ObtenerProyectosUseCaseImpl(repository: DependencyManager.shared.proyectoRepository)
    let crearProyectoUseCase: CrearProyectoUseCase = CrearProyectoUseCaseImpl(repository: DependencyManager.shared.proyectoRepository)
    let cerrarProyectoUseCase: CerrarProyectoUseCase = CerrarProyectoUseCaseImpl(repository: DependencyManager.shared.proyectoRepository)
    let enviarSolicitudUseCase: EnviarSolicitudUseCase = EnviarSolicitudUseCaseImpl(repository: DependencyManager.shared.solicitudRepository)
    let obtenerSolicitudesUseCase: ObtenerSolicitudesUseCase = ObtenerSolicitudesUseCaseImpl(repository: DependencyManager.shared.solicitudRepository)
}
