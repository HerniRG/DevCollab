protocol ObtenerProyectosUseCase {
    func execute() async throws -> [Proyecto]
}

class ObtenerProyectosUseCaseImpl: ObtenerProyectosUseCase {
    private let repository: ProyectoRepository
    
    init(repository: ProyectoRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [Proyecto] {
        return try await repository.obtenerProyectos()
    }
}
