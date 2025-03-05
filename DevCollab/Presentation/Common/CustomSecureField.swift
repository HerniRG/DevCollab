import SwiftUI

// 🔹 COMPONENTE PARA TEXTFIELD DE CONTRASEÑA
struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var isPasswordVisible: Bool
    
    var body: some View {
        HStack {
            // 🔥 Se muestra un TextField o SecureField según el estado de visibilidad
            if isPasswordVisible {
                TextField(NSLocalizedString("password_placeholder", comment: "Placeholder para el campo de contraseña"), text: $text)
                    .accessibilityLabel(NSLocalizedString("password_placeholder", comment: "Placeholder para el campo de contraseña"))
                    .accessibilityHint(NSLocalizedString("password_visible_hint", comment: "Indica que la contraseña está visible"))
            } else {
                SecureField(NSLocalizedString("password_placeholder", comment: "Placeholder para el campo de contraseña"), text: $text)
                    .accessibilityLabel(NSLocalizedString("password_placeholder", comment: "Placeholder para el campo de contraseña"))
                    .accessibilityHint(NSLocalizedString("password_hidden_hint", comment: "Indica que la contraseña está oculta"))
            }
            
            // Botón para alternar la visibilidad de la contraseña.
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
            .accessibilityLabel(NSLocalizedString(isPasswordVisible ? "hide_password" : "show_password", comment: "Botón para alternar visibilidad de la contraseña"))
            .accessibilityHint(NSLocalizedString("toggle_password_visibility_hint", comment: "Toca para cambiar la visibilidad de la contraseña"))
        }
        .padding()
        .frame(height: 50) // 🔥 Asegura altura uniforme
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .accessibilityElement(children: .contain)
    }
}
