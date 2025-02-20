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
                
                // Lenguajes del proyecto
                Text("Lenguajes: \(proyecto.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Estado (Abierto en verde, Cerrado en rojo)
                HStack {
                    Text("Estado:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(proyecto.estado)
                        .font(.subheadline)
                        .foregroundColor(proyecto.estado == "Abierto" ? .green : .red)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Botón de borrar, solo si está cerrado y hay un handler
            if proyecto.estado == "Cerrado", let onDelete = onDelete {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .accessibilityLabel("Borrar proyecto")
                .accessibilityHint("Elimina este proyecto de Firebase")
            }
        }
        .padding(.vertical, 8)
        // Overlay en la esquina superior derecha para la insignia
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
                }
            },
            alignment: .topTrailing
        )
    }
}
