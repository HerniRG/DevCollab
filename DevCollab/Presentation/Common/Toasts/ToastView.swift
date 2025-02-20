import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        // Usamos un HStack para centrar mejor el texto
        HStack {
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                // Cuando aparece, se envía una notificación a VoiceOver
                .onAppear {
                    UIAccessibility.post(notification: .announcement, argument: message)
                }
        }
        .background(.regularMaterial) // Efecto de fondo translúcido
        .cornerRadius(8)
        .shadow(radius: 4)
        .padding(.horizontal, 16)
        // Agrupamos el contenido para accesibilidad y etiquetamos
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}
