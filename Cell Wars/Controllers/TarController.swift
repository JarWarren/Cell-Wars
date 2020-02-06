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
    
    // MARK: - Properties
    
    var selectedIndex: TarIndex?
    private var filledSquareCount = 63
    
    weak var delegate: TarControllerDelegate?
    var board: [String: Tar] = [:]
    var currentPlayer: Faction = .blue
    
    // MARK: - Gameplay Methods
    
    /// Fills `board` with 64 empty `Tar`.
    func newGame() {
        selectedIndex = nil
        currentPlayer = .blue
        filledSquareCount = 4
        for row in 0...7 {
            for column in 0...7 {
                board["\(row)|\(column)"] = Tar()
            }
        }
        board["\((0, 0))"]?.faction = .blue
        board["\((0, 7))"]?.faction = .blue
        board["\((7, 0))"]?.faction = .pink
        board["\((7, 7))"]?.faction = .pink
    }
    
    /// Pass in a `(row, column)` and receive an array `[(row, column)]` for all viable moves.
    func getViableMoves(index: TarIndex) -> (duplicate: [TarIndex], teleport: [TarIndex]) {
        // hold all viable moves
        var viableMoves: [TarIndex] = []
        
        // moves filtered by type
        var duplicatingMoves: [TarIndex] = []
        var teleportingMoves: [TarIndex] = []
        
        // hold a reference to the selected tar
        selectedIndex = index
        
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
    
    /// Takes in a `(row, column)`and performs either duplication or teleportation.  Returns an array `[(TarIndex, Tar)]` for squares that need to be updated.
    func moveTo(_ targetIndex: TarIndex) -> [(index: TarIndex, tar: Tar)] {
        
        // Cannot perform move if there isn't a previously selected tar
        guard let selectedIndex = selectedIndex else { return [] }
        
        // Check whether the move is within duplicating range or Tar needs to teleport.
        if abs(targetIndex.row - selectedIndex.row) < 2 && abs(targetIndex.column - selectedIndex.column) < 2 {
            return duplicateTar(at: targetIndex)
            
        } else {
            return teleportTar(to: targetIndex)
        }
    }
    
    /// Nils out the currently selected Tar.
    func cancelMove() {
        selectedIndex = nil
    }
    
    // MARK: - Private Methods
    
    private func teleportTar(to targetIndex: TarIndex) -> [(index: TarIndex, tar: Tar)] {
        
        // Cannot perform move if there isn't a previously selected tar
        guard let selectedIndex = selectedIndex else { return [] }
        
        // remove tar from selected index
        board["\(selectedIndex)"]?.faction = .none
        
        // add tar to target index
        board["\(targetIndex)"]?.faction = currentPlayer
        
        // capture adjacents to target index
        return captureAdjacents(index: targetIndex)
    }
    
    private func duplicateTar(at targetIndex: TarIndex) -> [(index: TarIndex, tar: Tar)] {
        
        // add tar to target index
        board["\(targetIndex)"]?.faction = currentPlayer
        
        // update filled tar counts
        filledSquareCount += 1
        
        // capture adjacents to the target index
        return captureAdjacents(index: targetIndex)
    }
    
    private func captureAdjacents(index: TarIndex) -> [(index: TarIndex, tar: Tar)] {
        var updatedTars: [(index: TarIndex, tar: Tar)] = []
        
        // set tar color to current
        for row in (index.row - 1)...(index.row + 1) where (0...7) ~= row {
            for column in (index.column - 1)...(index.column + 1) where (0...7) ~= column {
                if let tar = board["\((row, column))"],
                    tar.faction != nil {
                    tar.faction = currentPlayer
                    updatedTars.append(((row, column), tar))
                }
            }
        }
        
        // Check for victory
        checkForWin()
        
        // Uhh... this might cause a bug
        return updatedTars
    }
    
    private func nextTurn() {
        
        // Reset selected index for next turn
        selectedIndex = nil
        
        // Change current player
        currentPlayer = currentPlayer == .blue ? .pink : .blue
    }
    
    private func checkForWin() {
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
        } else {
            nextTurn()
        }
    }
}
