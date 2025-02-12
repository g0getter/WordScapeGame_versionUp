//
//  ViewReactor.swift
//  WordScapeGame
//
//  Created by 여나경 on 2/8/25.
//

import ReactorKit

class ViewReactor: Reactor {
    init(words: [Word]) {
        self.initialWords = words
        self.wordSet = WordSet(initialWords)
    }
    
    let initialState = State(gameState: .initial)
    
    private var wordSet: WordSet {
        didSet {
            wordSet.print()
        }
    }
    private let initialWords: [Word]
    private var capturedWords: [Word] = []
    private var missedWords: [Word] = []
    
    enum Action {
        case startButtonTapped
        case resetButtonTapped
        /// `Word` is missed, animation is stopped
        case missed(Word)
        case captured(String)
    }
    
    enum Mutation {
        case initial
        case startAll([Word])
        case start(Word)
        case emptyBoxes([Word])
        case missed(Word)
        case captured(Word)
        case ended
    }
    
    struct State {
        var newMissedWord: Word?
        var newCapturedWord: Word?
        var gameState: GameState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .startButtonTapped:
            if currentState.gameState == .initial {
                guard let wordsToStart = wordSet.extractNextWords() else {
                    return Observable.empty()
                }
//                let wordsToStart = currentWords.values.compactMap { $0.first }
                
                return Observable.just(Mutation.startAll(wordsToStart))
            }
            return Observable.empty()
            
        case .resetButtonTapped:
            let wordsToRestart = capturedWords + missedWords
            // fill out wordSet
            wordSet.insertWords(wordsToRestart)
            // empty 2 boxes
            capturedWords = []
            missedWords = []
            
            switch currentState.gameState {
            case .initial: // do nothing
                return Observable.empty()
                
            case .end: // initialize all and go to initial state
//                // fill out current words, sort them properly and set to initial state
                return Observable.just(Mutation.initial)
            default: // is still running
                return Observable.just(Mutation.emptyBoxes(wordsToRestart))
            }
            
        case let .missed(word):
            missedWords.append(word)
//            wordSet.remove(word)
            // 3 cases
            
            // i) if there are remaining words to animate, start next one
            if let nextWord = wordSet.extractNextWord(lane: word.laneType) {
                return Observable.concat([
                    Observable.just(Mutation.missed(word)),
                    Observable.just(Mutation.start(nextWord))
                ])
            }
            
            // ii) if it is the last word of all lanes, end the game
            print("✅missed \(word.text), \(capturedWords.count)+\(missedWords.count) AND \(initialWords.count)")
            if capturedWords.count + missedWords.count == initialWords.count {
//            if wordSet.isEmpty {
                return Observable.concat([
                    Observable.just(Mutation.missed(word)),
                    Observable.just(Mutation.ended)
                ])
            }
            
            // iii) do nothing(wait for the other lanes to terminate)
            return Observable.concat([
                Observable.just(Mutation.missed(word)),
            ])
            
        case let .captured(wordText):
            // convert wordText -> word
            guard let word = initialWords.first(where: { $0.text == wordText }) else {
                return Observable.empty()
            }
            capturedWords.append(word)
            
            print("🔥captured: \(capturedWords)\nwordSet:")
            wordSet.print()
            // i) start next one
            if let nextWord = wordSet.extractNextWord(lane: word.laneType) {
                return Observable.concat([
                    Observable.just(Mutation.captured(word)),
                    Observable.just(Mutation.start(nextWord))
                ])
            }
            
            // ii) end the game
            if capturedWords.count + missedWords.count == initialWords.count {
//            if wordSet.isEmpty {
                return Observable.concat([
                    Observable.just(Mutation.captured(word)),
                    Observable.just(Mutation.ended)
                ])
            }
            
            // iii) do nothing(wait for the other lanes to terminate)
            return Observable.just(Mutation.captured(word))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.newCapturedWord = nil
        newState.newMissedWord = nil
        switch mutation {
        case .initial:
            newState.gameState = .initial
            
        case let .startAll(words):
            newState.gameState = .startAll(words)
            
        case let .start(word):
            newState.gameState = .start(word)
            
        case let .emptyBoxes(words):
            newState.gameState = .emptyBoxes(words)
            
        case let .missed(word):
            newState.newMissedWord = word
            newState.gameState = .running //
            
        case let .captured(word):
            newState.newCapturedWord = word
            newState.gameState = .running //
        case .ended:
            newState.gameState = .end
        }
        
        return newState
    }
}

enum GameState: Equatable {
    case initial
    case startAll([Word])
    case start(Word)
    case emptyBoxes([Word])
    /// game is running, nothing to do
    case running
    case end
    
    static func == (lhs: GameState, rhs: GameState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial), (.start, .start), (.end, .end):
            return true
        case (.startAll, .startAll), (.running, .running):
            return true
        case (.emptyBoxes, .emptyBoxes):
            return true
        default:
            return false
        }
    }
}


