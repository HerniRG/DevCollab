import Foundation
import SwiftUI

final class ToastManager: ObservableObject {
    @Published var message: String? = nil

    func showToast(_ message: String, duration: Double = 2.5) {
        DispatchQueue.main.async {
            withAnimation {
                self.message = message
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if self.message == message {
                withAnimation {
                    self.message = nil
                }
            }
        }
    }
}
