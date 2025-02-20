import SwiftUI

struct SolicitudDetailModalView: View {
    let solicitud: Solicitud
    let usuario: Usuario
    var onDecision: (Bool) -> Void  // true: aprobar, false: rechazar
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Título
                Text("Detalles de la Solicitud")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 20)
                    // Accesibilidad
                    .accessibilityLabel("Detalles de la solicitud")
                
                // Datos del usuario
                Text("Nombre: \(usuario.nombre)")
                    .font(.body)
                    .accessibilityLabel("Nombre del usuario: \(usuario.nombre)")
                
                if !usuario.lenguajes.isEmpty {
                    Text("Lenguajes: \(usuario.lenguajes.map { $0.rawValue }.joined(separator: ", "))")
                        .font(.body)
                        .accessibilityLabel(
                            "Lenguajes del usuario: \(usuario.lenguajes.map { $0.rawValue }.joined(separator: ", "))"
                        )
                }
                
                if let descripcion = usuario.descripcion, !descripcion.isEmpty {
                    Text("Descripción: \(descripcion)")
                        .font(.body)
                        .accessibilityLabel("Descripción del usuario: \(descripcion)")
                }
                
                // Mensaje de la solicitud
                if let mensaje = solicitud.mensaje, !mensaje.isEmpty {
                    Text("Mensaje: \(mensaje)")
                        .font(.body)
                        .padding(.top, 8)
                        .accessibilityLabel("Mensaje del usuario: \(mensaje)")
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
                    .accessibilityLabel("Aprobar solicitud")
                    .accessibilityHint("Acepta la solicitud del usuario para participar en el proyecto")
                    
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
                    .accessibilityLabel("Rechazar solicitud")
                    .accessibilityHint("Rechaza la solicitud del usuario para participar en el proyecto")
                }
            }
            .padding()
            .navigationBarTitle("Solicitud", displayMode: .inline)
            // Botón para cerrar la vista
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            }
            .accessibilityLabel("Cerrar la vista de solicitud")
            .accessibilityHint("Regresa a la pantalla anterior"))
        }
        // Evita cierre interactivo con swipe mientras se procesa la acción
        .interactiveDismissDisabled(true)
    }
}
