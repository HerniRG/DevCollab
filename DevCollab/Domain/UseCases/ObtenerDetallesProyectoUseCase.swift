protocol ObtenerDetallesProyectoUseCaseProtocol {
    func ejecutar(proyectoID: String, userID: String) async throws -> (String, Bool, Bool, Bool)
}

class ObtenerDetallesProyectoUseCase: ObtenerDetallesProyectoUseCaseProtocol {
    private let repository: ProyectoRepository
    
    init(repository: ProyectoRepository) {
        self.repository = repository
    }
    
    func ejecutar(proyectoID: String, userID: String) async throws -> (String, Bool, Bool, Bool) {
        do {
            return try await repository.obtenerDetallesProyecto(proyectoID: proyectoID, userID: userID)
        } catch {
            return ("Desconocido", false, false, false)
        }
    }
}
