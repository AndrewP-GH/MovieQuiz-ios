//
// Created by Андрей Парамонов on 17.01.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)

    func highlightImageBorder(isCorrectAnswer: Bool)

    func showLoadingIndicator()
    func hideLoadingIndicator()

    func configureButtons(isEnabled: Bool)

    func showNetworkError(message: String)
}