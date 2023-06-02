//
//  TokenManagerTests.swift
//  HabitTrackerTests
//
//  Created by Artem Marhaza on 01/06/2023.
//

import XCTest
@testable import HabitTracker

final class TokenManagerTests: XCTestCase {
    
    var sut: TokenManager!
    var storageManagerMock: StorageManagerMock!
    
    let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjg1Mzk0MDA4LCJpYXQiOjE2ODUzOTM3MDgsImp0aSI6Ijc5YTVhMGUwYzczNTQwZWY5MDQwNTEwODM1YjRkNjg5IiwidXNlcl9pZCI6MX0.nZUcOMwa1MEMI4rqdzYw2HTjJSQkfeHZ6HXvOibloVY"
    
    class StorageManagerMock: StorageManageable {
        var refreshToken: TokenInfo?
        var accessToken: TokenInfo?
        var timeDelta: Double?
        
        func dropTokens() {
        }
        
        func saveTimeDelta(_ delta: Double) {
            timeDelta = delta
        }
        
        func getTimeDelta() -> Double? {
            return timeDelta
        }
        
        func saveToken(_ token: HabitTracker.TokenInfo, isRefresh: Bool) {
            if isRefresh {
                refreshToken = token
            } else {
                accessToken = token
            }
        }
        
        func getToken(isRefresh: Bool) -> HabitTracker.TokenInfo? {
            if isRefresh {
                return refreshToken
            }
            return accessToken
        }
    }
    
    func compareTokens(actual: TokenInfo, expected: TokenInfo) {
        XCTAssertEqual(actual.token, expected.token)
        XCTAssertEqual(actual.expiresAt, expected.expiresAt)
    }

    override func setUp() {
        super.setUp()
        
        storageManagerMock = StorageManagerMock()
        sut = TokenManager(storageManager: storageManagerMock)
    }

    override func tearDown() {
        super.tearDown()
        
        sut = nil
        storageManagerMock = nil
    }

    func testReturnsDefaultTokensAndDeltaWhenCreated() {
        compareTokens(actual: sut.accessToken, expected: TokenInfo(token: "", expiresAt: 0.0))
        compareTokens(actual: sut.refreshToken, expected: TokenInfo(token: "", expiresAt: 0.0))
        XCTAssertNil(sut.timeDelta)
    }
    
    func testParseTokenReturnsParsedToken() {
        let expectedToken = TokenInfo(token: token, expiresAt: 1685394008)
        
        let actualToken = sut.parseTokenForTesting(token)
        
        compareTokens(actual: actualToken!, expected: expectedToken)
    }
    
    func testParseTokenReturnsNilWhenTokenIsIncorrect() {
        let incorrectToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiaWF0IjoxNjg1MzkzNzA4LCJqdGkiOiI3OWE1YTBlMGM3MzU0MGVmOTA0MDUxMDgzNWI0ZDY4OSIsInVzZXJfaWQiOjF9.YlMfGjkbimRdT1xKavI86bS2t1wRgE-JVmwzp9JsWNI"
        
        let actualToken = sut.parseTokenForTesting(incorrectToken)
        
        XCTAssertNil(actualToken)
    }
    
    func testSaveTokenSuccessfulySavesAccessToken() {
        let expectedToken = TokenInfo(token: token, expiresAt: 1685394008)
        
        sut.saveToken(token)
        
        compareTokens(actual: storageManagerMock.accessToken!, expected: expectedToken)
    }
    
    func testSaveTokenSuccessfulySavesRefreshToken() {
        let expectedToken = TokenInfo(token: token, expiresAt: 1685394008)
        
        sut.saveToken(token, isRefresh: true)
        
        compareTokens(actual: storageManagerMock.refreshToken!, expected: expectedToken)
    }
    
    func testSaveTimeDeltaCalculatesAndSavesDelta() {
        let date = Date(timeIntervalSince1970: 1685394708)
        
        sut.saveTimeDeltaForTesting(token, fromDate: date)
        
        XCTAssertEqual(storageManagerMock.timeDelta!, 1000)
    }
    
    func testSaveTimeDeltaCalculatesAndSavesZeroDeltaIfDiffLessThanTwoSeconds() {
        let date = Date(timeIntervalSince1970: 1685393709)
        
        sut.saveTimeDeltaForTesting(token, fromDate: date)
        
        XCTAssertEqual(storageManagerMock.timeDelta!, 0)
    }
    
    func testUpdateTokensUpdatesTokens() {
        let tokens = TokensInfo(access: token, refresh: token)
        
        sut.updateTokens(tokens)
        
        compareTokens(actual: sut.accessToken, expected: storageManagerMock.accessToken!)
        compareTokens(actual: sut.refreshToken, expected: storageManagerMock.refreshToken!)
        XCTAssertNotNil(sut.timeDelta)
    }

}
