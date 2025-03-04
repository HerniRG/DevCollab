import Foundation

class ViewModelProvider {
    static let shared = ViewModelProvider()
    
    let toastManager: ToastManager
    let loginVM: LoginViewModel
    let registerVM: RegisterViewModel
    let crearProyectoViewModel: CrearProyectoViewModel
    let proyectosViewModel: ProyectosViewModel
    let solicitudesViewModel: SolicitudesViewModel
    let perfilViewModel: PerfilViewModel

    private init() {
        // Inicializamos ToastManager
        self.toastManager = ToastManager()
        
        self.loginVM = LoginViewModel(
            authRepository: DependencyManager.shared.authRepository,
            toastManager: self.toastManager
        )
        self.registerVM = RegisterViewModel(
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
