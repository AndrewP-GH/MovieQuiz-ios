//
// Created by Андрей Парамонов on 16.01.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol!
    private var questionFactory: QuestionFactoryProtocol!
    private var statisticService: StatisticService!

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        statisticService = StatisticServiceImplementation()
        loadData()
    }

    func loadData() {
        viewController?.showLoadingIndicator()
        questionFactory.loadData()
    }

    func restartGame() {
        (currentQuestionIndex, correctAnswers) = (0, 0)
        questionFactory.requestNextQuestion()
    }

    func noButtonClicked() {
        didAnswer(isCorrectAnswer: false)
    }

    func yesButtonClicked() {
        didAnswer(isCorrectAnswer: true)
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

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
                image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    private func didAnswer(isCorrectAnswer: Bool) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = isCorrectAnswer
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        proceedWithAnswer(isCorrect: isCorrect)
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

    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            viewController?.show(quiz: QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: getResultMessage(),
                    buttonText: "Сыграть ещё раз")
            )
        } else {
            switchToNextQuestion()
            questionFactory.requestNextQuestion()
        }
    }

    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.configureButtons(isEnabled: false)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.proceedToNextQuestionOrResults()
        }
    }
}
