import SwiftUI

struct ProyectoRowView: View {
    let proyecto: Proyecto
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(proyecto.nombre).font(.headline)
            Text("Lenguajes: \(proyecto.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("Estado: \(proyecto.estado)")
                .font(.subheadline)
                .foregroundColor(proyecto.estado == "Abierto" ? .green : .red)
        }
        .padding()
    }
}
