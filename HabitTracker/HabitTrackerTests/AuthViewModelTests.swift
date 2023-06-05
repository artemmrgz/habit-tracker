//
//  AuthViewModelTests.swift
//  HabitTrackerTests
//
//  Created by Artem Marhaza on 05/06/2023.
//

import XCTest
@testable import HabitTracker

final class AuthViewModelTests: XCTestCase {
    
    var sut: AuthViewModel!
    var networkServiceMock: NetworkServiceMock!
    var tokenManagerMock: TokenManagerMock!
    
    static let errorMessage = "Test Error"
    static let tokens = TokensInfo(access: "Test Access Token", refresh: "Test Resfresh Token")
    
    class NetworkServiceMock: NetworkServiceProtocol {
        var isSendEmailCalled = false
        var isSendVerificationCodeCalled = false
        var shouldReturnError = false
        
        func sendEmail(emailBody: EmailBody, completionHandler: @escaping (Result<SuccessResponse>) -> Void) {
            isSendEmailCalled = true
            
            if shouldReturnError {
                completionHandler(Result.authError(ErrorResponse(code: 402, message: errorMessage)))
            } else {
                completionHandler(Result.success(SuccessResponse()))
            }
        }
        
        func sendVerificationCode(codeBody: HabitTracker.VerificationCodeBody, completionHandler: @escaping (HabitTracker.Result<HabitTracker.TokensInfo>) -> Void) {
            isSendVerificationCodeCalled = true
            
            if shouldReturnError {
                completionHandler(Result.authError(ErrorResponse(code: 402, message: errorMessage)))
            } else {
                completionHandler(Result.success(tokens))
            }
        }
    }
    
    class TokenManagerMock: TokenManageable {
        var isUpdateTokensCalled: Bool = false
        var receivedTokens: TokensInfo?
        
        func updateTokens(_ tokens: HabitTracker.TokensInfo) {
            isUpdateTokensCalled = true
            
            receivedTokens = tokens
        }
        
        func isValidToken(_ token: HabitTracker.TokenInfo) -> Bool {
            true
        }
        
        var accessToken: HabitTracker.TokenInfo!
        
        var refreshToken: HabitTracker.TokenInfo!
        
        var timeDelta: Double?
    }

    override func setUp() {
        super.setUp()
        
        networkServiceMock = NetworkServiceMock()
        tokenManagerMock = TokenManagerMock()
        sut = AuthViewModel(networkService: networkServiceMock, tokenManager: tokenManagerMock)
    }

    override func tearDown() {
        super.tearDown()
        
        sut = nil
        networkServiceMock = nil
        tokenManagerMock = nil
    }

    func testSendEmailStoresEmailAndMarksEmailAsSent() throws {
        let expectedEmail = "test@email.com"
        
        sut.sendEmail(email: expectedEmail)
        
        XCTAssertTrue(networkServiceMock.isSendEmailCalled)
        XCTAssertTrue(sut.emailSent.value)
        XCTAssertNil(sut.error)
        
        let actualEmail = try XCTUnwrap(sut.emailForTesting)
        XCTAssertEqual(actualEmail, expectedEmail)
    }
    
    func testSendEmailCreatesErrorWhenErrorOccurs() throws {
        let expectedError = UIAlertController(title: "An error has occured", message: AuthViewModelTests.errorMessage, preferredStyle: .alert)
        let email = "test@email.com"

        networkServiceMock.shouldReturnError = true
        
        sut.sendEmail(email: email)
        
        XCTAssertTrue(networkServiceMock.isSendEmailCalled)
        XCTAssertFalse(sut.emailSent.value)
        XCTAssertNil(sut.emailForTesting)
        
        let actualError = try XCTUnwrap(sut.error)
        XCTAssertEqual(actualError.title, expectedError.title)
        XCTAssertEqual(actualError.message, expectedError.message)
    }
    
    func testGetTokensUpdatesTokensAndMarksTokensAsReceived() throws {
        // to save email into AuthViewModel.email property
        sut.sendEmail(email: "test@email.com")
        
        sut.getTokens(code: "123456")
        
        XCTAssertTrue(networkServiceMock.isSendVerificationCodeCalled)
        XCTAssertTrue(sut.tokensReceived.value)
        XCTAssertTrue(tokenManagerMock.isUpdateTokensCalled)
        XCTAssertNil(sut.error)
        
        let actualTokens = try XCTUnwrap(tokenManagerMock.receivedTokens)
        let expectedTokens = AuthViewModelTests.tokens
        XCTAssertEqual(actualTokens.access, expectedTokens.access)
        XCTAssertEqual(actualTokens.refresh, expectedTokens.refresh)
    }
    
    func testGetTokensCreatesErrorWhenErrorOccures() throws {
        let expectedError = UIAlertController(title: "An error has occured", message: AuthViewModelTests.errorMessage, preferredStyle: .alert)
        // to save email into AuthViewModel.email property
        sut.sendEmail(email: "test@email.com")
        
        networkServiceMock.shouldReturnError = true
        
        sut.getTokens(code: "123456")
        
        XCTAssertTrue(networkServiceMock.isSendVerificationCodeCalled)
        XCTAssertFalse(sut.tokensReceived.value)
        XCTAssertFalse(tokenManagerMock.isUpdateTokensCalled)
        XCTAssertNil(tokenManagerMock.receivedTokens)
        
        let actualError = try XCTUnwrap(sut.error)
        XCTAssertEqual(actualError.title, expectedError.title)
        XCTAssertEqual(actualError.message, expectedError.message)
    }
}
