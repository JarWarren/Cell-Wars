//
//  TarController.swift
//  Cell Wars
//
//  Created by Jared Warren on 2/5/20.
//  Copyright © 2020 Warren. All rights reserved.
//  swiftlint:disable cyclomatic_complexity

import Foundation

typealias TarIndex = (row: Int, column: Int)

// MARK: - Tar Controller Delegate

/// Receives updates from a TarController.
protocol TarControllerDelegate: AnyObject {
    
    /// Returns the faction that won, or `nil` if it was a draw.
    func gameDidEnd(winningFaction: Faction?)
    
    /// Called by TarController between turns. Returns the indexes of `Tar` that need to be updated on the UI.
    func computerPlayerDidMove(move: TarIndex)
}

// MARK: - Tar Controller

class TarController {
    
    // MARK: - Properties
    
    private let singlePlayer: Bool
    
    weak var delegate: TarControllerDelegate?
    var selectedIndex: TarIndex?
    var board: [String: Tar] = [:]
    var currentPlayer: Faction = .blue
    var pinkCount = 2
    var blueCount = 2
    
    // MARK: - Initializer
    
    init(singlePlayer: Bool) {
        self.singlePlayer = singlePlayer
    }
    
    // MARK: - Gameplay Methods
    
    /// Fills `board` with 64 empty `Tar`.
    func newGame() {
        selectedIndex = nil
        currentPlayer = .blue
        pinkCount = 2
        blueCount = 2
        for row in 0...7 {
            for column in 0...7 {
                board["\(TarIndex(row, column))"] = Tar(faction: nil)
            }
        }
        board["\(TarIndex(0, 0))"]?.faction = .blue
        board["\(TarIndex(0, 7))"]?.faction = .blue
        board["\(TarIndex(7, 0))"]?.faction = .pink
        board["\(TarIndex(7, 7))"]?.faction = .pink
    }
    
    /// Pass in a `(row, column)` and receive an array `[(row, column)]` for all viable moves.
    func getViableMoves(index: TarIndex) -> (duplicate: [TarIndex], teleport: [TarIndex]) {
        guard board["\(index)"]?.faction == .some(currentPlayer) else { return ([], []) }
        
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
                if board["\(TarIndex(row, column))"]?.faction == .none {
                    viableMoves.append((row, column))
                }
            }
        }
        
        // filter to see if they exist on the board (and aren't the original index)
        viableMoves = viableMoves.filter { $0.column >= 0 && $0.row >= 0 && ($0.row != index.row || $0.column != index.column) }
        
        // filter viable moves to determine tar behavior
        duplicatingMoves = viableMoves.filter { move in
            
            // Both row AND column must be within 1 of the target index in order to duplicate
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
        
        // Called after return, calculates computer player's move on a background thread and notifies delegate
        defer {
            if !singlePlayer && currentPlayer == .pink {
                DispatchQueue.global(qos: .background).async {
                    self.findBestMoveForComputerPlayer()
                }
            }
        }
        
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
        print("teleported")
        
        // Cannot perform move if there isn't a previously selected tar
        guard let selectedIndex = selectedIndex else { return [] }
        
        // remove tar from selected index
        board["\(selectedIndex)"]?.faction = .none
        
        // add tar to target index
        board["\(targetIndex)"]?.faction = currentPlayer
        
        // capture adjacents to target index
        var updatedTars = captureAdjacents(index: targetIndex)
        updatedTars.append((index: selectedIndex, tar: Tar(faction: nil)))
        return updatedTars
    }
    
    private func duplicateTar(at targetIndex: TarIndex) -> [(index: TarIndex, tar: Tar)] {
        print("duplicated")
        
        // add tar to target index
        board["\(targetIndex)"]?.faction = currentPlayer
        
        // update tar counts
        if currentPlayer == .blue {
            blueCount += 1
        } else {
            pinkCount += 1
        }
        
        // capture adjacents to the target index
        return captureAdjacents(index: targetIndex)
    }
    
    private func captureAdjacents(index: TarIndex) -> [(index: TarIndex, tar: Tar)] {
        var updatedTars: [(index: TarIndex, tar: Tar)] = []
        
        // set tar color to current
        for row in (index.row - 1)...(index.row + 1) where (0...7) ~= row {
            for column in (index.column - 1)...(index.column + 1) where (0...7) ~= column {
                if let tar = board["\(TarIndex(row, column))"],
                    tar.faction != nil {
                    
                    if tar.faction != currentPlayer {
                        if currentPlayer == .blue {
                            blueCount += 1
                            pinkCount -= 1
                        } else {
                            pinkCount += 1
                            blueCount -= 1
                        }
                    }
                    
                    print(blueCount, pinkCount)
                    
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
        
        if blueCount == 0 { delegate?.gameDidEnd(winningFaction: .pink) }
        if pinkCount == 0 { delegate?.gameDidEnd(winningFaction: .blue) }
        
        if blueCount + pinkCount >= 64 {
            
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
    
    private func findBestMoveForComputerPlayer() {
        var bestMove = TarIndex(0, 0)
        var from = TarIndex(0, 0)
        var highestCaptureCount = 0
        var captureCount = 0
        
        for row in 0...7 {
            for column in 0...7 {
                let index = TarIndex(row, column)
                let key = "\(index)"
                if board[key]?.faction == .some(.pink) {
                    let viableMoves = getViableMoves(index: index)
                    
                    for move in viableMoves.duplicate {
                        captureCount = 1
                        for row in (move.row - 1)...(move.row + 1) where (0...7) ~= row {
                            for column in (move.column - 1)...(move.column + 1) where (0...7) ~= column {
                                if board["\(TarIndex(row, column))"]?.faction == .blue {
                                    captureCount += 1
                                }
                            }
                        }
                        if captureCount > highestCaptureCount {
                            highestCaptureCount = captureCount
                            bestMove = move
                            from = index
                        }
                    }
                    
                    for move in viableMoves.teleport {
                        captureCount = 0
                        for row in (move.row - 1)...(move.row + 1) where (0...7) ~= row {
                            for column in (move.column - 1)...(move.column + 1) where (0...7) ~= column {
                                if board["\(TarIndex(row, column))"]?.faction == .blue {
                                    captureCount += 1
                                }
                            }
                        }
                        if captureCount > highestCaptureCount {
                            highestCaptureCount = captureCount
                            bestMove = move
                            from = index
                        }
                    }
                }
            }
        }
        
        // Find index of best move, call moveTo(index:) and pass result to delegate
        selectedIndex = from
        delegate?.computerPlayerDidMove(move: bestMove)
    }
}
