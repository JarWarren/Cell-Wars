//
//  TarController.swift
//  Cell Wars
//
//  Created by Jared Warren on 2/5/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import Foundation

typealias TarIndex = (row: Int, column: Int)

protocol TarControllerDelegate: AnyObject {
    func gameDidEnd(winningFaction: Faction)
}

class TarController {
    
    var board: [[Tar]] = [[]]
    var currentTar: Tar?
    weak var delegate: TarControllerDelegate?
    
    func getViableMoves(index: TarIndex) -> [TarIndex] {
        []
    }
    
    func moveTar(to: TarIndex) {
        
    }
    
    func duplicateTar(at: TarIndex) {
        
         captureAdjactents()
        
    }
    
    private func captureAdjactents() {
        
        checkForWin()
    }
    
    private func checkForWin() {
        delegate?.gameDidEnd(winningFaction: .blue)
    }
}
