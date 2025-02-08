import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class PerfilViewModel: ObservableObject {
    @Published var usuario: Usuario?
    @Published var proyectosCreados: [Proyecto] = []
    @Published var proyectosParticipando: [Proyecto] = []
    @Published var solicitudes: [Solicitud] = []
    
    // Para feedback (errores y éxito) en la edición del perfil
    @Published var errorMessage: String? = nil
    @Published var isProfileUpdated: Bool = false
    
    private let authRepository: AuthRepository
    private let proyectoRepository: ProyectoRepository
    private let solicitudRepository: SolicitudRepository
    private let updatePerfilUseCase: UpdatePerfilUseCase
    
    // Para operaciones directas en Firestore (si fuera necesario)
    private let db = Firestore.firestore()
    
    init(authRepository: AuthRepository,
         proyectoRepository: ProyectoRepository,
         solicitudRepository: SolicitudRepository,
         updatePerfilUseCase: UpdatePerfilUseCase) {
        self.authRepository = authRepository
        self.proyectoRepository = proyectoRepository
        self.solicitudRepository = solicitudRepository
        self.updatePerfilUseCase = updatePerfilUseCase
        
        fetchUserProfile()
    }
    
    // MARK: - Cargar Perfil y Proyectos
    func fetchUserProfile() {
        Task {
            do {
                if let user = try await authRepository.getCurrentUser() {
                    DispatchQueue.main.async {
                        self.usuario = user
                    }
                    fetchUserProjects(userID: user.id)
                    fetchSolicitudes(usuarioID: user.id)
                }
            } catch {
                print("Error al obtener perfil: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchUserProjects(userID: String) {
        Task {
            do {
                let proyectos = try await proyectoRepository.obtenerProyectos()
                DispatchQueue.main.async {
                    self.proyectosCreados = proyectos.filter { $0.creadorID == userID }
                    self.updateProyectosParticipando(userID: userID, allProjects: proyectos)
                }
            } catch {
                print("Error al obtener proyectos: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchSolicitudes(usuarioID: String) {
        Task {
            do {
                let solicitudes = try await solicitudRepository.obtenerSolicitudes(usuarioID: usuarioID)
                DispatchQueue.main.async {
                    self.solicitudes = solicitudes
                    if let userID = self.usuario?.id {
                        let proyectos = self.proyectosCreados + self.proyectosParticipando
                        self.updateProyectosParticipando(userID: userID, allProjects: proyectos)
                    }
                }
            } catch {
                print("Error al obtener solicitudes: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateProyectosParticipando(userID: String, allProjects: [Proyecto]) {
        let participando = allProjects.filter { proyecto in
            proyecto.creadorID != userID &&
            self.solicitudes.contains { solicitud in
                solicitud.proyectoID == proyecto.id && solicitud.estado == "Aceptada"
            }
        }
        DispatchQueue.main.async {
            self.proyectosParticipando = participando
        }
    }
    
    // MARK: - Borrar Proyecto
    func deleteProject(proyecto: Proyecto) {
        Task {
            do {
                try await proyectoRepository.eliminarProyecto(proyectoID: proyecto.id)
                DispatchQueue.main.async {
                    self.proyectosCreados.removeAll { $0.id == proyecto.id }
                    self.proyectosParticipando.removeAll { $0.id == proyecto.id }
                }
            } catch {
                print("Error al borrar proyecto: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Actualizar Perfil usando UpdatePerfilUseCase
    func updateUserProfile(nombre: String,
                           descripcion: String,
                           lenguajes: [LenguajeProgramacion]) {
        let maxNombreLength = 25
        let maxDescripcionLength = 150
        
        if nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "El nombre no puede estar vacío."
            }
            return
        }
        if nombre.count > maxNombreLength {
            DispatchQueue.main.async {
                self.errorMessage = "El nombre excede los \(maxNombreLength) caracteres."
            }
            return
        }
        if descripcion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "La descripción no puede estar vacía."
            }
            return
        }
        if descripcion.count > maxDescripcionLength {
            DispatchQueue.main.async {
                self.errorMessage = "La descripción excede los \(maxDescripcionLength) caracteres."
            }
            return
        }
        if lenguajes.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Selecciona al menos un lenguaje."
            }
            return
        }
        
        guard let userID = usuario?.id else {
            print("No hay usuario para actualizar")
            return
        }
        
        Task {
            do {
                try await updatePerfilUseCase.execute(
                    userID: userID,
                    nombre: nombre,
                    descripcion: descripcion,
                    lenguajes: lenguajes
                )
                DispatchQueue.main.async {
                    self.usuario = Usuario(
                        id: userID,
                        nombre: nombre,
                        lenguajes: lenguajes,
                        descripcion: descripcion.isEmpty ? nil : descripcion
                    )
                    self.errorMessage = nil
                    self.isProfileUpdated = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.isProfileUpdated = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error al actualizar el perfil: \(error.localizedDescription)"
                }
            }
        }
    }
}
