import SwiftUI

struct SolicitudModalView: View {
    let proyectoID: String
    var onSubmit: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var mensaje: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Instrucción para el mensaje
                Text(NSLocalizedString("participation_message_instructions", comment: "Instrucción para redactar la solicitud"))
                    .padding()
                    .accessibilityLabel(NSLocalizedString("participation_message_instructions_accessibility", comment: "Accesibilidad: Describe por qué deseas participar"))
                    .accessibilityHint(NSLocalizedString("participation_message_instructions_hint", comment: "Explica tus motivaciones y habilidades para unirte al proyecto"))

                // Campo de texto (TextEditor) para redactar la solicitud
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $mensaje)
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        // Accesibilidad
                        .accessibilityLabel(NSLocalizedString("request_message_field", comment: "Mensaje de solicitud"))
                        .accessibilityHint(NSLocalizedString("request_message_field_hint", comment: "Describe las razones para participar en este proyecto"))
                    
                    // Placeholder (solo visible si está vacío). Lo ocultamos de VoiceOver
                    if mensaje.isEmpty {
                        Text(NSLocalizedString("request_message_placeholder", comment: "Placeholder: Escribe aquí tu motivación..."))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 18)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                }
                .padding(.bottom, 16)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Título principal
                ToolbarItem(placement: .principal) {
                    Text(NSLocalizedString("participation_request_title", comment: "Solicitud de Participación"))
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .accessibilityLabel(NSLocalizedString("participation_request_title_accessibility", comment: "Accesibilidad: Solicitud de participación"))
                }
                
                // Botón para cerrar (Cancelar)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel_button", comment: "Cancelar")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .accessibilityLabel(NSLocalizedString("cancel_button_accessibility", comment: "Cerrar sin enviar"))
                    .accessibilityHint(NSLocalizedString("cancel_button_hint", comment: "Cierra el formulario sin enviar la solicitud"))
                }
                
                // Botón para enviar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("send_button", comment: "Enviar")) {
                        let msg = mensaje.trimmingCharacters(in: .whitespacesAndNewlines)
                        // Solo enviamos si no está vacío
                        if !msg.isEmpty {
                            onSubmit(msg)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(mensaje.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel(NSLocalizedString("send_button_accessibility", comment: "Enviar solicitud"))
                    .accessibilityHint(NSLocalizedString("send_button_hint", comment: "Envía el mensaje al creador del proyecto"))
                }
            }
        }
        // Evita que se cierre con un swipe si no se ha pulsado algún botón
        .interactiveDismissDisabled(true)
    }
}
