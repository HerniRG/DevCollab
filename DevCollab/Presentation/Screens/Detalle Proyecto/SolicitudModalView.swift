import SwiftUI

struct SolicitudModalView: View {
    let proyectoID: String
    var onSubmit: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var mensaje: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Escribe un mensaje explicando por qué deseas participar:")
                    .padding()
                    // Accesibilidad
                    .accessibilityLabel("Instrucción para el mensaje")
                    .accessibilityHint("Describe tus motivaciones y habilidades para unirte al proyecto")
                
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
                        .accessibilityLabel("Mensaje de solicitud")
                        .accessibilityHint("Explica las razones para participar en este proyecto")
                    
                    // Placeholder (si está vacío). Lo ocultamos de VoiceOver con .accessibilityHidden(true)
                    if mensaje.isEmpty {
                        Text("Escribe aquí tu motivación...")
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
                    Text("Solicitud de Participación")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .accessibilityLabel("Solicitud de participación")
                }
                
                // Botón para cerrar (Cancelar)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .accessibilityLabel("Cancelar envío")
                    .accessibilityHint("Cierra el formulario sin enviar la solicitud")
                }
                
                // Botón para enviar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enviar") {
                        let msg = mensaje.trimmingCharacters(in: .whitespacesAndNewlines)
                        // Solo enviamos si no está vacío
                        if !msg.isEmpty {
                            onSubmit(msg)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(mensaje.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Enviar solicitud")
                    .accessibilityHint("Envía el mensaje de motivación al creador del proyecto")
                }
            }
        }
        // Evita que se cierre con un swipe si no se ha pulsado algún botón
        .interactiveDismissDisabled(true)
    }
}
