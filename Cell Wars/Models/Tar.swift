//
//  Tar.swift
//  Cell Wars
//
//  Created by Jared Warren on 2/5/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import Foundation

class Tar {
    var faction: Faction?
    
    init(faction: Faction?) {
        self.faction = faction
    }
}

enum Faction {
    case pink
    case blue
}
