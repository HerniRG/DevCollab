import SwiftUI

struct CrearProyectoView: View {
    @ObservedObject var viewModel: CrearProyectoViewModel
    @State private var nombre: String = ""
    @State private var descripcion: String = ""
    @State private var lenguajes: String = ""
    @State private var horasSemanales: String = ""
    @State private var tipoColaboracion: String = ""
    @State private var estado: String = "Abierto"
    
    var body: some View {
        VStack {
            Text("Crear Proyecto").font(.largeTitle).bold()
            TextField("Nombre del proyecto", text: $nombre)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Descripción", text: $descripcion)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Lenguajes (separados por coma)", text: $lenguajes)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Horas Semanales", text: $horasSemanales)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Tipo de Colaboración", text: $tipoColaboracion)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                let proyecto = Proyecto(
                    id: UUID().uuidString,
                    nombre: nombre,
                    descripcion: descripcion,
                    lenguajes: lenguajes.split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .compactMap { LenguajeProgramacion(rawValue: $0) },
                    horasSemanales: Int(horasSemanales) ?? 0,
                    tipoColaboracion: tipoColaboracion,
                    estado: estado,
                    creadorID: "UserIDPlaceholder"
                )
                viewModel.crearProyecto(proyecto: proyecto)
            }) {
                Text("Crear Proyecto")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            if viewModel.isSuccess {
                Text("Proyecto creado exitosamente").foregroundColor(.green)
            }
        }
        .padding()
    }
}
