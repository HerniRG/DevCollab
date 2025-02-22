import SwiftUI

// MARK: - Vista de Selección de Lenguajes (renombrada)
struct ProjectLanguageSelectionView: View {
    @Binding var seleccionLenguajes: [LenguajeProgramacion]
    @State private var showLanguageSheet = false

    var body: some View {
        Button(action: {
            showLanguageSheet = true
        }) {
            HStack {
                Text(seleccionLenguajes.isEmpty
                     ? "Seleccionar lenguajes"
                     : seleccionLenguajes.map { $0.rawValue }.joined(separator: ", "))
                    .foregroundColor(seleccionLenguajes.isEmpty ? .gray : .primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .accessibilityHidden(true) // icono decorativo
            }
            .padding(8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
        .accessibilityLabel("Seleccionar lenguajes")
        .accessibilityHint("Abre la lista para elegir lenguajes de programación")
        .sheet(isPresented: $showLanguageSheet) {
            NavigationView {
                List {
                    ForEach(LenguajeProgramacion.allCases, id: \.self) { lenguaje in
                        ProjectMultipleSelectionRow(
                            lenguaje: lenguaje,
                            isSelected: seleccionLenguajes.contains(lenguaje),
                            action: {
                                if seleccionLenguajes.contains(lenguaje) {
                                    seleccionLenguajes.removeAll { $0 == lenguaje }
                                } else {
                                    seleccionLenguajes.append(lenguaje)
                                }
                            }
                        )
                    }
                }
                .navigationTitle("Lenguajes de Programación")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Hecho") {
                            showLanguageSheet = false
                        }
                        .accessibilityLabel("Hecho")
                        .accessibilityHint("Cierra la lista de lenguajes")
                    }
                }
            }
        }
    }
}

// MARK: - Fila de Selección Múltiple (renombrada)
struct ProjectMultipleSelectionRow: View {
    var lenguaje: LenguajeProgramacion
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(lenguaje.rawValue)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(lenguaje.rawValue)
        .accessibilityHint(isSelected ? "Seleccionado. Pulsa para deseleccionar" : "No seleccionado. Pulsa para seleccionar")
    }
}
