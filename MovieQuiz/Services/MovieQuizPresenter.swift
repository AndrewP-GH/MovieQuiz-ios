//
// Created by Андрей Парамонов on 16.01.2023.
//

import UIKit

final class MovieQuizPresenter {

    let questionsAmount = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
                image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func resetProgress() {
        currentQuestionIndex = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion, let viewController else {
            return
        }
        let givenAnswer = isYes
        viewController.configureButtons(isEnabled: false)
        viewController.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        showCurrentQuestion()
    }

    private func showCurrentQuestion() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let question = self.currentQuestion else {
                return
            }
            let viewModel = self.convert(model: question)
            self.viewController?.show(quiz: viewModel)
            self.viewController?.configureButtons(isEnabled: true)
        }
    }
}
