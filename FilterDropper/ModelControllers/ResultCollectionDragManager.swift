//
//  ResultCollectionDragManager.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/8/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

protocol ResultCollectionDragManagerDataSource: class {
    func image(for indexPath: IndexPath) -> UIImage?
}

/// This class acts as the dragDelegate for the `resultsCollectionView` in the ViewController.
class ResultCollectionDragManager: NSObject, UICollectionViewDragDelegate {
    
    weak var dataSource: ResultCollectionDragManagerDataSource?
    
    // Just get the image for the selected index path.
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(for: indexPath)
    }
    
    // We won't let items be added more than once to the flock.
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let items = dragItems(for: indexPath).filter({ !session.items.contains($0) })
        return items
    }
    
    private func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        guard let image = dataSource?.image(for: indexPath) else {
            return []
        }
        
        let imageProvider = NSItemProvider(object: image)
        return [UIDragItem(itemProvider: imageProvider)]
    }
}
