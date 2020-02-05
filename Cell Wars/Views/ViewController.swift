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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gameBoard.clipsToBounds = true
        let width = (gameBoard.frame.width) / CGFloat(numViewPerRow)
        
        for j in 0...numViewPerRow {
            for i in 0...numViewPerRow {
                let tarBlob = UIView()
                tarBlob.backgroundColor = .white
                tarBlob.frame = CGRect(x: CGFloat(i) * width, y: CGFloat(j) * width, width: width, height: width)
                tarBlob.layer.borderWidth = 1
                tarBlob.layer.borderColor = UIColor.white.cgColor
                tarBlob.layer.cornerRadius = tarBlob.frame.height / 2
                tarBlob.clipsToBounds = true
                gameBoard.addSubview(tarBlob)
                
                let key = "\(i)|\(j)"
                cells[key] = tarBlob
            }
        }
        cells["0|0"]?.backgroundColor = UIColor.systemBlue
        cells["7|7"]?.backgroundColor = UIColor.systemPink
        gameBoard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedTarBlob)))
    }
    
    @objc func tappedTarBlob(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        //print(location)
        
        let width = gameBoard.frame.width / CGFloat(numViewPerRow)
        
        let i = Int(location.x / width)
        let j = Int(location.y / width)
        print(i, j)
        
        cells["\(i)|\(j)"]?.backgroundColor = bluesTurn ? .systemBlue:.systemPink
        bluesTurn = !bluesTurn
    }
}
