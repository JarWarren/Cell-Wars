//
//  ViewController.swift
//  Cell Wars
//
//  Created by Jared Warren on 2/5/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var gameBoard: UIView!
    @IBOutlet weak var blueScore: UILabel!
    @IBOutlet weak var pinkScore: UILabel!
    
    let numViewPerRow = 8
    var cells = [String: TarBlobView]()
    var bluesTurn: Bool = true
    let tarController = TarController(singlePlayer: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gameBoard.clipsToBounds = true
        newGame()
    }
    
    func newGame() {
        cells.removeAll()
        gameBoard.subviews.forEach { $0.removeFromSuperview() }
        let width = (gameBoard.frame.width) / CGFloat(numViewPerRow)
        tarController.newGame()
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
        
        for tar in tarController.board {
            switch tar.value.faction {
            case .blue:
                cells[tar.key]?.tar = Tar(faction: .blue)
            case .pink:
                cells[tar.key]?.tar = Tar(faction: .pink)
            default:
                cells[tar.key]?.tar = Tar(faction: nil)
            }
        }
    }
    @IBAction func restartPressed(_ sender: Any) {
        newGame()
    }
}

extension ViewController: TarBlobViewDelegate {
    func didTapTarBlob(tarBlobView: TarBlobView) {
        print("tapped \(tarBlobView.index)")
        if tarController.selectedIndex != nil {
            guard let backgroundColor = tarBlobView.backgroundColor else {return}
            if backgroundColor == .lightGray || backgroundColor == .darkGray {
                for tarBlob in tarController.moveTo(tarBlobView.index) {
                    cells["\(tarBlob.index)"]?.tar = tarBlob.tar
                }
            } else {
                tarController.cancelMove()
            }
            for tar in cells where tar.value.tar.faction == nil {
                tar.value.tar = Tar(faction: nil)
            }
        } else if tarBlobView.tar.faction == tarController.currentPlayer {
            let viableMoves = tarController.getViableMoves(index: tarBlobView.index)
            
            for tarBlob in viableMoves.duplicate {
                cells["\(tarBlob)"]?.backgroundColor = .darkGray
            }
            for tarBlob in viableMoves.teleport {
                cells["\(tarBlob)"]?.backgroundColor = .lightGray
            }
        }
    }
}
