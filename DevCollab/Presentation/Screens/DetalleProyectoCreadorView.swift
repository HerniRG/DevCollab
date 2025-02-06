import SwiftUI
import FirebaseAuth

struct DetalleProyectoCreadorView: View {
    let proyecto: Proyecto
    @StateObject private var viewModel: DetalleProyectoViewModel

    init(proyecto: Proyecto) {
        self.proyecto = proyecto
        let userID = Auth.auth().currentUser?.uid ?? ""
        _viewModel = StateObject(wrappedValue: DetalleProyectoViewModel(userID: userID))
    }

    var body: some View {
        VStack {
            Text(proyecto.nombre)
                .font(.largeTitle)
                .bold()
            Text("Creador: \(viewModel.nombreCreador)")
            
            // ✅ Mostrar el estado real actualizado en Firestore
            Text("Estado: \(viewModel.estadoProyecto)")
                .foregroundColor(viewModel.estadoProyecto == "Abierto" ? .green : .red)

            // 🔥 Solo el creador puede cambiar el estado
            Button(action: {
                Task {
                    await viewModel.alternarEstadoProyecto(proyectoID: proyecto.id)
                }
            }) {
                Text(viewModel.estadoProyecto == "Abierto" ? "Cerrar Proyecto" : "Reabrir Proyecto")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.estadoProyecto == "Abierto" ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .task {
            await viewModel.obtenerDatosAdicionales(proyectoID: proyecto.id)
        }
    }
}
