//
//  TarBlob.swift
//  Cell Wars
//
//  Created by Trevor Walker on 2/5/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit
protocol TarBlobViewDelegate: class {
    func didTapTarBlob(tarBlobView: TarBlobView)
}

class TarBlobView: UIView {
    
    let index: TarIndex
    var tar: Tar {
        didSet {
            let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
            
            if (self.tar.faction == .blue || self.tar.faction == .pink) && (!(self.backgroundColor == .systemBlue && self.tar.faction == .blue) || !(self.backgroundColor == .systemPink && self.tar.faction == .pink)) {
                UIView.transition(with: self, duration: 1.0, options: transitionOptions, animations: {
                    switch self.tar.faction {
                    case .blue:
                        self.backgroundColor = .systemBlue
                    case .pink:
                        self.backgroundColor = .systemPink
                    default:
                        self.backgroundColor = .clear
                    }
                })
            } else {
                self.backgroundColor = .clear
            }
        }
    }
    weak var delegate: TarBlobViewDelegate?
    
    init(_ rect: CGRect, index: TarIndex) {
        // Drawing code
        self.index = index
        self.tar = Tar(faction: nil)
        super.init(frame: rect)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCell)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapCell() {
        delegate?.didTapTarBlob(tarBlobView: self)
    }
}
