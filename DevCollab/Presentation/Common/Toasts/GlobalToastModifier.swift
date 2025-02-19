import SwiftUI

struct GlobalToastModifier: ViewModifier {
    @EnvironmentObject var toastManager: ToastManager

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if let message = toastManager.message {
                ToastView(message: message)
                    .id(message)  // Forzamos que cada mensaje se trate como una vista nueva
                    .padding(.horizontal)
                    .padding(.top, 50)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: toastManager.message)
    }
}

extension View {
    func globalToast() -> some View {
        self.modifier(GlobalToastModifier())
    }
}
