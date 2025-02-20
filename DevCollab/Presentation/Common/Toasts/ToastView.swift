import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        // Usamos un HStack para centrar mejor el texto en caso de que haya varios elementos
        HStack {
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .background(.regularMaterial) // Efecto de fondo translúcido
        .cornerRadius(8)
        .shadow(radius: 4)
        .padding(.horizontal, 16) // Margen horizontal para separarlo de los bordes de la pantalla
    }
}
