import SwiftUI

// MARK: - Cabecera Común (Internacionalizada)
struct AuthHeaderView: View {
    let isRegistering: Bool

    var body: some View {
        VStack(spacing: 5) {
            // Título principal de la app
            Text(NSLocalizedString("devcollab_app_title", comment: "Título principal de la aplicación"))
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.blue)
                .accessibilityLabel(NSLocalizedString("devcollab_app_title_accessibility", comment: "Accesibilidad: Nombre de la app"))
                .accessibilityAddTraits(.isHeader)
            
            // Texto dinámico según sea registro o login
            Text(isRegistering
                 ? NSLocalizedString("create_account", comment: "Texto para crear cuenta")
                 : NSLocalizedString("start_session", comment: "Texto para iniciar sesión"))
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
                .accessibilityLabel(isRegistering
                    ? NSLocalizedString("create_account_accessibility", comment: "Accesibilidad: Crear cuenta")
                    : NSLocalizedString("start_session_accessibility", comment: "Accesibilidad: Iniciar sesión"))
        }
        .accessibilityElement(children: .combine)
    }
}
