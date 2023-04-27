//
//  QuizModel.swift
//  ARCatalog
//
//  Created by User on 27.04.2023.
//

import Foundation

class QuizModel {
    var questions = [String:QuizQuestionObject]()
    required init() {
        loadData()
    }
    
    func loadData() {
        guard let url = Bundle.main.url(forResource: "quizQuetions", withExtension: "json") else {
            fatalError("Unable to find JSON in bundle")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unable to load JSON")
        }

        let decoder = JSONDecoder()

        guard let loadedQuestions = try? decoder.decode([String: QuizQuestionObject].self, from: data) else {
            fatalError("Unable to parse JSON.")
        }

        questions = loadedQuestions
    }
}
