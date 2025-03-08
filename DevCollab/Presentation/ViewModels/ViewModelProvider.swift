import Foundation

class ViewModelProvider {
    static let shared = ViewModelProvider()
    
    let toastManager: ToastManager
    
    // ViewModels individuales (Login/Registro) ya incluidos en AuthContainerViewModel.
    let authContainerVM: AuthContainerViewModel
    
    let crearProyectoViewModel: CrearProyectoViewModel
    let proyectosViewModel: ProyectosViewModel
    let solicitudesViewModel: SolicitudesViewModel
    let perfilViewModel: PerfilViewModel

    private init() {
        // 1) Inicializamos ToastManager
        self.toastManager = ToastManager()
        
        // 2) Creamos el AuthContainerViewModel que internamente tiene loginVM y registerVM
        self.authContainerVM = AuthContainerViewModel(
            authRepository: DependencyManager.shared.authRepository,
            toastManager: self.toastManager
        )
        
        // 3) Demás ViewModels
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
