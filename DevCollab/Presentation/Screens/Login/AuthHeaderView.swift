import SwiftUI

// MARK: - Cabecera Común
struct AuthHeaderView: View {
    let isRegistering: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            Text("DevCollab")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.blue)
                .accessibilityLabel("DevCollab")
                .accessibilityAddTraits(.isHeader)
            
            Text(isRegistering ? "Crea tu cuenta" : "Inicia sesión")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
                .accessibilityLabel(isRegistering ? "Crea tu cuenta" : "Inicia sesión")
        }
        .accessibilityElement(children: .combine)
    }
}
