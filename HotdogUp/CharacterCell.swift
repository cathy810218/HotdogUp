//
//  CharacterCell.swift
//  HotdogUp
//
//  Created by Cathy Oun on 8/19/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import UIKit

class CharacterCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            checkmarkImageView.isHidden = !isSelected
        }
    }
}
