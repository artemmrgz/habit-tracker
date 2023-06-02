//
//  AuthenticationViewController.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 26/05/2023.
//

import UIKit

protocol AuthenticationViewControllerDelegate: AnyObject {
    func didAuth()
}

class AuthenticationViewController: UIViewController {
    let emailField = UITextField()
    let codeField = UITextField()
    let sendButton = UIButton()
    
    let stackView = UIStackView()
    
    let authVM = AuthViewModel()
    
    weak var delegate: AuthenticationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
        setupBinders()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let cornerRadius = emailField.bounds.height * 0.2
        
        emailField.layer.cornerRadius = cornerRadius
        codeField.layer.cornerRadius = cornerRadius
        sendButton.layer.cornerRadius = cornerRadius
    }
    
    private func style() {
        view.backgroundColor = .systemBackground
        
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.placeholder = "Email address"
        emailField.layer.borderWidth = 1.5
        emailField.layer.borderColor = UIColor.systemGray2.cgColor
        emailField.setLeftPaddingPoints(16)
      

        codeField.translatesAutoresizingMaskIntoConstraints = false
        codeField.placeholder = "Verification code"
        codeField.isHidden = true
        codeField.layer.borderWidth = 1.5
        codeField.layer.borderColor = UIColor.systemGray2.cgColor
        codeField.setLeftPaddingPoints(16)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = .systemCyan
        sendButton.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
    }
    
    private func layout() {
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(codeField)
        stackView.addArrangedSubview(sendButton)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            emailField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06),
            codeField.heightAnchor.constraint(equalTo: emailField.heightAnchor),
            sendButton.heightAnchor.constraint(equalTo: emailField.heightAnchor)
        ])
    }
    
    private func setupBinders() {
        authVM.emailSent.bind { [weak self] success in
            if !success {
                guard let error = self?.authVM.error else { return }
                self?.present(error, animated: true)
            } else {
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 4) {
                    self?.emailField.isUserInteractionEnabled = false
                    self?.emailField.backgroundColor = .systemGray5
                    self?.codeField.isHidden = false
                }
            }
        }

        authVM.tokensReceived.bind { [weak self] success in
            if !success {
                guard let error = self?.authVM.error else { return }
                self?.present(error, animated: true)
            } else {
                self?.delegate?.didAuth()
            }
        }
    }
    
    @objc func btnTapped(_ sender: UIButton) {
        if !authVM.emailSent.value {
            guard let text = emailField.text else { return }
            let emailText = text.lowercased()
            authVM.sendEmail(email: emailText)
        } else {
            guard let code = codeField.text else { return }
            authVM.getTokens(code: code)
        }
    }
}
