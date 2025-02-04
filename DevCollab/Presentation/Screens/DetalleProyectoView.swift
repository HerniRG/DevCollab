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
            Text("Estado: \(viewModel.esMiProyecto ? "Abierto" : "Cerrado")")
                .foregroundColor(viewModel.esMiProyecto ? .green : .red)

            Button(action: {
                Task {
                    await viewModel.toggleEstadoProyecto(proyectoID: proyecto.id)
                    await viewModel.obtenerDatosAdicionales(proyectoID: proyecto.id) // 🔥 Recargar después del cambio
                }
            }) {
                Text(viewModel.esMiProyecto ? "Cerrar Proyecto" : "Reabrir Proyecto")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.esMiProyecto ? Color.red : Color.green)
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
