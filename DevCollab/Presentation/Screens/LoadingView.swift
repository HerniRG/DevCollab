import SwiftUI

struct LoadingView: View {
    @State private var pulsate: Bool = false
    
    var body: some View {
        ZStack {
            // Fondo adaptado al modo claro y oscuro
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Logo animado
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(Color.accentColor)
                    .scaleEffect(pulsate ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                        value: pulsate
                    )
                    .accessibilityLabel(NSLocalizedString("loading_view_icon_accessibility", comment: "Texto que describe el icono de carga"))
                    .accessibilityHidden(false) // Es un icono con significado
                
                // Texto informativo con accesibilidad activa
                Text(NSLocalizedString("loading_view_text", comment: "Texto de carga principal"))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Barra de carga animada
                LoadingBar()
                    .accessibilityLabel(NSLocalizedString("loading_view_progress_accessibility", comment: "Accesibilidad para la barra de progreso"))
                    .accessibilityHint(NSLocalizedString("loading_view_progress_hint", comment: "Indica al usuario que debe esperar"))
            }
            .padding()
        }
        .onAppear {
            pulsate = true
        }
    }
}

// MARK: - Barra de carga animada
struct LoadingBar: View {
    @State private var animate: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let barWidth = width * 0.3  // Ancho de la línea animada
            
            ZStack(alignment: .leading) {
                // Fondo estático del progress bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .accessibilityHidden(true) // No es necesario para VoiceOver
                
                // Barra animada
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.5)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: barWidth, height: 8)
                    .offset(x: animate ? width - barWidth : 0)
                    .animation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: animate
                    )
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 40)
        .onAppear {
            animate = true
        }
    }
}
