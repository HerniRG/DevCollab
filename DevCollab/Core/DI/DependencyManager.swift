class DependencyManager {
    static let shared = DependencyManager()
    private init() {}
    
    // Repositorios que ya tienes
    lazy var authRepository: AuthRepository = FirebaseAuthRepository()
    lazy var proyectoRepository: ProyectoRepository = FirebaseProyectoRepository()
    lazy var solicitudRepository: SolicitudRepository = FirebaseSolicitudRepository()
    
    // Nuevo: repositorio de usuarios
    lazy var userRepository: UserRepository = FirebaseUserRepository()
}
