import Foundation

enum AuthRepositoryError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case emailNotVerified  // Nuevo caso
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
            return "Usuario o contraseña incorrectos."
        case .emailNotVerified:
            return "El correo electrónico no ha sido verificado. Por favor, revisa tu bandeja de entrada."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
