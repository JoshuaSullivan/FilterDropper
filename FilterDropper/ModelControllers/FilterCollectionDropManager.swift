//
//  FilterCollectionDropManager.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/1/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol FilterCollectionDropManagerDelegate: class {
    func filterDropManager(_ filterDropManager: FilterCollectionDropManager, dropHoverOver indexPath: IndexPath)
    func filterDropManager(didStopDropHover filterDropManager: FilterCollectionDropManager)
    func filterDropManager(willReceiveImages filterDropManager: FilterCollectionDropManager)
    func filterDropManager(_ filterDropManager: FilterCollectionDropManager, didReceive images: [UIImage], at indexPath: IndexPath)
}

class FilterCollectionDropManager: NSObject, UICollectionViewDropDelegate {
    
    weak var delegate: FilterCollectionDropManagerDelegate?
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        // THIS IS WHERE THE RUBBER HITS THE ROAD, BAY-BEE!!!
        guard let indexPath = coordinator.destinationIndexPath else { return }
        delegate?.filterDropManager(willReceiveImages: self)
        coordinator.session.loadObjects(ofClass: UIImage.self) {
            [weak self]
            (items) in
            guard let `self` = self else { return }
            guard !items.isEmpty else {
                self.delegate?.filterDropManager(self, didReceive: [], at: indexPath)
                return
            }
            let images = items.flatMap({ $0 as? UIImage })
            debugPrint("Able to convert \(images.count)/\(items.count) to images.")
            self.delegate?.filterDropManager(self, didReceive: images, at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        let result = session.hasItemsConforming(toTypeIdentifiers: UIImage.readableTypeIdentifiersForItemProvider)
        return result
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard let ip = destinationIndexPath else {
            delegate?.filterDropManager(didStopDropHover: self)
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        delegate?.filterDropManager(self, dropHoverOver: ip)
        if session.localDragSession != nil {
            return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .copy, intent: .insertIntoDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidExit session: UIDropSession) {
        delegate?.filterDropManager(didStopDropHover: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        delegate?.filterDropManager(didStopDropHover: self)
    }
}
