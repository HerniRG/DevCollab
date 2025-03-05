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
            return NSLocalizedString("auth_invalid_email", comment: "Error cuando el email no es válido")
        case .weakPassword:
            return NSLocalizedString("auth_weak_password", comment: "Error cuando la contraseña es demasiado débil")
        case .emailAlreadyInUse:
            return NSLocalizedString("auth_email_in_use", comment: "Error cuando el email ya está registrado")
        case .userNotFound:
            return NSLocalizedString("auth_user_not_found", comment: "Error cuando no se encuentra el usuario")
        case .wrongPassword:
            return NSLocalizedString("auth_wrong_password", comment: "Error cuando la contraseña es incorrecta")
        case .emailNotVerified:
            return NSLocalizedString("auth_email_not_verified", comment: "Error cuando el email no ha sido verificado")
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
