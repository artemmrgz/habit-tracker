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
        var _accessToken = TokenInfo(token: "", expiresAt: 0)
        var _refreshToken = TokenInfo(token: "", expiresAt: 0)
        
        override var accessToken: TokenInfo! {
            _accessToken
        }
        
        override var refreshToken: TokenInfo! {
            _refreshToken
        }
        
        override func updateTokens(_ tokens: TokensInfo) {
            _accessToken = TokenInfo(token: tokens.access, expiresAt: 11.11)
            _refreshToken = TokenInfo(token: tokens.refresh, expiresAt: 22.22)
            timeDelta = 33.33
        }
        
        func setAccessToken() {
            _accessToken = TokenInfo(token: "Test Access Token", expiresAt: 11.11)
        }
        
        func setRefreshToken() {
            _refreshToken = TokenInfo(token: "Test Refresh Token", expiresAt: 22.22)
        }
    }
    
    class MockURLSession: URLSessionProtocol {
        let dataTaskMock = MockURLSessionDataTask()
        var requestUrl: URL?
        
        var data: Data?
        var error: Error?
        var httpResponse: HTTPURLResponse?
        
        func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HabitTracker.URLSessionDataTaskProtocol {
            requestUrl = request.url
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
        let data = try! JSONEncoder().encode(expectedResult)
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
        let data = try! JSONEncoder().encode(expectedError)
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
}
