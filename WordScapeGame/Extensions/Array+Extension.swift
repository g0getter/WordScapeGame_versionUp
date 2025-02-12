//
//  Array+Extension.swift
//  WordScapeGame
//
//  Created by 여나경 on 2/12/25.
//

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
