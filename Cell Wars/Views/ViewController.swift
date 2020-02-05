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
    
    let numViewPerRow = 8
    var cells = [String: UIView]()
    var bluesTurn: Bool = true
    let tarController = TarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gameBoard.clipsToBounds = true
        newGame()
    }
    
    func newGame() {
        let width = (gameBoard.frame.width) / CGFloat(numViewPerRow)
        tarController.newGame()
        for row in 0...numViewPerRow {
            for column in 0...numViewPerRow {
                let rect = CGRect(x: CGFloat(column) * width, y: CGFloat(row) * width, width: width, height: width)
                let tarBlob = TarBlobView(rect, index: (row, column))
                tarBlob.delegate = self
                gameBoard.addSubview(tarBlob)
                let key = "\((row, column))"
                cells[key] = tarBlob
                
            }
        }
    }
}

extension ViewController: TarBlobViewDelegate {
    func didTapTarBlob(tarBlobView: TarBlobView) {
        print("tapped \(tarBlobView.index)")
        if tarController.selectedIndex == nil {
            let viableMoves = tarController.getViableMoves(index: tarBlobView.index)
            
            for tarBlob in viableMoves.duplicate {
                cells["\(tarBlob)"]?.backgroundColor = .darkGray
            }
            for tarBlob in viableMoves.teleport {
                cells["\(tarBlob)"]?.backgroundColor = .lightGray
            }
        } else {
            if tarBlobView.backgroundColor == .lightGray && tarBlobView.backgroundColor == .darkGray {
                for tarBlob in tarController.moveTo(tarBlobView.index) {
                    cells["\(tarBlob.index)"].tar = tarBlob.tar
                }
            }
        }
    }
}
