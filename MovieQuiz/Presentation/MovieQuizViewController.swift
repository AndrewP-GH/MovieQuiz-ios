import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var movieQuizPresenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        movieQuizPresenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter()
    }


    @IBAction func noButtonClicked(_ sender: UIButton) {
        movieQuizPresenter.noButtonClicked()
    }

    @IBAction func yesButtonClicked(_ sender: UIButton) {
        movieQuizPresenter.yesButtonClicked()
    }

    func configureButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }

    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    func showNetworkError(message: String) {
        let model = AlertModel(
                title: "Ошибка",
                message: message,
                buttonText: "Попробовать еще раз") { [weak self] in
            self?.movieQuizPresenter.loadData()
        }
        alertPresenter.show(with: model, in: self)
    }

    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        drawBorder(color: isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor)
    }

    private func drawBorder(color: CGColor) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = color
    }

    func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
                title: result.title,
                message: result.text,
                buttonText: result.buttonText) { [weak self] in
            self?.movieQuizPresenter.restartGame()
        }
        alertPresenter.show(with: model, in: self)
    }
}
