//
//  HomeMenuViewController.swift
//  Cell Wars
//
//  Created by Trevor Walker on 2/6/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit

class HomeMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pvp" {
            guard let destination = segue.destination as? ViewController else {return}
            destination.tarController = TarController(singlePlayer: true)
        }
        
    }

}
