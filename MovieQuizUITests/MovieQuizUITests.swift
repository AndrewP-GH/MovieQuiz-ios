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

    func testButtons() {
        continueAfterFailure = true
        let testCases = [
            ("Yes", 2),
            ("No", 3)
        ]
        let poster = "Poster"
        sleep(3)
        for (button, index) in testCases {
            XCTContext.runActivity(named: "Test \(button) button") { _ in
                let firstPoster = app.images[poster].screenshot().pngRepresentation

                app.buttons[button].tap()
                sleep(2)

                let secondPoster = app.images[poster].screenshot().pngRepresentation
                XCTAssertNotEqual(firstPoster, secondPoster)
                let indexLabel = app.staticTexts["Index"]
                XCTAssertEqual(indexLabel.label, "\(index)/100")
            }
        }
    }

    func testGameFinish() {
        sleep(3)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }

        let alert = app.alerts["Alert"];

        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }

    func testAlertDismiss() {
        sleep(3)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        let poster = "Poster"
        let lastPoster = app.images[poster].screenshot().pngRepresentation

        let alert = app.alerts["Alert"];
        alert.buttons.firstMatch.tap()
        sleep(2)

        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.label == "1/10")
        let newPoster = app.images[poster].screenshot().pngRepresentation
        XCTAssertNotEqual(lastPoster, newPoster)
    }
}
