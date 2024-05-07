import AppAuth

func checkTokenValidity(authState: OIDAuthState, completion: @escaping (Bool, Bool) -> Void) {
    // Checa a validade do token de acesso
    if let accessTokenExpirationDate = authState.lastTokenResponse?.accessTokenExpirationDate,
       accessTokenExpirationDate > Date() {
        // Token de acesso ainda é válido
        print("Token de acesso ainda é válido")
    } else {
        // Token de acesso expirou ou não está disponível
        print("Token de acesso expirou ou não está disponível")
    }
    
    // Verifica se o token de refresh está disponível (sua validade não é gerenciada pelo AppAuth e deve ser determinada pelo servidor)
    let hasRefreshToken = authState.refreshToken != nil
    
    // Executar ação com tokens frescos para checar ambos, se necessário
    authState.performAction { accessToken, idToken, error in
        if let error = error {
            print("Erro durante a renovação dos tokens: \(error.localizedDescription)")
            // Falha na renovação dos tokens, possível problema com o token de refresh
            completion(false, false)
        } else if accessToken != nil {
            // Tokens renovados com sucesso
            completion(true, hasRefreshToken)
        } else {
            // Não conseguiu renovar os tokens mesmo sem erros explícitos
            completion(false, hasRefreshToken)
        }
    }
}
