import SwiftUI

struct ProyectoRowView: View {
    let proyecto: Proyecto
    // Flag para indicar si hay solicitudes pendientes (por ejemplo, de otros usuarios)
    var tieneSolicitudPendiente: Bool = false
    // Closure opcional para borrar el proyecto
    var onDelete: (() -> Void)? = nil
    
    // Estado para controlar la animación del badge
    @State private var animateBadge: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(proyecto.nombre)
                    .font(.headline)
                Text("Lenguajes: \(proyecto.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Estado: \(proyecto.estado)")
                    .font(.subheadline)
                    .foregroundColor(proyecto.estado == "Abierto" ? .green : .red)
            }
            Spacer()
            // Botón de borrar, si procede
            if proyecto.estado == "Cerrado", let onDelete = onDelete {
                Button(action: {
                    onDelete()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .accessibilityLabel("Borrar proyecto")
                .accessibilityHint("Elimina este proyecto de Firebase")
            }
        }
        .padding()
        // Overlay para posicionar el badge en la esquina superior derecha con animación
        .overlay(
            Group {
                if tieneSolicitudPendiente {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 16, height: 16)
                        Image(systemName: "exclamationmark")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                    .scaleEffect(animateBadge ? 1.0 : 0.0)
                    .opacity(animateBadge ? 1.0 : 0.0)
                    .onAppear {
                        withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.5).delay(0.1)) {
                            animateBadge = true
                        }
                    }
                    .offset(x: -8, y: 8)
                }
            },
            alignment: .topTrailing
        )
    }
}
