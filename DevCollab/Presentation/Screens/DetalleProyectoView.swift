import SwiftUI
import FirebaseFirestore

struct DetalleProyectoView: View {
    let proyecto: Proyecto
    @ObservedObject var viewModel: DetalleProyectoViewModel
    @State private var nombreCreador: String = ""
    @State private var yaSolicitado: Bool = false
    @State private var esMiProyecto: Bool = false
    @State private var soyParticipante: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(proyecto.nombre).font(.largeTitle).bold()
            Text("Descripción: \(proyecto.descripcion)")
            Text("Lenguajes: \(proyecto.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
            Text("Horas Semanales: \(proyecto.horasSemanales)")
            Text("Tipo de Colaboración: \(proyecto.tipoColaboracion)")
            Text("Estado: \(proyecto.estado)")
                .foregroundColor(proyecto.estado == "Abierto" ? .green : .red)
            Text("Creador: \(nombreCreador)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if esMiProyecto {
                Button(action: {
                    viewModel.toggleEstadoProyecto(proyectoID: proyecto.id)
                }) {
                    Text(proyecto.estado == "Abierto" ? "Cerrar Proyecto" : "Reabrir Proyecto")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(proyecto.estado == "Abierto" ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top)
                
                Text("Solicitudes de Participación")
                    .font(.headline)
                    .padding(.top)
                
                List(viewModel.solicitudesPendientes, id: \ .id) { solicitud in
                    HStack {
                        Text(solicitud.usuarioID)
                        Spacer()
                        Button("Aceptar") {
                            viewModel.actualizarEstadoSolicitud(solicitudID: solicitud.id, estado: "Aceptada")
                        }
                        .padding(.horizontal, 8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        Button("Rechazar") {
                            viewModel.actualizarEstadoSolicitud(solicitudID: solicitud.id, estado: "Rechazada")
                        }
                        .padding(.horizontal, 8)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                    }
                }
            } else if soyParticipante {
                Text("Ya eres parte de este proyecto")
                    .foregroundColor(.blue)
                    .padding(.top)
                Button("Abandonar Proyecto") {
                    viewModel.abandonarProyecto(proyectoID: proyecto.id)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Button(action: {
                    viewModel.solicitarParticipacion(proyectoID: proyecto.id)
                }) {
                    Text(yaSolicitado ? "Solicitud enviada" : "Solicitar Participación")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(yaSolicitado ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(yaSolicitado)
            }
        }
        .padding()
        .onAppear {
            viewModel.obtenerDatosAdicionales(proyectoID: proyecto.id) { creador, solicitado, esCreador, participante in
                self.nombreCreador = creador
                self.yaSolicitado = solicitado
                self.esMiProyecto = esCreador
                self.soyParticipante = participante
            }
        }
    }
}
