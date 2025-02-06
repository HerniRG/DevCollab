import SwiftUI
import FirebaseAuth

struct DetalleProyectoParticipanteView: View {
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

            // 🔥 Opción de solicitar participación
            if !viewModel.yaSolicitado {
                Button(action: {
                    Task {
                        await viewModel.solicitarParticipacion(proyectoID: proyecto.id)
                    }
                }) {
                    Text("Solicitar Participación")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                Text("Solicitud Pendiente o Aprobada")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .padding()
        .task {
            await viewModel.obtenerDatosAdicionales(proyectoID: proyecto.id)
        }
    }
}
