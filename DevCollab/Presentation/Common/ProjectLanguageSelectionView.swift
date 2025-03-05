import SwiftUI

// MARK: - Vista de Selección de Lenguajes (Internacionalizada)
struct ProjectLanguageSelectionView: View {
    @Binding var seleccionLenguajes: [LenguajeProgramacion]
    @State private var showLanguageSheet = false

    var body: some View {
        Button(action: {
            showLanguageSheet = true
        }) {
            HStack {
                Text(seleccionLenguajes.isEmpty
                     ? NSLocalizedString("select_languages", comment: "Placeholder para seleccionar lenguajes")
                     : seleccionLenguajes.map { NSLocalizedString($0.rawValue, comment: "Nombre del lenguaje") }.joined(separator: ", "))
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
        .accessibilityLabel(NSLocalizedString("select_languages", comment: "Etiqueta de accesibilidad para seleccionar lenguajes"))
        .accessibilityHint(NSLocalizedString("select_languages_hint", comment: "Hint para abrir la lista de lenguajes de programación"))
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
                .navigationTitle(NSLocalizedString("programming_languages", comment: "Título para la lista de lenguajes"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(NSLocalizedString("done", comment: "Botón para confirmar selección")) {
                            showLanguageSheet = false
                        }
                        .accessibilityLabel(NSLocalizedString("done", comment: "Etiqueta de accesibilidad para botón de confirmación"))
                        .accessibilityHint(NSLocalizedString("close_languages_list", comment: "Hint para cerrar la lista de lenguajes"))
                    }
                }
            }
        }
    }
}

// MARK: - Fila de Selección Múltiple (renombrada)
// MARK: - Fila de Selección Múltiple (Internacionalizada)
struct ProjectMultipleSelectionRow: View {
    var lenguaje: LenguajeProgramacion
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(NSLocalizedString(lenguaje.rawValue, comment: "Nombre del lenguaje de programación"))
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
        .accessibilityLabel(NSLocalizedString(lenguaje.rawValue, comment: "Nombre del lenguaje de programación"))
        .accessibilityHint(isSelected
            ? NSLocalizedString("selected_language_hint", comment: "Lenguaje seleccionado")
            : NSLocalizedString("unselected_language_hint", comment: "Lenguaje no seleccionado"))
    }
}
