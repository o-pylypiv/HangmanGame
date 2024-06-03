//
//  ViewController.swift
//  HangmanGame
//
//  Created by Olha Pylypiv on 06.03.2024.
//

import UIKit

class ViewController: UIViewController {
    var allWords = [String]()
    var usedLetters = [Character]()
    var wrongAnswers = 0
    var wordToGuess = ""
    var wordToGuessInProgress = "" {
        didSet {
            wordToGuessLabel.text = wordToGuessInProgress
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1 {
        didSet {
            levelLabel.text = "Level: \(level)"
        }
    }
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var wordToGuessLabel: UILabel!
    @IBOutlet weak var lettersTextField: UITextField!
    
    @IBOutlet weak var line1: UIView!
    @IBOutlet weak var line2: UIView!
    @IBOutlet weak var line3: UIView!
    @IBOutlet weak var line4: UIView!
    @IBOutlet weak var line5O: UILabel!
    @IBOutlet weak var line6Body: UIView!
    @IBOutlet weak var line7Arms: UILabel!
    @IBOutlet weak var line8Legs: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Hangman Game"
        scoreLabel.text = "Score: \(score)"
        levelLabel.text = "Level: \(level)"
        
        clearHangman()
        loadLevel()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector (dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
            view.endEditing(true)
    }
    
    @objc func startGame(action: UIAlertAction) {
        clearHangman()
        wrongAnswers = 0
        usedLetters.removeAll()
        level += 1
        
        if let word = allWords.randomElement() {
            wordToGuess = word
            wordToGuessInProgress = String(repeating: "?", count: wordToGuess.count)
            wordToGuessLabel.text = wordToGuessInProgress
            print(wordToGuess)
        }
    }
    
    func clearHangman() {
        line1.isHidden = true
        line2.isHidden = true
        line3.isHidden = true
        line4.isHidden = true
        line5O.isHidden = true
        line6Body.isHidden = true
        line7Arms.isHidden = true
        line8Legs.isHidden = true
    }
    
    func loadLevel() {
        if let wordsURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let words = try? String(contentsOf: wordsURL) {
                allWords = words.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["hangman"]
        }
        
        if let word = allWords.randomElement() {
            wordToGuess = word
            wordToGuessInProgress = String(repeating: "?", count: wordToGuess.count)
            wordToGuessLabel.text = wordToGuessInProgress
            print(wordToGuess)
        }
    }
    
    func isInTheWord(letter: Character) -> Bool {
        return wordToGuess.contains(letter)
    }
    
    func isOriginal(letter: Character) -> Bool {
        return !usedLetters.contains(letter)
    }
    
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    func drawHangman() {
        if wrongAnswers > 0 {
            if wrongAnswers == 1 {
                line1.isHidden = false
            } else if wrongAnswers == 2 {
                line2.isHidden = false
            } else if wrongAnswers == 3 {
                line3.isHidden = false
                line4.isHidden = false
            } else if wrongAnswers == 4 {
                line5O.isHidden = false
            } else if wrongAnswers == 5 {
                line6Body.isHidden = false
            } else if wrongAnswers == 6 {
                line7Arms.isHidden = false
            } else if wrongAnswers == 7 {
                line8Legs.isHidden = false
                
                let ac = UIAlertController(title: "Oh no! You lose", message: "Want to try another word?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: startGame))
                present(ac, animated: true)
            }
        }
    }

    @IBAction func submitTapped(_ sender: UIButton) {
        guard lettersTextField.text?.isEmpty == false && lettersTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 1 else {return}
        if let lowerLetter = lettersTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            let letter = Character(lowerLetter)
            
            if letter.isLetter {
                if isOriginal(letter: letter) {
                    usedLetters.append(letter)
                    if isInTheWord(letter: letter) {
                        
                        for (index, char) in wordToGuess.enumerated() {
                            if char == letter {
                                let i = wordToGuess.index(wordToGuess.startIndex, offsetBy: index)
                                wordToGuessInProgress.remove(at: i)
                                wordToGuessInProgress.insert(letter, at: i)
                            }
                        }
                        
                        if wordToGuess == wordToGuessInProgress {
                            score += 1
                            let ac = UIAlertController(title: "Great! You win!", message: "Ready for another level?", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: startGame))
                            present(ac, animated: true)
                        }
                        
                    } else {
                        wrongAnswers += 1
                        drawHangman()
                    }
                } else {
                    showErrorMessage(errorTitle: "You have already tried it", errorMessage: "Try another letter")
                }
            } else {
                showErrorMessage(errorTitle: "This is not a letter", errorMessage: "Try entering a letter")
            }
        }
        lettersTextField.resignFirstResponder()
        lettersTextField.text = ""
    }
    
    @IBAction func clearTapped(_ sender: UIButton) {
        lettersTextField.resignFirstResponder()
        lettersTextField.text = ""
    }
}

