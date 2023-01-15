//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Андрей Парамонов on 15.01.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testButton() {
        let cases = ["Yes", "No"]
        let poster = "Poster"
        sleep(3)
        cases.forEach {
            let firstPoster = app.images[poster].screenshot().pngRepresentation
            app.buttons[$0].tap()
            sleep(2)
            let secondPoster = app.images[poster].screenshot().pngRepresentation
            XCTAssertNotEqual(firstPoster, secondPoster)
        }
    }

    func testLabel() {
        let cases = [("Yes", 2), ("No", 3)]
        sleep(3)
        cases.forEach {
            let (button, index) = $0
            app.buttons[button].tap()
            sleep(2)
            let indexLabel = app.staticTexts["Index"]
            XCTAssertEqual(indexLabel.label, "\(index)/10")
        }
    }

}
