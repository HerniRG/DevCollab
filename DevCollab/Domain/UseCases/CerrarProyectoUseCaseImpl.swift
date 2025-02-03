protocol CerrarProyectoUseCase {
    func execute(proyectoID: String) async throws
}

class CerrarProyectoUseCaseImpl: CerrarProyectoUseCase {
    private let repository: ProyectoRepository
    
    init(repository: ProyectoRepository) {
        self.repository = repository
    }
    
    func execute(proyectoID: String) async throws {
        try await repository.cerrarProyecto(proyectoID: proyectoID)
    }
}
