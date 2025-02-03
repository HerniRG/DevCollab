import Foundation

enum DevCollabError: Error {
    case usuarioNoEncontrado
    case proyectoNoEncontrado
    case solicitudInvalida
    case operacionFallida
}

extension DevCollabError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .usuarioNoEncontrado:
            return "El usuario no fue encontrado."
        case .proyectoNoEncontrado:
            return "El proyecto no existe."
        case .solicitudInvalida:
            return "Solicitud no válida."
        case .operacionFallida:
            return "Ha ocurrido un error en la operación."
        }
    }
}
