import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol!
    private var statisticService: StatisticService!
    private var alertPresenter: AlertPresenter!
    private let presenter = MovieQuizPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        presenter.viewController = self
        alertPresenter = AlertPresenter()
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        statisticService = StatisticServiceImplementation()
        loadData()
    }

    private func loadData() {
        showLoadingIndicator()
        questionFactory.loadData()
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }

    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        showNetworkError(message: error.localizedDescription)
    }

    @IBAction func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    @IBAction func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    func configureButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }

    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
        let model = AlertModel(
                title: "Ошибка",
                message: message,
                buttonText: "Попробовать еще раз") { [weak self] in
            self?.loadData()
        }
        alertPresenter.show(with: model, in: self)
    }

    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        drawBorder(color: isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResult()
        }
    }

    private func drawBorder(color: CGColor) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = color
    }

    private func showNextQuestionOrResult() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            showResult()
        } else {
            presenter.switchToNextQuestion()
            questionFactory.requestNextQuestion()
        }
    }

    private func showResult() {
        let model = AlertModel(
                title: "Этот раунд окончен!",
                message: formatResultMessage(),
                buttonText: "Сыграть ещё раз") { [weak self] in
            self?.startNewGame()
        }
        alertPresenter.show(with: model, in: self)
    }

    private func startNewGame() {
        presenter.resetProgress()
        correctAnswers = 0
        questionFactory.requestNextQuestion()
    }

    private func formatResultMessage() -> String {
        let bestGame = statisticService.bestGame
        return """
               Ваш результат: \(correctAnswers) из \(presenter.questionsAmount)
               Количество сыгранных квизов: \(statisticService.gamesCount)
               Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
               Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%
               """
    }

}
