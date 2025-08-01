import Foundation

public enum Environment {
    enum Keys {
        static let baseUrl =  "BASE_URL"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist file not found")
        }
        return dict
    }()
    
    static let baseUrl: String = {
        guard let url = Environment.infoDictionary[Keys.baseUrl] as? String else {
            fatalError("Missing base url in info.plist")
        }
        return url
    }()
}
