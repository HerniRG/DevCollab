import SwiftUI

struct LoadingView: View {
    @State private var pulsate: Bool = false
    
    var body: some View {
        ZStack {
            // Fondo adaptado al sistema, para modo claro y oscuro
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Logo antiguo: parecido a "< / >"
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
                
                // Texto informativo
                Text("Conectando con DevCollab...")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Barra de carga animada
                LoadingBar()
            }
            .padding()
        }
        .onAppear {
            pulsate = true
        }
    }
}

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
                
                // Barra animada que se desplaza dentro del progress bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.5)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: barWidth, height: 8)
                    // Desplazamos desde 0 hasta (ancho total - ancho de la línea)
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
