//
//  AuthViewModel.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 30/05/2023.
//

import UIKit

class AuthViewModel {
    
    let networkService = NetworkService.shared()
    let tokenManager = TokenManager()
    
    var error: UIAlertController?
    
    let emailSent: ObservableObject<Bool> = ObservableObject(false)
    let tokensReceived: ObservableObject<Bool> = ObservableObject(false)
    
    private var email: String!
    
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
}
