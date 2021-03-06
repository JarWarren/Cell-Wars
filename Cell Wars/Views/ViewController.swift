//
//  ViewController.swift
//  Cell Wars
//
//  Created by Jared Warren on 2/5/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var gameBoard: UIView!
    @IBOutlet weak var blueScore: UILabel!
    @IBOutlet weak var pinkScore: UILabel!
    @IBOutlet weak var playerTurnLabel: UILabel!
    
    // MARK: - Properties
    let numViewPerRow = 8
    var cells = [String: TarBlobView]()
    var tarController = TarController(singlePlayer: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gameBoard.clipsToBounds = true
        tarController.delegate = self
        newGame()
    }
    
    /// Resets board and score
    func newGame() {
        //Clears board
        cells.removeAll()
        gameBoard.subviews.forEach { $0.removeFromSuperview() }
        //Calculates the width of our TarViews
        let width = (gameBoard.frame.width) / CGFloat(numViewPerRow)
        //Resets TarController
        tarController.newGame()
        //Updates Score and turn labels
        updateScoresAndTurn()
        //Adds TarBlobViews to gameBoard
        for row in 0...numViewPerRow {
            for column in 0...numViewPerRow {
                let rect = CGRect(x: CGFloat(column) * width, y: CGFloat(row) * width, width: width, height: width)
                let tarBlob = TarBlobView(rect, index: (row, column))
                tarBlob.delegate = self
                gameBoard.addSubview(tarBlob)
                let key = "\(TarIndex(row, column))"
                cells[key] = tarBlob
            }
        }
        ///Setting Colors for TarBlobViews
        for tar in tarController.board {
            switch tar.value.faction {
            case .blue:
                cells[tar.key]?.tar = Tar(faction: .blue)
            case .pink:
                cells[tar.key]?.tar = Tar(faction: .pink)
            default:
                cells[tar.key]?.tar = Tar(faction: .none)
            }
        }
    }
    
     ///Updates Turn label and score labels
    func updateScoresAndTurn() {
        playerTurnLabel.text = tarController.currentPlayer == .blue ? "Blue's Turn" : "Pink's Turn"
        blueScore.text = "Blue Score: \(tarController.blueCount)"
        pinkScore.text = "Pink Score: \(tarController.pinkCount)"
    }
    
    ///calls newGameWhenPressed
    @IBAction func restartPressed(_ sender: Any) {
        newGame()
    }
    /**
     Called when a tar is being moved
     
     - Parameter tarBlobView - Holds the current View that we are moving to
     */
    func didMoveTar(tarBlobView: TarBlobView) {
        //Unwraps background color
        guard let backgroundColor = tarBlobView.backgroundColor else {return}
        //Makes sure that our selected tar is a legal move
        if backgroundColor == .lightGray || backgroundColor == .darkGray {
            //Updates all of our tars to the proper colors and faction status
            for tarBlob in tarController.moveTo(tarBlobView.index) {
                cells["\(tarBlob.index)"]?.tar = tarBlob.tar
            }
            //updates scores and player turn
            updateScoresAndTurn()
        } else {
            //if not a legal move then we cancel the move
            tarController.cancelMove()
        }
        for tar in cells where tar.value.tar.faction == nil {
            tar.value.tar = Tar(faction: nil)
        }
    }
    
    func didSelectTar(tarBlobView: TarBlobView) {
        let viableMoves = tarController.getViableMoves(index: tarBlobView.index)
        if viableMoves.duplicate.count > 0 || viableMoves.teleport.count > 0 {
            for tarBlob in viableMoves.duplicate {
                cells["\(tarBlob)"]?.backgroundColor = .darkGray
            }
            for tarBlob in viableMoves.teleport {
                cells["\(tarBlob)"]?.backgroundColor = .lightGray
            }
        } else {
            tarController.cancelMove()
        }
    }
}

extension ViewController: TarBlobViewDelegate {
    func didTapTarBlob(tarBlobView: TarBlobView) {
        print("tapped \(tarBlobView.index)")
        if tarController.selectedIndex != nil {
            didMoveTar(tarBlobView: tarBlobView)
        } else if tarBlobView.tar.faction == tarController.currentPlayer {
            didSelectTar(tarBlobView: tarBlobView)
        }
    }
}

extension ViewController: TarControllerDelegate {
    func computerPlayerDidMove(move: TarIndex) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            guard let tarBlobView = self.cells["\(move)"] else {return}
            print("computer moved")
            print(move)
            for tarBlob in self.tarController.moveTo(tarBlobView.index) {
                self.cells["\(tarBlob.index)"]?.tar = tarBlob.tar
            }
            self.updateScoresAndTurn()
        })
    }
    
    func gameDidEnd(winningFaction: Faction?) {
        var winner: String = ""
        switch winningFaction {
        case .blue:
            winner = "Blue Won!"
        case .pink:
            winner = "Pink Won!"
        default:
            winner = "Tie Game!"
        }
        let alert = UIAlertController(title: winner, message: "Play Again?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            self.newGame()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}
