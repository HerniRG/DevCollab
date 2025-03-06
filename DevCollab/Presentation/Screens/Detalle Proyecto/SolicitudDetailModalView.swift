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
                Text(NSLocalizedString("request_details_title", comment: "Título para detalles de la solicitud"))
                    .font(.title)
                    .bold()
                    .padding(.bottom, 20)
                    .accessibilityLabel(NSLocalizedString("request_details_accessibility", comment: "Accesibilidad: Detalles de la solicitud"))
                
                // Datos del usuario
                Text(String(format: NSLocalizedString("user_name_format", comment: "Nombre: %@"), usuario.nombre))
                    .font(.body)
                    .accessibilityLabel(String(format: NSLocalizedString("user_name_accessibility", comment: "Nombre del usuario: %@"), usuario.nombre))
                
                // Lenguajes del usuario, si existen
                if !usuario.lenguajes.isEmpty {
                    let lenguajesString = usuario.lenguajes
                        .map { NSLocalizedString($0.rawValue, comment: "Nombre de lenguaje") }
                        .joined(separator: ", ")
                    Text(String(format: NSLocalizedString("user_languages_format", comment: "Lenguajes: %@"), lenguajesString))
                        .font(.body)
                        .accessibilityLabel(String(format: NSLocalizedString("user_languages_accessibility", comment: "Lenguajes del usuario: %@"), lenguajesString))
                }
                
                // Descripción del usuario, si existe
                if let descripcion = usuario.descripcion, !descripcion.isEmpty {
                    Text(String(format: NSLocalizedString("user_description_format", comment: "Descripción: %@"), descripcion))
                        .font(.body)
                        .accessibilityLabel(String(format: NSLocalizedString("user_description_accessibility", comment: "Descripción del usuario: %@"), descripcion))
                }
                
                // Mensaje de la solicitud
                if let mensaje = solicitud.mensaje, !mensaje.isEmpty {
                    Text(String(format: NSLocalizedString("request_message_format", comment: "Mensaje: %@"), mensaje))
                        .font(.body)
                        .padding(.top, 8)
                        .accessibilityLabel(String(format: NSLocalizedString("request_message_accessibility", comment: "Mensaje del usuario: %@"), mensaje))
                }
                
                Spacer()
                
                // Botones para aprobar o rechazar
                HStack(spacing: 16) {
                    Button(action: {
                        onDecision(true)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(NSLocalizedString("approve_request", comment: "Aprobar"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .accessibilityLabel(NSLocalizedString("approve_request_accessibility", comment: "Aprobar solicitud"))
                    .accessibilityHint(NSLocalizedString("approve_request_hint", comment: "Acepta la solicitud de participación"))
                    
                    Button(action: {
                        onDecision(false)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(NSLocalizedString("reject_request", comment: "Rechazar"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .accessibilityLabel(NSLocalizedString("reject_request_accessibility", comment: "Rechazar solicitud"))
                    .accessibilityHint(NSLocalizedString("reject_request_hint", comment: "Rechaza la solicitud de participación"))
                }
            }
            .padding()
            .navigationBarTitle(NSLocalizedString("request_nav_title", comment: "Título de la navegación"), displayMode: .inline)
            // Botón para cerrar la vista
            .navigationBarItems(trailing: Button(NSLocalizedString("close", comment: "Cerrar")) {
                presentationMode.wrappedValue.dismiss()
            }
            .accessibilityLabel(NSLocalizedString("close_request_view_accessibility", comment: "Cerrar la vista de solicitud"))
            .accessibilityHint(NSLocalizedString("close_request_view_hint", comment: "Regresa a la pantalla anterior")))
        }
        // Evita cierre interactivo con swipe mientras se procesa la acción
        .interactiveDismissDisabled(true)
    }
}
