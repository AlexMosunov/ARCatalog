//
//  QuizQuestionObject.swift
//  ARCatalog
//
//  Created by User on 27.04.2023.
//

import Foundation

struct QuizQuestionObject: Decodable {
    let title: String
    let answers: [String]
    let correctAnswer: String
    let question: String
    let imageName: String
    let description: String
    let is3D: Bool
    let modelName: String?
    var answeredCorrectly:Bool = false
}
