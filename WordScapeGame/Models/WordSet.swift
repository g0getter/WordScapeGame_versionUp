//
//  WordSet.swift
//  WordScapeGame
//
//  Created by 여나경 on 2/12/25.
//

struct WordSet {
    var laneA: [Word] = []
    var laneB: [Word] = []
    var laneC: [Word] = []
    
    init(laneA: [Word], laneB: [Word], laneC: [Word]) {
        self.laneA = laneA
        self.laneB = laneB
        self.laneC = laneC
    }
    
    init(_ words: [Word]) {
        laneA = words.filter { $0.laneType == .laneA }.sorted(by: { $0.priorityInLane < $1.priorityInLane })
        laneB = words.filter { $0.laneType == .laneB }.sorted(by: { $0.priorityInLane < $1.priorityInLane })
        laneC = words.filter { $0.laneType == .laneC }.sorted(by: { $0.priorityInLane < $1.priorityInLane })
    }
    
//    mutating func remove(_ word: Word) {
//        switch word.laneType {
//        case .laneA:
//            laneA.removeAll { $0 == word }
//        case .laneB:
//            laneB.removeAll { $0 == word }
//        case .laneC:
//            laneC.removeAll { $0 == word }
//        }
//    }
}

extension WordSet {
    /// Removes next words to start of all three lanes and returns them
    mutating func extractNextWords() -> [Word]? {
        var words: [Word] = []
        if laneA.first != nil {
            words.append(laneA.removeFirst())
        }
        
        if laneB.first != nil {
            words.append(laneB.removeFirst())
        }
        
        if laneC.first != nil {
            words.append(laneC.removeFirst())
        }
        
        return words.isEmpty ? nil : words
    }
    
    /// Removes and returns the next word in `lane`
    mutating func extractNextWord(lane: LaneType) -> Word? {
        switch lane {
        case .laneA:
            laneA.isEmpty ? nil : laneA.removeFirst()
        case .laneB:
            laneB.isEmpty ? nil : laneB.removeFirst()
        case .laneC:
            laneC.isEmpty ? nil : laneC.removeFirst()

        }
    }
    
    mutating func insertWords(_ words: [Word]) {
        words.forEach { insertWord($0) }
    }
    
    mutating func insertWord(_ word: Word) {
        switch word.laneType {
        case .laneA:
            let index = laneA.insertionIndex(of: word)
            laneA.insert(word, at: index)
        case .laneB:
            let index = laneB.insertionIndex(of: word)
            laneB.insert(word, at: index)
        case .laneC:
            let index = laneC.insertionIndex(of: word)
            laneC.insert(word, at: index)
        }
    }
    
    
}

extension WordSet {
    func print() {
        Swift.print("""
✨WORD SET✨
laneA: \(laneA.map { $0.text })
laneB: \(laneB.map { $0.text })
laneC: \(laneC.map { $0.text })
""")
    }
    
    var isEmpty: Bool {
        if laneA.isEmpty && laneB.isEmpty && laneC.isEmpty {
            return true
        }
        return false
    }
    
    var allWords: [Word] {
        laneA + laneB + laneC
    }
    
    func words(of laneType: LaneType) -> [Word] {
        switch laneType {
        case .laneA:
            return laneA
        case .laneB:
            return laneB
        case .laneC:
            return laneC
        }
    }
}

extension Array where Element == Word {
    /// Inserts to a proper index using binary search
    func insertionIndex(of newWord: Word) -> Int {
        var low = 0
        var high = self.count
        while low < high {
            let mid = low + (high - low) / 2
            if self[mid].priorityInLane < newWord.priorityInLane {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return low
    }
}


