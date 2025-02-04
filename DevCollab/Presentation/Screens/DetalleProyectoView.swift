import SwiftUI
import FirebaseAuth

struct DetalleProyectoView: View {
    let proyecto: Proyecto
    @StateObject private var viewModel: DetalleProyectoViewModel

    init(proyecto: Proyecto) {
        self.proyecto = proyecto
        let userID = Auth.auth().currentUser?.uid ?? "" // Recuperamos el ID del usuario autenticado
        _viewModel = StateObject(wrappedValue: DetalleProyectoViewModel(userID: userID))
    }

    var body: some View {
        VStack {
            Text(proyecto.nombre)
                .font(.largeTitle)
                .bold()
            Text("Creador: \(viewModel.nombreCreador)")
            Button(action: {
                Task {
                    await viewModel.toggleEstadoProyecto(proyectoID: proyecto.id)
                }
            }) {
                Text(proyecto.estado == "Abierto" ? "Cerrar Proyecto" : "Reabrir Proyecto")
            }
        }
        .padding()
        .task {
            viewModel.obtenerDatosAdicionales(proyectoID: proyecto.id)
        }
    }
}
