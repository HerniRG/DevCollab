import SwiftUI

struct SolicitudDetailModalView: View {
    let solicitud: Solicitud
    let usuario: Usuario
    var onDecision: (Bool) -> Void  // true: aprobar, false: rechazar
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Detalles de la Solicitud")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 20)
                
                // Datos del usuario
                Text("Nombre: \(usuario.nombre)")
                    .font(.body)
                if !usuario.lenguajes.isEmpty {
                    Text("Lenguajes: \(usuario.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
                        .font(.body)
                }
                if let descripcion = usuario.descripcion, !descripcion.isEmpty {
                    Text("Descripción: \(descripcion)")
                        .font(.body)
                }
                
                // Mostrar el mensaje de la solicitud
                if let mensaje = solicitud.mensaje, !mensaje.isEmpty {
                    Text("Mensaje: \(mensaje)")
                        .font(.body)
                        .padding(.top, 8)
                }
                
                Spacer()
                
                // Botones para aprobar o rechazar
                HStack(spacing: 16) {
                    Button(action: {
                        onDecision(true)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Aprobar")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        onDecision(false)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Rechazar")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .navigationBarTitle("Solicitud", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .interactiveDismissDisabled(true)
    }
}
