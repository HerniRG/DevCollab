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
                TextEditor(text: $mensaje)
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding()
                Spacer()
            }
            .navigationTitle("Solicitud de Participación")
            .navigationBarItems(leading: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Enviar") {
                onSubmit(mensaje)
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(mensaje.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
        }
        .interactiveDismissDisabled(true)
    }
}
