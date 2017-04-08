//
//  MoleCollectionViewCell.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/4/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation
import UIKit

class MoleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellImageView: UIImageView!
    
    func configCell(){
        self.cellImageView.image = UIImage(named: "mole")
        self.backgroundColor = UIColor.blue
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
    }
    
}
