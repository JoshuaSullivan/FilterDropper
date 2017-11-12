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
    @IBOutlet weak var selectionOverlay: UIImageView!
    private var currentFilter: String = ""
    
    func configure(with filterName: String) {
        currentFilter = filterName
        if let title = CIFilter.localizedName(forFilterName: filterName) {
            titleContainer.isHidden = false
            titleLabel.text = title
        } else {
            titleContainer.isHidden = true
        }
        
        imageView.image = UIImage(named: "image-loading")
        ThumbnailService.shared.thumbnail(for: filterName) {
            [weak self] image in
            guard let `self` = self else { return }
            guard let image = image else {
                // Got no image back.
                self.imageView.image = UIImage(named:"image-missing")
                return
            }
            guard filterName == self.currentFilter else {
                // The cell has been reused.
                return
            }
            self.imageView.image = image
        }
        selectionOverlay.isHidden = true
    }
    
    func showSelectedState(_ selected: Bool) {
        self.selectionOverlay.isHidden = !selected
    }
    
}
