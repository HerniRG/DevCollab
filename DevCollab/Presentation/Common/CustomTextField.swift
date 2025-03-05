import SwiftUI

// 🔹 COMPONENTE PARA TEXTFIELD NORMAL
struct CustomTextField: View {
    var placeholderKey: String  // Clave para Localizable.strings
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(NSLocalizedString(placeholderKey, comment: "Placeholder del campo de texto"), text: $text)
            .padding()
            .frame(height: 50) // 🔥 Asegura altura uniforme
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            // Accesibilidad:
            .accessibilityLabel(NSLocalizedString(placeholderKey, comment: "Placeholder del campo de texto"))
            .accessibilityValue(text)
            .accessibilityHint(NSLocalizedString("\(placeholderKey)_hint", comment: "Hint para el campo de texto"))
    }
}
