//
//  AuthViewModel.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 30/05/2023.
//

import UIKit

class AuthViewModel {
    
    private (set) var networkService: NetworkServiceProtocol!
    private (set) var tokenManager: TokenManageable!
    
    private (set) var error: UIAlertController?
    
    let emailSent: ObservableObject<Bool> = ObservableObject(false)
    let tokensReceived: ObservableObject<Bool> = ObservableObject(false)
    
    private var email: String?
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared(), tokenManager: TokenManageable = TokenManager()) {
        self.networkService = networkService
        self.tokenManager = tokenManager
    }
    
    func sendEmail(email: String) {
        let emailBody = EmailBody(email: email)
        networkService.sendEmail(emailBody: emailBody) { [weak self] result in
            switch result {
            case .success(_):
                self?.email = email
                self?.emailSent.value = true
            case .authError(let error):
                self?.error = ErrorAlert.buildForError(message: error.message)
            case .networkError(_):
                self?.error = ErrorAlert.networkError()
            case .serverError(let error):
                self?.error = ErrorAlert.buildForError(message: error.message)
            case .encodingError:
                self?.error = ErrorAlert.encodingError()
            }
        }
    }
    
    func getTokens(code: String) {
        guard let email else { return }
        let codeBody = VerificationCodeBody(email: email, code: code)
        networkService.sendVerificationCode(codeBody: codeBody) { [weak self] result in
            switch result {
            case .success(let tokens):
                self?.tokensReceived.value = true
                self?.tokenManager.updateTokens(tokens)
            case .authError(let error):
                self?.error = ErrorAlert.buildForError(message: error.message)
            case .networkError(_):
                self?.error = ErrorAlert.networkError()
            case .serverError(let error):
                self?.error = ErrorAlert.buildForError(message: error.message)
            case .encodingError:
                self?.error = ErrorAlert.encodingError()
            }
        }
    }
    
    func validateEmail(_ text: String?) -> (Bool, String) {
        guard let text = text, !text.isEmpty else {
            return (false, "Please enter your email address")
        }
        
        if !text.isValidEmail {
            return (false, "Please enter a valid email address")
        }
        return (true, "")
    }
    
    func validateCode(_ text: String?) -> (Bool, String) {
        guard let text = text, !text.isEmpty else {
            return (false, "Please enter your verification code")
        }
        
        if Int(text) == nil, text.count != 6 {
            return (false, "Please enter a valid verification code")
        }
        return (true, "")
    }
}

// MARK: Unit testing
extension AuthViewModel {
    var emailForTesting: String? {
        return email
    }
}
