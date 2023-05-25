//
//  NetworkService.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

class NetworkService {
    
    private static var instance: NetworkService!
    
    private let accessTokenLifeSeconds = 5 * 60
    
    private let storageManager: StorageManageable!
    
    private var accessToken: TokenInfo
    private var refreshToken: TokenInfo
    
    private init(storageManager: StorageManageable) {
        self.storageManager = storageManager
        
        accessToken = storageManager.getAccessToken()
        refreshToken = storageManager.getRefreshToken()
    }
    
    static func shared(storageManager: StorageManageable = UserDefaultsManager()) -> NetworkService {
        if instance == nil {
            instance = NetworkService(storageManager: storageManager)
        }
        return instance
    }
    
    private func updateTokens(_ tokens: TokensInfo) {
        storageManager.saveAuthTokens(tokens: tokens)
        accessToken = TokenInfo(token: tokens.accessToken, expiresAt: tokens.accessTokenExpire)
        refreshToken = TokenInfo(token: tokens.refreshToken, expiresAt: tokens.refreshTokenExpire)
    }
    
    func dropTokens() {
        accessToken = TokenInfo(token: "", expiresAt: 0)
        refreshToken = TokenInfo(token: "", expiresAt: 0)
    }
    
    private func buildRequest(url: URL,
                              data: Data = Data(),
                              method: String = "POST",
                              contentType: String = "application/json",
                              refreshTokens: Bool = false,
                              ignoreJwtAuth: Bool = false) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        if refreshTokens {
            request.addValue("Bearer \(refreshToken.token)", forHTTPHeaderField: "Authorization")
        } else if !accessToken.token.isEmpty && !ignoreJwtAuth {
            request.addValue("Bearer \(accessToken.token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    private func buildRefreshTokenRequest() -> URLRequest {
        return buildRequest(url: Endpoint.refreshToken.absoluteURL, refreshTokens: true)
    }
    
    private var needReAuth: Bool {
        //TODO: get server time and compare with access token expire
        return true
    }
    
    private func renewAuthHeader(request: URLRequest) -> URLRequest {
        var newRequest = request
        newRequest.setValue("Bearer \(accessToken.token)", forHTTPHeaderField: "Authorization")
        return newRequest
    }
    
    func request<T: Decodable>(request: URLRequest, completionHandler: @escaping (Result<T>) -> Void) {
        if needReAuth && !refreshToken.token.isEmpty {
            authAndDoRequest(request: request, completionHandler: completionHandler)
        } else {
            doRequest(request: request, completionHandler: completionHandler)
        }
    }
    
    func authAndDoRequest<T: Decodable>(request: URLRequest, completionHandler: @escaping (Result<T>) -> Void) {
        let refreshToken = buildRefreshTokenRequest()
        URLSession.shared.dataTask(with: refreshToken) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completionHandler(.networkError(error.localizedDescription))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completionHandler(.authError(ErrorResponse(code: 0, message: "Some error")))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(.authError(ErrorResponse(code: httpResponse.statusCode, message: "some error")))
                }
                return
            }
            
            if httpResponse.isSuccessful() {
                do {
                    let response = try JSONDecoder().decode(TokensInfo.self, from: data)
                    self.updateTokens(response)
                    let newRequest = self.renewAuthHeader(request: request)
                    self.doRequest(request: newRequest, completionHandler: completionHandler)
                    return
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(.authError(ErrorResponse(code: 0, message: "some error")))
                    }
                    return
                }
                    
            } else {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(.authError(errorResponse))
                    }
                    return
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(.authError(ErrorResponse(code: 0, message: "Some error")))
                    }
                    return
                }
            }
        }.resume()
    }
    
    func doRequest<T: Decodable>(request: URLRequest, completionHandler: @escaping (Result<T>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    //TODO: errors classification
                    completionHandler(.networkError(error.localizedDescription))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completionHandler(.networkError("some description"))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(.serverError(ErrorResponse(code: httpResponse.statusCode, message: "some message")))
                }
                return
            }
            
            if httpResponse.isSuccessful() {
                let responseBody: Result<T> = self.parseResponse(data: data)
                DispatchQueue.main.async {
                    completionHandler(responseBody)
                }
            } else {
                let responseBody: Result<T> = self.parseError(data: data)
                DispatchQueue.main.async {
                    completionHandler(responseBody)
                }
            }
        }.resume()
    }
    
    private func parseResponse<T: Decodable>(data: Data) -> Result<T> {
        do {
            return try .success(JSONDecoder().decode(T.self, from: data))
        } catch {
            return parseError(data: data)
        }
    }
    
    private func parseError<T>(data: Data) -> Result<T> {
        do {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            if errorResponse.isAuth() {
                return .authError(errorResponse)
            } else {
                return .serverError(errorResponse)
            }
        } catch {
            return .serverError(ErrorResponse(code: 0, message: "some error"))
        }
    }
    
    
}
