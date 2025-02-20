import SwiftUI

struct ProyectoRowView: View {
    let proyecto: Proyecto
    
    /// Indica si hay solicitudes pendientes relacionadas con este proyecto
    var tieneSolicitudPendiente: Bool = false
    
    /// Closure opcional para eliminar el proyecto (solo se muestra si el proyecto está cerrado)
    var onDelete: (() -> Void)? = nil
    
    /// Controla la animación del badge cuando hay solicitudes pendientes
    @State private var animateBadge: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                // Nombre del proyecto
                Text(proyecto.nombre)
                    .font(.headline)
                    .accessibilityLabel("Nombre del proyecto: \(proyecto.nombre)")
                
                // Lenguajes del proyecto
                Text("Lenguajes: \(proyecto.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Lenguajes: \(proyecto.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
                
                // Estado: Abierto en verde, Cerrado en rojo
                HStack {
                    Text("Estado:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)  // Información redundante
                    Text(proyecto.estado)
                        .font(.subheadline)
                        .foregroundColor(proyecto.estado == "Abierto" ? .green : .red)
                        .accessibilityLabel("Estado: \(proyecto.estado)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Botón de borrar (solo se muestra si el proyecto está cerrado y hay un handler)
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
        .padding(.vertical, 8)
        // Agrupamos la fila para que se lea como un solo elemento
        .accessibilityElement(children: .combine)
        // Overlay para la insignia de solicitudes pendientes
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
                        withAnimation(
                            .spring(response: 0.5, dampingFraction: 0.5)
                                .delay(0.1)
                        ) {
                            animateBadge = true
                        }
                    }
                    .offset(x: -8, y: 8)
                    .accessibilityLabel("Solicitud pendiente")
                    .accessibilityHint("Hay solicitudes pendientes para este proyecto")
                }
            },
            alignment: .topTrailing
        )
    }
}
