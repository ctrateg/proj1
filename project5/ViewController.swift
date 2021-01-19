import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartGame))
        
        if let startWorldURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWorldURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silworm"]
        }
        
        startGame()
    }
    
    func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "World", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func restartGame(){
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default){
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text?.localizedLowercase else { return }
            self?.submit(answer)
        }
            
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String){
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isStarted(word: lowerAnswer){
            if isShort(word: lowerAnswer){
               if isPossible(word: lowerAnswer){
                   if isOriginal(word: lowerAnswer){
                       if isReal(word: lowerAnswer){
                           usedWords.insert(answer, at: 0)
                    
                           let indexPath = IndexPath(row: 0, section: 0)
                           tableView.insertRows(at: [indexPath], with: .automatic)
                    
                           return
                       }
                   }
               }
            }
        }
        
        (errorTitle,errorMessage) = showErrorMassage(lowerAnswer)
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }

    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in tempWord {
            if let position = tempWord.firstIndex(of: letter){
                tempWord.remove(at: position)
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misselledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misselledRange.location == NSNotFound
    }
    
    func isStarted(word: String) -> Bool {
        if word == title?.lowercased() {
            return false
        }
        return true
    }
    
    func isShort(word: String) -> Bool {
        if word.count <= 3 {
            return false
        }
        return true
    }
    
    func showErrorMassage( _ lowerAnswer: String) -> (String, String) {
        var errorTitle: String = ""
        var errorMessage: String = ""
        
        if isStarted(word: lowerAnswer) == false {
            guard let title = title else { return ("","") }
            errorTitle = "Word is answer"
            errorMessage = "Word is \(title.lowercased())"
        } else if isShort(word: lowerAnswer) == false{
            errorTitle = "Word too short"
            errorMessage = "Word must be more then 3 character"
        } else if isPossible(word: lowerAnswer) == false {
            guard let title = title else { return ("","") }
            errorTitle = "Word not possible"
            errorMessage = "U can't spell that word from \(title.lowercased())"
        } else if isOriginal(word: lowerAnswer) == false{
            errorTitle = "Word already used"
            errorMessage = "Be more original"
        } else if isReal(word: lowerAnswer) == false {
            errorTitle = "Word not recognized"
            errorMessage = "U can't just make up, u know!"
        }
        
        return (errorTitle, errorMessage)
    }
}

