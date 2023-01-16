//
// Created by Андрей Парамонов on 16.01.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController!
    var questionFactory: QuestionFactoryProtocol!
    var statisticService: StatisticService!

    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        statisticService = StatisticServiceImplementation()
        loadData()
    }

    func loadData() {
        guard let viewController else {
            return
        }
        viewController.showLoadingIndicator()
        questionFactory.loadData()
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
                image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func restartGame() {
        (currentQuestionIndex, correctAnswers) = (0, 0)
        questionFactory.requestNextQuestion()
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
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        viewController.configureButtons(isEnabled: false)
        viewController.showAnswerResult(isCorrect: isCorrect)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        showCurrentQuestion()
    }

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }

    private func showCurrentQuestion() {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let question = self.currentQuestion,
                  let viewController = self.viewController else {
                return
            }
            let viewModel = self.convert(model: question)
            viewController.show(quiz: viewModel)
            viewController.configureButtons(isEnabled: true)
        }
    }

    func showNextQuestionOrResult() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            viewController?.showResult()
        } else {
            switchToNextQuestion()
            questionFactory.requestNextQuestion()
        }
    }

    func getResultMessage() -> String {
        let bestGame = statisticService.bestGame
        return """
               Ваш результат: \(correctAnswers) из \(questionsAmount)
               Количество сыгранных квизов: \(statisticService.gamesCount)
               Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
               Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%
               """
    }
}
