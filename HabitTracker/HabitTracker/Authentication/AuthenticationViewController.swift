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
    let backButton = UIButton()
    
    let errorLabel = UILabel()
    
    let stackView = UIStackView()
    let buttonsStackView = UIStackView()
    
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
        backButton.layer.cornerRadius = cornerRadius
    }
    
    private func style() {
        view.backgroundColor = .systemBackground
        
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.placeholder = "Email address"
        emailField.layer.borderWidth = 1.5
        emailField.layer.borderColor = UIColor.systemGray2.cgColor
        emailField.setLeftPaddingPoints(16)
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingDidBegin)
      

        codeField.translatesAutoresizingMaskIntoConstraints = false
        codeField.placeholder = "Verification code"
        codeField.isHidden = true
        codeField.layer.borderWidth = 1.5
        codeField.layer.borderColor = UIColor.systemGray2.cgColor
        codeField.setLeftPaddingPoints(16)
        codeField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingDidBegin)
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = .systemRed
        errorLabel.isHidden = true
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = .systemCyan
        sendButton.addTarget(self, action: #selector(sendBtnTapped), for: .touchUpInside)
        sendButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back", for: .normal)
        backButton.backgroundColor = .systemRed
        backButton.addTarget(self, action: #selector(backBtnTapped), for: .touchUpInside)
        backButton.isHidden = true
        backButton.alpha = 0
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.spacing = 8
    }
    
    private func layout() {
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(codeField)
        stackView.addArrangedSubview(errorLabel)
        buttonsStackView.addArrangedSubview(sendButton)
        buttonsStackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(buttonsStackView)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            emailField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06),
            codeField.heightAnchor.constraint(equalTo: emailField.heightAnchor),
            buttonsStackView.heightAnchor.constraint(equalTo: emailField.heightAnchor),
            backButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.2),
        ])
    }
    
    private func setupBinders() {
        authVM.emailSent.bind { [weak self] success in
            if !success {
                guard let error = self?.authVM.error else { return }
                self?.present(error, animated: true)
            } else {
                UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 4) {
                    guard let codeField = self?.codeField, let emailField = self?.emailField else { return }
                    self?.nextTextField(codeField, previousField: emailField, show: true)
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
    
    private func nextTextField(_ nextField: UITextField, previousField: UITextField, show: Bool) {
        previousField.isUserInteractionEnabled = !show
        previousField.backgroundColor = show ? .systemGray4 : .white
        previousField.textColor = show ? .systemGray: .black
        nextField.isHidden = !show
        self.backButton.isHidden = !show
        self.backButton.alpha = show ? 1 : 0
    }
    
    private func validate(text: String?, validator: (String?) -> (Bool, String), onSuccess: (String) -> Void) {
        let (isValid, error) = validator(text)
        if isValid {
            onSuccess(text!)
        } else {
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 4) {
                self.errorLabel.text = error
                self.errorLabel.isHidden = false
            }
        }
    }
}

// MARK: Actions
extension AuthenticationViewController {
    @objc func sendBtnTapped() {
        emailField.endEditing(true)
        if !authVM.emailSent.value {
            validate(text: emailField.text, validator: authVM.validateEmail(_:), onSuccess: authVM.sendEmail(email:))
        } else {
            validate(text: codeField.text, validator: authVM.validateCode(_:), onSuccess: authVM.getTokens(code:))
        }
    }
    
    @objc func backBtnTapped() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 4) {
            self.errorLabel.isHidden = true
            self.nextTextField(self.codeField, previousField: self.emailField, show: false)
            self.authVM.emailSent.value = false
        }
    }
    
    @objc func textFieldEditingChanged(_ sender: UITextField) {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 4) {
            self.errorLabel.isHidden = true
        }
    }
}
