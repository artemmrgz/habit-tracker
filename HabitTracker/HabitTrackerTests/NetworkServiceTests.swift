//
//  NetworkServiceTests.swift
//  HabitTrackerTests
//
//  Created by Artem Marhaza on 02/06/2023.
//

import XCTest
@testable import HabitTracker

final class NetworkServiceTests: XCTestCase {

    var sut: NetworkService!
    var tokenManagerMock: TokenManagerMock!
    var sessionMock: MockURLSession!

    class TokenManagerMock: TokenManager {
        var accessTkn = TokenInfo(token: "", expiresAt: 0)
        var refreshTkn = TokenInfo(token: "", expiresAt: 0)

        override var accessToken: TokenInfo! { accessTkn }

        override var refreshToken: TokenInfo! { refreshTkn }

        override func updateTokens(_ tokens: TokensInfo) {
            accessTkn = TokenInfo(token: tokens.access, expiresAt: 11.11)
            refreshTkn = TokenInfo(token: tokens.refresh, expiresAt: 22.22)
            timeDelta = 33.33
        }

        func setAccessToken() {
            accessTkn = TokenInfo(token: "Test Access Token", expiresAt: 11.11)
        }

        func setRefreshToken() {
            refreshTkn = TokenInfo(token: "Test Refresh Token", expiresAt: 22.22)
        }
    }

    class MockURLSession: URLSessionProtocol {
        let dataTaskMock = MockURLSessionDataTask()
        var requestUrl: URL?
        var requestData: Data?

        var data: Data?
        var error: Error?
        var httpResponse: HTTPURLResponse?

        func dataTask(with request: URLRequest,
                      completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) ->
        URLSessionDataTaskProtocol {
            requestUrl = request.url
            requestData = request.httpBody

            completionHandler(self.data, self.httpResponse, self.error)

            return dataTaskMock
        }
    }

    class MockURLSessionDataTask: URLSessionDataTaskProtocol {
        var resumeWasCalled = false
        func resume() {
            resumeWasCalled = true
        }
    }

    override func setUp() {
        super.setUp()

        tokenManagerMock = TokenManagerMock()
        sessionMock = MockURLSession()
        sut = NetworkService.shared(tokenManager: tokenManagerMock, session: sessionMock)
    }

    override func tearDown() {
        super.tearDown()

        tokenManagerMock = nil
        sut = nil
    }

