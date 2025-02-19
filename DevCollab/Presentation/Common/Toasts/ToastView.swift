import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            // Use a system material for a blur-like effect
            .background(.regularMaterial)
            .cornerRadius(8)
            .shadow(radius: 4)
    }
}
