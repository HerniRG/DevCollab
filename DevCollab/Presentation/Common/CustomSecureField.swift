import SwiftUI

// 🔹 COMPONENTE PARA TEXTFIELD DE CONTRASEÑA
struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var isPasswordVisible: Bool
    
    var body: some View {
        HStack {
            // Dependiendo del estado, mostramos un TextField o SecureField.
            if isPasswordVisible {
                TextField(placeholder, text: $text)
                    .accessibilityLabel(placeholder)
                    .accessibilityValue(text)
                    .accessibilityHint("La contraseña es visible")
            } else {
                SecureField(placeholder, text: $text)
                    .accessibilityLabel(placeholder)
                    .accessibilityValue(text)
                    .accessibilityHint("La contraseña está oculta")
            }
            
            // Botón para alternar la visibilidad de la contraseña.
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
            .accessibilityLabel(isPasswordVisible ? "Ocultar contraseña" : "Mostrar contraseña")
            .accessibilityHint("Toca para cambiar la visibilidad de la contraseña")
        }
        .padding()
        .frame(height: 50) // 🔥 Asegura altura uniforme
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .accessibilityElement(children: .contain)
    }
}
