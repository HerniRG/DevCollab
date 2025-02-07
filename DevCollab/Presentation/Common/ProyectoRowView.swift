import SwiftUI

struct ProyectoRowView: View {
    let proyecto: Proyecto
    // Closure opcional para borrar el proyecto
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
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
            // Si el proyecto está cerrado y se proporcionó la función onDelete, se muestra el botón
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
    }
}
