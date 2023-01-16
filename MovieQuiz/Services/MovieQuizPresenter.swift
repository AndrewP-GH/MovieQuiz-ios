//
// Created by Андрей Парамонов on 16.01.2023.
//

import UIKit

final class MovieQuizPresenter {

    let questionsAmount = 10
    private var currentQuestionIndex: Int = 0

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
}
