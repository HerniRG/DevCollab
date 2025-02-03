import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    let auth: Auth
    let firestore: Firestore
    
    private init() {
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
    }
}
