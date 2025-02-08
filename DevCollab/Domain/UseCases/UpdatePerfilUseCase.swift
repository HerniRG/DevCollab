//
//  UpdatePerfilUseCase.swift
//  DevCollab
//
//  Created by Hernán Rodríguez on 8/2/25.
//


protocol UpdatePerfilUseCase {
    func execute(userID: String,
                 nombre: String,
                 descripcion: String,
                 lenguajes: [LenguajeProgramacion]) async throws
}

/// Implementación
class UpdatePerfilUseCaseImpl: UpdatePerfilUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(userID: String,
                 nombre: String,
                 descripcion: String,
                 lenguajes: [LenguajeProgramacion]) async throws {
        // Ejemplo: Podrías hacer validaciones
        // if nombre.isEmpty { throw Error("Nombre vacío") }
        
        // Llamar al repositorio
        try await userRepository.updateUserData(
            userID: userID,
            nombre: nombre,
            descripcion: descripcion,
            lenguajes: lenguajes
        )
    }
}