    func testBuildRequestReturnsRequestWithAuthHeader() throws {
        tokenManagerMock.setAccessToken()

        let expectedUrl = URL(string: "https://testURL.com")!
        let request = sut.buildRequestForTesting(url: expectedUrl, method: .GET)

        let actualUrl = try XCTUnwrap(request.url)
        XCTAssertEqual(actualUrl, expectedUrl)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.httpMethod, Method.GET.rawValue)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer Test Access Token")
    }

    func testBuildRequestReturnsRequestWithoutAuthHeaderWhenTokenIsEmpty() throws {
        let expectedUrl = URL(string: "https://testURL.com")!
        let request = sut.buildRequestForTesting(url: expectedUrl, method: .GET)

        let actualUrl = try XCTUnwrap(request.url)
        XCTAssertEqual(actualUrl, expectedUrl)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.httpMethod, Method.GET.rawValue)
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
    }

    func testBuildRequestReturnsRequestWithoutAuthHeaderWhenIgnoreJWTAuth() throws {
        tokenManagerMock.setAccessToken()

        let expectedUrl = URL(string: "https://testURL.com")!
        let request = sut.buildRequestForTesting(url: expectedUrl, method: .GET, ignoreJwtAuth: true)

        let actualUrl = try XCTUnwrap(request.url)
        XCTAssertEqual(actualUrl, expectedUrl)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.httpMethod, Method.GET.rawValue)
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
    }

    func testBuildRefreshTokenRequest() throws {
        tokenManagerMock.setRefreshToken()
        let expectedUrl = Endpoint.auth(.refreshToken).absoluteURL

        let request = sut.buildRefreshTokenRequestForTesting()

        let actualUrl = try XCTUnwrap(request.url)
        XCTAssertEqual(actualUrl, expectedUrl)
        XCTAssertEqual(request.httpMethod, Method.POST.rawValue)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer Test Refresh Token")
    }

    func testRenewAuthHeader() throws {
        tokenManagerMock.setAccessToken()
        let expectedUrl = URL(string: "https://testURL.com")!
        var request = URLRequest(url: expectedUrl)
        request.setValue("Bearer Old Access Token", forHTTPHeaderField: "Authorization")

        let updatedRequest = sut.renewAuthHeaderForTesting(request: request)

        let actualUrl = try XCTUnwrap(request.url)
        XCTAssertEqual(actualUrl, expectedUrl)
        XCTAssertEqual(updatedRequest.value(forHTTPHeaderField: "Authorization"), "Bearer Test Access Token")
    }

    func testDoRequestResturnsCorrectData() throws {
        let url = URL(string: "https://testURL.com")
        let request = URLRequest(url: url!)

        let expectedResult = EmailBody(email: "email@gmail.com")
        let data = try? JSONEncoder().encode(expectedResult)
        sessionMock.data = data

        let httpResponse = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
        sessionMock.httpResponse = httpResponse

        let expectation = self.expectation(description: "Wait for dispathing to main queue")

        var emailResult: EmailBody?
        let completion: (Result<EmailBody>) -> Void = { result in
            switch result {
            case .success(let resp):
                emailResult = resp
                expectation.fulfill()
            default:
                return
            }
        }

        sut.doRequest(request: request, completionHandler: completion)

        XCTAssertEqual(sessionMock.requestUrl, url)
        XCTAssertTrue(sessionMock.dataTaskMock.resumeWasCalled)

        waitForExpectations(timeout: 2)

        let actualResult = try XCTUnwrap(emailResult)
        XCTAssertEqual(actualResult.email, expectedResult.email)
    }

    func testDoRequestResturnsErrorWhenUnseccessfulResponseReceived() throws {
        let url = URL(string: "https://testURL.com")
        let request = URLRequest(url: url!)

        let expectedError = ErrorResponse(code: 401, message: "Test Error Message")
        let data = try? JSONEncoder().encode(expectedError)
        sessionMock.data = data

        let httpResponse = HTTPURLResponse(url: url!, statusCode: 401, httpVersion: nil, headerFields: nil)
        sessionMock.httpResponse = httpResponse

        let expectation = self.expectation(description: "Wait for dispathing to main queue")

        var error: ErrorResponse?
        let completionHandler: (Result<EmailBody>) -> Void = { result in
            switch result {
            case .authError(let err):
                error = err
                expectation.fulfill()
            default:
                return
            }
        }

        sut.doRequest(request: request, completionHandler: completionHandler)

        waitForExpectations(timeout: 2)

        let actualError = try XCTUnwrap(error)
        XCTAssertEqual(actualError.code, expectedError.code)
        XCTAssertEqual(actualError.message, expectedError.message)
    }

    func testSendEmailSuccessfullySendsEmail() throws {
        let url = URL(string: "http://127.0.0.1:8080/auth/email/")

        let emailBody = EmailBody(email: "email@gmail.com")
        let dataToSend = try? JSONEncoder().encode(emailBody)

        let httpResponse = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = try? JSONEncoder().encode("")
        sessionMock.httpResponse = httpResponse
        sessionMock.data = data

        let expectation = self.expectation(description: "Wait for dispathing to main queue")

        var res: Bool?

        sut.sendEmail(emailBody: emailBody) { result in
            switch result {
            case .success(_):
                res = true
                expectation.fulfill()
            default:
                res = false
            }
        }

        let actualUrl = try XCTUnwrap(sessionMock.requestUrl)
        XCTAssertEqual(actualUrl, url)

        let actualData = try XCTUnwrap(sessionMock.requestData)
        XCTAssertEqual(actualData, dataToSend!)

        waitForExpectations(timeout: 2)

        let success = try XCTUnwrap(res)
        XCTAssertTrue(success)
    }

    func testSendEmailReturnsEncodingErrorWhenCannotEncodeEmailData() throws {
        let string = "💇‍♀️" as NSString
        let badString = string.substring(with: NSRange(location: 0, length: 1))
        let badEmailBody = EmailBody(email: badString)

        let expectation = self.expectation(description: "Wait for dispathing to main queue")

        var encodingError: Bool?

        sut.sendEmail(emailBody: badEmailBody) { res in
            switch res {
            case .encodingError:
                encodingError = true
                expectation.fulfill()
            default:
                encodingError = false
            }
        }

        waitForExpectations(timeout: 2)

        let error = try XCTUnwrap(encodingError)
        XCTAssertTrue(error)
    }

    func testSendVerificationCodeSendsCodeAndReceivesTokens() throws {
        let url = URL(string: "http://127.0.0.1:8080/auth/token/")

        let codeBody = VerificationCodeBody(email: "email@gmail.com", code: "123456")
        let dataToSend = try? JSONEncoder().encode(codeBody)

        let httpResponse = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
        sessionMock.httpResponse = httpResponse

        let expectedTokens = TokensInfo(access: "Test Access Token", refresh: "Test Resfresh Token")
        let receivedData = try? JSONEncoder().encode(expectedTokens)
        sessionMock.data = receivedData

        let expectation = expectation(description: "Wait for dispathing to main queue")

        var receivedTokens: TokensInfo?

        sut.sendVerificationCode(codeBody: codeBody) { res in
            switch res {
            case .success(let tokens):
                receivedTokens = tokens
                expectation.fulfill()
            default:
                receivedTokens = nil
            }
        }

        let actualURL = try XCTUnwrap(sessionMock.requestUrl)
        XCTAssertEqual(actualURL, url)

        let actualData = try XCTUnwrap(sessionMock.requestData)
        XCTAssertEqual(actualData, dataToSend!)

        waitForExpectations(timeout: 2)

        let actualTokens = try XCTUnwrap(receivedTokens)
        XCTAssertEqual(actualTokens.access, expectedTokens.access)
        XCTAssertEqual(actualTokens.refresh, expectedTokens.refresh)
    }

    func testSendVerificationCodeReturnsEncodingErrorWhenCannotEncodeVerificationCodeData() throws {
        let string = "💇‍♀️" as NSString
        let badString = string.substring(with: NSRange(location: 0, length: 1))
        let badVerifCodeBody = VerificationCodeBody(email: badString, code: "123456")

        let expectation = self.expectation(description: "Wait for dispathing to main queue")

        var encodingError: Bool?

        sut.sendVerificationCode(codeBody: badVerifCodeBody) { res in
            switch res {
            case .encodingError:
                encodingError = true
                expectation.fulfill()
            default:
                encodingError = false
            }
        }

        waitForExpectations(timeout: 2)

        let error = try XCTUnwrap(encodingError)
        XCTAssertTrue(error)
    }
}
