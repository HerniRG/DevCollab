protocol CrearProyectoUseCase {
    func execute(proyecto: Proyecto) async throws
}

class CrearProyectoUseCaseImpl: CrearProyectoUseCase {
    private let repository: ProyectoRepository
    
    init(repository: ProyectoRepository) {
        self.repository = repository
    }
    
    func execute(proyecto: Proyecto) async throws {
        try await repository.crearProyecto(proyecto: proyecto)
    }
}
