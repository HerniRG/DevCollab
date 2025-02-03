class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func checkInternetConnection() -> Bool {
        // Aquí se podría implementar Reachability para verificar conexión a internet.
        return true
    }
}
