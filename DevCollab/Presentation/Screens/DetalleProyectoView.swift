import SwiftUI

struct DetalleProyectoView: View {
    let proyecto: Proyecto
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(proyecto.nombre).font(.largeTitle).bold()
            Text("Descripción: \(proyecto.descripcion)")
            Text("Lenguajes: \(proyecto.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
            Text("Horas Semanales: \(proyecto.horasSemanales)")
            Text("Tipo de Colaboración: \(proyecto.tipoColaboracion)")
            Text("Estado: \(proyecto.estado)")
                .foregroundColor(proyecto.estado == "Abierto" ? .green : .red)
            Spacer()
        }
        .padding()
        .navigationTitle("Detalles del Proyecto")
    }
}
