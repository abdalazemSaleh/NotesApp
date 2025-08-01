import Foundation

enum LocalizationFiles: String {
    case MainApp
    
    init(rawValue: String) {
        switch rawValue {
        case "MainApp": self = .MainApp
        default: self = .MainApp
        }
    }
}

let currentLanguage = Locale.current.language.languageCode?.identifier
