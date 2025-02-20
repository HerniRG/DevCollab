import SwiftUI

// 🔹 COMPONENTE PARA TEXTFIELD NORMAL
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .frame(height: 50) // 🔥 Asegura altura uniforme
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            // Accesibilidad:
            .accessibilityLabel(placeholder)
            .accessibilityValue(text)
            .accessibilityHint("Ingrese su \(placeholder.lowercased())")
    }
}
