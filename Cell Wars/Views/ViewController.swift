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
        
        for row in 0...numViewPerRow {
            for column in 0...numViewPerRow {
                let rect = CGRect(x: CGFloat(column) * width, y: CGFloat(row) * width, width: width, height: width)
                let tarBlob = TarBlobView(rect, index: (row,column))
                tarBlob.delegate = self
                gameBoard.addSubview(tarBlob)
                let key = "\((row, column))"
                cells[key] = tarBlob
                
            }
        }
        cells["\((0, 0))"]?.backgroundColor = UIColor.systemBlue
        cells["\((7, 7))"]?.backgroundColor = UIColor.systemPink
    }
}

extension ViewController: TarBlobViewDelegate {
    func didTapTarBlob(tarBlobView: TarBlobView) {
        print("tapped \(tarBlobView.index)")
        if tarController.selectedTar == nil {
            for tarBlobKey in tarController.getViableMoves(index: tarBlobView.index) {
                cells["\((tarBlobKey))"]?.layer.borderColor = UIColor.black.cgColor
            }
        } else {
            
        }
    }
}
