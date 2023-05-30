//
//  NetworkService.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    
    private let tokenManager = TokenManager()
    
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
            request.addValue("Bearer \(tokenManager.refreshToken.token)", forHTTPHeaderField: "Authorization")
        } else if !tokenManager.accessToken.token.isEmpty && !ignoreJwtAuth {
            request.addValue("Bearer \(tokenManager.accessToken.token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    private func buildRefreshTokenRequest() -> URLRequest {
        return buildRequest(url: Endpoint.auth(.refreshToken).absoluteURL, refreshTokens: true)
    }
    
    private var needReAuth: Bool {
        // request new access token if time delta is empty
        guard let timeDelta = tokenManager.timeDelta else { return true }
        let now = Date().timeIntervalSinceReferenceDate
        
        return (tokenManager.accessToken.expiresAt - now + timeDelta) > 0
    }
    
    private func renewAuthHeader(request: URLRequest) -> URLRequest {
        var newRequest = request
        newRequest.setValue("Bearer \(tokenManager.accessToken.token)", forHTTPHeaderField: "Authorization")
        return newRequest
    }
    
    func request<T: Decodable>(request: URLRequest, completionHandler: @escaping (Result<T>) -> Void) {
        if needReAuth && !tokenManager.refreshToken.token.isEmpty {
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
                    completionHandler(.authError(ErrorResponse(code: 0, message: Errors.errorConvertingToHttpResponse)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(.authError(ErrorResponse(code: httpResponse.statusCode, message: Errors.errorNilBody)))
                }
                return
            }
            
            if httpResponse.isSuccessful() {
                do {
                    let response = try JSONDecoder().decode(TokensInfo.self, from: data)
                    self.tokenManager.updateTokens(response)
                    let newRequest = self.renewAuthHeader(request: request)
                    self.doRequest(request: newRequest, completionHandler: completionHandler)
                    return
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(.authError(ErrorResponse(code: 0, message: Errors.errorParsingResponse)))
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
                        completionHandler(.authError(ErrorResponse(code: 0, message: Errors.errorParsingErrorResponse)))
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
                    completionHandler(.networkError(error.localizedDescription))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completionHandler(.networkError(Errors.errorConvertingToHttpResponse))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(.serverError(ErrorResponse(code: httpResponse.statusCode, message: Errors.errorNilBody)))
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
            return .serverError(ErrorResponse(code: 0, message: Errors.errorParsingErrorResponse))
        }
    }
    
    func sendEmail(emailBody: EmailBody, completionHandler: @escaping (Result<SuccessResponse>) -> Void) {
        let url = Endpoint.auth(.sendEmail).absoluteURL
        let body = try! JSONEncoder().encode(emailBody)  //TODO: handle serialization error
        let request = buildRequest(url: url, data: body, method: Method.POST.rawValue, ignoreJwtAuth: true)
        doRequest(request: request, completionHandler: completionHandler)
    }
    
    func sendVerificationCode(codeBody: VerificationCodeBody, completionHandler: @escaping (Result<TokensInfo>) -> Void) {
        let url = Endpoint.auth(.sendVerificationCode).absoluteURL
        let body = try! JSONEncoder().encode(codeBody) //TODO: handle serialization error
        let request = buildRequest(url: url, data: body, method: Method.POST.rawValue, ignoreJwtAuth: true)
        doRequest(request: request, completionHandler: completionHandler)
    }
}
