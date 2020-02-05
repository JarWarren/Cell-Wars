//
//  TarController.swift
//  Cell Wars
//
//  Created by Jared Warren on 2/5/20.
//  Copyright © 2020 Warren. All rights reserved.
//  swiftlint:disable for_where

import Foundation

typealias TarIndex = (row: Int, column: Int)

// MARK: - Tar Controller Delegate

protocol TarControllerDelegate: AnyObject {
    func gameDidEnd(winningFaction: Faction?)
}

// MARK: - Tar Controller

class TarController {
    
    // MARK: Properties
    
    var selectedTar: Tar?
    private var filledSquareCount = 63
    
    weak var delegate: TarControllerDelegate?
    var board: [String: Tar] = [:]
    var currentPlayerTurn: Faction = .blue
    
    // MARK: Gameplay Methods
    
    /// Fills `board` with 64 empty `Tar`.
    func newGame() {
        selectedTar = nil
        currentPlayerTurn = .blue
        filledSquareCount = 4
        for row in 0...7 {
            for column in 0...7 {
                board["\(row)|\(column)"] = Tar()
            }
        }
        board["\(0)|\(0)"]?.faction = .blue
        board["\(0)|\(7)"]?.faction = .blue
        board["\(7)|\(0)"]?.faction = .pink
        board["\(7)|\(7)"]?.faction = .pink
    }
    
    /// Pass in a `(row, column)` and receive an array `[(row, column)]` for all viable moves.
    func getViableMoves(index: TarIndex) -> (duplicate: [TarIndex], teleport: [TarIndex]) {
        // hold all viable moves
        var viableMoves: [TarIndex] = []
        
        var duplicatingMoves: [TarIndex] = []
        var teleportingMoves: [TarIndex] = []
        
        // hold a reference to the selected tar
        selectedTar = board["\(index.row)|\(index.column)"]
        
        // search 20+ nearest squares for emptiness
        for row in (index.row - 2)...(index.row + 2) {
            for column in (index.column - 2)...(index.column + 2) {
                if board["\(row)|\(column)"]?.faction == .none {
                    viableMoves.append((row, column))
                }
            }
        }
        
        // filter to see if they exist on the board
        viableMoves = viableMoves.filter { $0.column >= 0 && $0.row >= 0 }
        
        // filter viable moves to see if they're teleporting or not
        duplicatingMoves = viableMoves.filter { move in
            
            // Both row AND column must be within 1 of the target index
            (index.row - 1)...(index.row + 1) ~= move.row &&
                (index.column - 1)...(index.column + 1) ~= move.column
        }
        
        // all remaining moves are considered teleporting moves
        teleportingMoves = viableMoves.filter { move in
            !duplicatingMoves.contains {
                move.column == $0.column && move.row == $0.row
            }
        }
        
        return (duplicatingMoves, teleportingMoves)
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
        selectedTar = nil
        if filledSquareCount == 64 {
            // Count how many tars are blue (out of 64)
            let blueTars = board.values.filter { $0.faction == .some(.blue) }
            let blueCount = blueTars.count
            
            // Different victory scenarios
            switch blueCount {
            // If it's exactly 32, the game ended in a draw
            case 32:
                delegate?.gameDidEnd(winningFaction: .none)
            // Blue is less than 32, pink had the majority
            case ..<32:
                delegate?.gameDidEnd(winningFaction: .pink)
            // Otherwise blue wins.
            default:
                delegate?.gameDidEnd(winningFaction: .blue)
            }
        }
    }
}
