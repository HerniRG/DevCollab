import TipKit

struct ProfileTip: Tip {
    var id: String = "ProfileTip"

    var title: Text {
        Text(NSLocalizedString("profile_tip_title", comment: "Perfil"))
    }

    var message: Text? {
        Text(NSLocalizedString("profile_tip_message", comment: "Aquí puedes ver y editar tu información de perfil."))
    }

    var image: Image? {
        Image(systemName: "person.crop.circle")
    }
}

struct ProjectsTip: Tip {
    var id: String = "ProjectsTip"

    var title: Text {
        Text(NSLocalizedString("projects_tip_title", comment: "Exploración de Proyectos"))
    }

    var message: Text? {
        Text(NSLocalizedString("projects_tip_message", comment: "Aquí puedes ver tus proyectos creados, en los que participas y proyectos abiertos para unirte."))
    }

    var image: Image? {
        Image(systemName: "rectangle.stack.badge.person.crop")
    }
}

struct CreateProjectTip: Tip {
    var id: String = "CreateProjectTip"

    var title: Text {
        Text(NSLocalizedString("create_project_tip_title", comment: "Crear Proyecto"))
    }

    var message: Text? {
        Text(NSLocalizedString("create_project_tip_message", comment: "Este botón te permite crear un nuevo proyecto."))
    }

    var image: Image? {
        Image(systemName: "plus")
    }
}
