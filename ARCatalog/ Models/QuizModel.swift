//
//  QuizModel.swift
//  ARCatalog
//
//  Created by User on 27.04.2023.
//

import Foundation
import SceneKit

class QuizModel {
    var questions = [String:QuizQuestionObject]()
    let spacingX: Float = 0.005
    var spacingY: Float = 0

    required init() {
        loadData()
    }
    
    private func loadData() {
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

    func getItem(at indexPath: IndexPath) -> QuizQuestionObject? {
        return nil
    }

    func get3DModel(_ question: QuizQuestionObject) -> SCNNode? {
        guard let name = question.modelName else {
            return nil
        }
        if let node = SCNNode.getNode(named: name){
            node.position = SCNVector3(
                x: 0,
                y: 0,
                z: 0.05)
            return node
        }
        return nil
    }

    func getQuestiontitle(_ question: QuizQuestionObject) -> SCNNode {
        let questionTitle = textNode(
            question.answeredCorrectly ? question.title : question.question,
            font: UIFont.boldSystemFont(ofSize: 8)
        )
        questionTitle.pivotOnTopCenter()
        questionTitle.position.x -= Float(questionTitle.width / 2)
        questionTitle.position.y += 0.15 - spacingX
        return questionTitle
    }

    func textNode(_ str: String, font: UIFont, maxWidth: Int? = nil) -> SCNNode {
        let text = SCNText(string: str, extrusionDepth: 0)

        text.flatness = 0.1
        text.font = font


        if let maxWidth = maxWidth {
            text.containerFrame = CGRect(origin: .zero, size: CGSize(width: maxWidth, height: 500))
            text.isWrapped = true
        }

        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)

        return textNode
    }
}
