//
//  FilterCollectionViewCell.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 10/30/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleContainer: UIView! {
        didSet {
            titleContainer.layer.cornerRadius = 8.0
        }
    }
    private var currentFilter: String = ""
    
    func configure(with filterName: String) {
        ThumbnailService.shared.thumbnail(for: filterName) {
            [weak self] image in
            guard let image = image else {
                // Got no image back.
                
            }
            if filterName == self?.currentFilter {
                self?.imageView.image =
            }
        }
        currentFilter = filterName
    }
    
}
