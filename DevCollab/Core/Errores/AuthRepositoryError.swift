import Foundation

enum AuthRepositoryError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "El correo electrónico no es válido."
        case .weakPassword:
            return "La contraseña es demasiado débil."
        case .emailAlreadyInUse:
            return "El correo electrónico ya está en uso."
        case .userNotFound:
            return "No se encontró un usuario con ese correo."
        case .wrongPassword:
            // Se devuelve un mensaje más genérico para cubrir ambos casos
            return "Usuario o contraseña incorrectos."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
