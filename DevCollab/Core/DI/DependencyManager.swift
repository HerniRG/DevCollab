class DependencyManager {
    static let shared = DependencyManager()
    private init() {}
    
    lazy var authRepository: AuthRepository = FirebaseAuthRepository()
    lazy var proyectoRepository: ProyectoRepository = FirebaseProyectoRepository()
    lazy var solicitudRepository: SolicitudRepository = FirebaseSolicitudRepository()
}
