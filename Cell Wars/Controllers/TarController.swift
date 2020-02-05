//
//  TarController.swift
//  Cell Wars
//
//  Created by Jared Warren on 2/5/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import Foundation

typealias TarIndex = (row: Int, column: Int)

// MARK: - Tar Controller Delegate

protocol TarControllerDelegate: AnyObject {
    func gameDidEnd(winningFaction: Faction?)
}

// MARK: - Tar Controller

class TarController {
    
    // MARK: Properties
    
    private var selectedTar: Tar?
    private var filledSquareCount = 63
    
    weak var delegate: TarControllerDelegate?
    var board: [String: Tar] = [:]
    var currentPlayerTurn: Faction = .blue
    
    // MARK: Gameplay Methods
    
    /// Pass in a `(row, column)` and receive an array `[(row, column)]` for all viable moves.
    func getViableMoves(index: TarIndex) -> [TarIndex] {
        selectedTar = board["\(index.row)|\(index.column)"]
        return []
    }
    
    /// Takes in a `(row, column)`and performs either duplication or teleportation.  Returns an array `[(row, column)]` of squares that need to be updated.
    func moveTo(_ index: TarIndex) {
        
    }
    
    /// Nils out the currently selected Tar.
    func cancelMove() {
        selectedTar = nil
    }
    
    // MARK: Private Methods
    
    private func moveTar(to: TarIndex) {
        
    }
    
    private func duplicateTar(at: TarIndex) {
        
        captureAdjacents()
        
    }
    
    private func captureAdjacents() {
        
        checkForWin()
    }
    
    private func checkForWin() {
        
        if filledSquareCount == 64 {
//            let blueCount = board.values.map { $0.faction == .some(.blue) }.count
//            let winningFaction: Faction = blueCount > 32 ? .blue : .pink
        }
        delegate?.gameDidEnd(winningFaction: .blue)
        selectedTar = nil
    }
}
