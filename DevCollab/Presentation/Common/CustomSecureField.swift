// 🔹 COMPONENTE PARA TEXTFIELD DE CONTRASEÑA
struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var isPasswordVisible: Bool
    
    var body: some View {
        HStack {
            if isPasswordVisible {
                TextField(placeholder, text: $text)
            } else {
                SecureField(placeholder, text: $text)
            }
            
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(height: 50) // 🔥 Asegura altura uniforme
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
