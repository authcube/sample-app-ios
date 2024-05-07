import UIKit
import Security

import AppAuthCore

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // property of the app's AppDelegate
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    private var authState: OIDAuthState?
    private var tokenDecoded: [String: Any]?
    
    override init() {
        super.init()
        
        if let savedAuthState = getAuthStateFromKeychain() {
            authState = savedAuthState
            decodeToken()
            print("*** AppDelegate INIT: isAuthorized -> \(String(describing: authState?.isAuthorized))")
            print("*** AppDelegate INIT: isAuthorized -> \(String(describing: authState?.lastTokenResponse?.accessTokenExpirationDate))")
            print("*** AppDelegate INIT: Date now is: \(Date())")
            
            self.authState?.setNeedsTokenRefresh()
            print("*** AppDelegate INIT: isAuthorized -> \(String(describing: authState))")
            
            if let accessTokenExpirationDate = authState?.lastTokenResponse?.accessTokenExpirationDate,
               accessTokenExpirationDate > Date() {
                // Token de acesso ainda é válido
                print("*** AppDelegate INIT: Token de acesso ainda é válido")
            } else {
                // Token de acesso expirou ou não está disponível
                print("*** AppDelegate INIT: Token de acesso expirou ou não está disponível")
                self.authState?.setNeedsTokenRefresh()
                print("*** AppDelegate INIT: isAuthorized -> \(String(describing: authState))")
            }
            
//            checkTokenValidity(authState: authState!) { isAccessTokenValid, isRefreshTokenAvailable in
//                print("Validade do Token de Acesso: \(isAccessTokenValid)")
//                print("Disponibilidade do Token de Refresh: \(isRefreshTokenAvailable)")
//                
//                if !isRefreshTokenAvailable {
//                    self.authState = nil
//                    self.deleteAuthStateFromKeychain()
//                } else {
//                    print("try to refresh token")
//                }
//            }

            
        } else {
            print("*** AppDelegate INIT: impossible to load last State ***")
        }
        
        print("*** AppDelegate INIT ***")
        
    }
    
    func setAuthState(_ _authState: OIDAuthState?) {
        self.authState = _authState
        saveAuthStateToKeychain(authState: _authState!)
        decodeToken()
    }
    
    func getAuthState() -> OIDAuthState? {
        return self.authState
    }
    
    func isAuthorized() -> Bool {
        let _authState = self.getAuthState()
        return _authState != nil && _authState!.isAuthorized && _authState!.refreshToken != nil
    }
    
    func getUsername() -> String {
        
        guard let tk = self.tokenDecoded else {
            print("Token vazio")
            return ""
        }
        
        if let uid: String = AppSample.value(from: tk, forKey: "uid") {
            return uid
        } else {
            return ""
        }
    }
    
    func decodeToken() {
        if let _accessToken = self.getAuthState() {
            
            let atk = _accessToken.lastTokenResponse!.accessToken!
            
            if let decoded = decodeJWT(atk) {
                self.tokenDecoded = decoded
//                print("decoded: \(decoded)")
            } else {
                // Tratar caso em que o token não pode ser decodificado
                print("Failed to decode JWT")
                self.tokenDecoded = [:]
            }
        } else {
            // Tratar caso em que o accessToken não está disponível
            self.tokenDecoded = [:]
        }
    }
    
    func viewWillDisappear(_: Bool) {
        print("func viewWillDisappear(Bool)")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("func applicationWillTerminate(_ application: UIApplication)")
    }
    
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Sends the URL to the current authorization flow (if any) which will
        // process it if it relates to an authorization response.
        if let authorizationFlow = self.currentAuthorizationFlow,
           authorizationFlow.resumeExternalUserAgentFlow(with: url) {
            self.currentAuthorizationFlow = nil
            return true
        }
        
        // Your additional URL handling (if any)
        
        return false
    }
    
    // Keychain
    let keychainServiceName = "com.example.myapp.auth"
    // Função para salvar o OIDAuthState no Keychain
    func saveAuthStateToKeychain(authState: OIDAuthState) {
        do {
            // Converta o OIDAuthState em Data
            let data = try NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: true)
            
            // Configure a query para adicionar dados ao Keychain
            var query = [String: Any]()
            query[kSecClass as String] = kSecClassGenericPassword
            query[kSecAttrService as String] = keychainServiceName
            query[kSecAttrAccount as String] = "AuthState"
            query[kSecValueData as String] = data
            
            // Remova quaisquer dados existentes antes de adicionar os novos dados
            SecItemDelete(query as CFDictionary)
            
            // Adicione os dados ao Keychain
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else {
                throw KeychainError.unhandledError(status: status)
            }
        } catch {
            print("Erro ao salvar o estado de autenticação no Keychain: \(error.localizedDescription)")
        }
    }
    
    // Função para recuperar o OIDAuthState do Keychain
    func getAuthStateFromKeychain() -> OIDAuthState? {
        var query = [String: Any]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = keychainServiceName
        query[kSecAttrAccount as String] = "AuthState"
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            print("Erro ao recuperar o estado de autenticação do Keychain: \(String(describing: SecCopyErrorMessageString(status, nil)))")
            return nil
        }
        
        do {
            // Converta os dados de volta para OIDAuthState
            if let authState = try NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data) {
                return authState
            } else {
                print("Erro ao deserializar o estado de autenticação do Keychain.")
                return nil
            }
        } catch {
            print("Erro ao recuperar o estado de autenticação do Keychain: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Função para excluir o OIDAuthState do Keychain
    func deleteAuthStateFromKeychain() {
        var query = [String: Any]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = keychainServiceName
        query[kSecAttrAccount as String] = "AuthState"
        
        // Exclua os dados do Keychain
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            print("Erro ao excluir o estado de autenticação do Keychain: \(String(describing: SecCopyErrorMessageString(status, nil)))")
            return
        }
    }
    
    enum KeychainError: Error {
        case unhandledError(status: OSStatus)
    }
}

func value<T>(from dictionary: [String: Any], forKey key: String) -> T? {
    return dictionary[key] as? T
}
