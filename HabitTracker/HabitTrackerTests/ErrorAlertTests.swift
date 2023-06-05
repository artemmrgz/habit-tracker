//
//  ErrorAlertTests.swift
//  HabitTrackerTests
//
//  Created by Artem Marhaza on 05/06/2023.
//

import XCTest
@testable import HabitTracker

final class ErrorAlertTests: XCTestCase {

    func testBuildForErrorReturnsCorrectError() {
        let expectedMessage = "Test message"
        
        let error = ErrorAlert.buildForError(message: expectedMessage)
        
        XCTAssertEqual(error.title, "An error has occured")
        XCTAssertEqual(error.message, expectedMessage)
    }
    
    func testBuildReturnsCorrectError() {
        let expectedTitle = "Test title"
        let expectedMessage = "Test message"
        
        let error = ErrorAlert.build(title: expectedTitle, message: expectedMessage)
        
        XCTAssertEqual(error.title, expectedTitle)
        XCTAssertEqual(error.message, expectedMessage)
    }
    
    func testNetworkErrorReturnsCorrectError() {
        let error = ErrorAlert.networkError()
        
        XCTAssertEqual(error.title, "An error has occured")
        XCTAssertEqual(error.message, "Please check your internet connection and try again")
    }
    
    func testEncodingErrorReturnsCorrectError() {
        let error = ErrorAlert.encodingError()
        
        XCTAssertEqual(error.title, "An error has occured")
        XCTAssertEqual(error.message, "Please try again later")
    }
}
