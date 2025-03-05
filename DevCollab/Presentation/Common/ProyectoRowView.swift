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
                    .accessibilityLabel(String(format: NSLocalizedString("project_name", comment: "Etiqueta de nombre de proyecto"), proyecto.nombre))
                
                // Lenguajes del proyecto
                Text(String(format: NSLocalizedString("project_languages", comment: "Etiqueta de lenguajes del proyecto"),
                            proyecto.lenguajes.map { NSLocalizedString($0.rawValue, comment: "Nombre del lenguaje") }.joined(separator: ", ")))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityLabel(String(format: NSLocalizedString("project_languages", comment: "Etiqueta de accesibilidad para lenguajes del proyecto"),
                                               proyecto.lenguajes.map { NSLocalizedString($0.rawValue, comment: "Nombre del lenguaje") }.joined(separator: ", ")))
                
                // Estado: Abierto en verde, Cerrado en rojo
                HStack {
                    Text(NSLocalizedString("status", comment: "Etiqueta de estado"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)  // Información redundante
                    Text(NSLocalizedString(proyecto.estado, comment: "Estado del proyecto"))
                        .font(.subheadline)
                        .foregroundColor(proyecto.estado == "Abierto" ? .green : .red)
                        .accessibilityLabel(String(format: NSLocalizedString("project_status", comment: "Accesibilidad del estado"), proyecto.estado))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Botón de borrar (solo si el proyecto está cerrado y hay un handler)
            if proyecto.estado == "Cerrado", let onDelete = onDelete {
                Button(action: {
                    onDelete()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .accessibilityLabel(NSLocalizedString("delete_project", comment: "Etiqueta de botón para eliminar proyecto"))
                .accessibilityHint(NSLocalizedString("delete_project_hint", comment: "Hint para eliminar proyecto de Firebase"))
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
                    .accessibilityLabel(NSLocalizedString("pending_request", comment: "Etiqueta para indicar que hay solicitudes pendientes"))
                    .accessibilityHint(NSLocalizedString("pending_request_hint", comment: "Hint para indicar que hay solicitudes pendientes en este proyecto"))
                }
            },
            alignment: .topTrailing
        )
    }
}
