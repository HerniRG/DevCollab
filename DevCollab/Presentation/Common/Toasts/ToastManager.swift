import Foundation
import SwiftUI

/// Un mensaje de Toast con un identificador único
struct ToastMessage: Equatable {
    let id = UUID()
    let text: String
}

final class ToastManager: ObservableObject {
    @Published var currentToast: ToastMessage? = nil

    func showToast(_ message: String, duration: Double = 2.5) {
        DispatchQueue.main.async {
            // Oculta inmediatamente cualquier toast activo
            withAnimation {
                self.currentToast = nil
            }
            // Después de un breve retraso, muestra el nuevo toast
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let newToast = ToastMessage(text: message)
                withAnimation {
                    self.currentToast = newToast
                }
                // Oculta el toast tras la duración establecida, siempre que siga siendo el actual
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    if self.currentToast?.id == newToast.id {
                        withAnimation {
                            self.currentToast = nil
                        }
                    }
                }
            }
        }
    }

    func hideToast() {
        DispatchQueue.main.async {
            withAnimation {
                self.currentToast = nil
            }
        }
    }
}
