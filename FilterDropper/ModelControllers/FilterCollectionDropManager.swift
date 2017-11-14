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

/// This class functions as the dropDelegate for the `filterCollectionView` in the ViewController.
class FilterCollectionDropManager: NSObject, UICollectionViewDropDelegate {
    
    private let rawImageType: String = kUTTypeRawImage as String
    
    weak var delegate: FilterCollectionDropManagerDelegate?
    
    private var workingIndexPath: IndexPath = IndexPath()
    
    private let rawQueue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        q.qualityOfService = .default
        return q
    }()
    
    private var imagesComplete: Bool = false {
        didSet {
            if imagesComplete {
                checkIfWorkComplete()
            }
        }
    }
    private var rawCount: Int = 0 {
        didSet {
            rawComplete = 0
        }
    }
    private var rawComplete: Int = 0 {
        didSet {
            if rawComplete == rawCount {
                checkIfWorkComplete()
            }
        }
    }
    
    private var collectedImages: [UIImage] = []
    
    // A drop was completed, attempt to load the images and send them for filter processing.
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let indexPath = coordinator.destinationIndexPath else { return }
        delegate?.filterDropManager(willReceiveImages: self)
        let message = NSLocalizedString("drop.loadImages", value: "Copying images…", comment: "Displayed when a drop begins.")
        NotificationCenter.default.post(name: NotificationNames.updateStatus, object: nil, userInfo: ["status" : message])
        imagesComplete = false
        // Set rawComplete to -1 here so any previous use of the raw queue doesn't cause checkIfWorkComplete to accidentally succeed.
        rawComplete =  -1
        workingIndexPath = indexPath
        coordinator.session.loadObjects(ofClass: UIImage.self) {
            [weak self]
            (items) in
            guard let `self` = self else { return }
            guard !items.isEmpty else {
                self.imagesComplete = true
                return
            }
            let images = items.flatMap({ $0 as? UIImage })
            debugPrint("Able to convert \(images.count)/\(items.count) to images.")
            self.collectedImages.append(contentsOf: images)
            self.imagesComplete = true
        }
        
        let rawItems = coordinator.items
            .filter({ $0.dragItem.itemProvider.hasItemConformingToTypeIdentifier(rawImageType) })
            .map({ $0.dragItem.itemProvider })
        self.rawCount = rawItems.count
        guard self.rawCount > 0 else { return }
        
        rawItems.forEach({
            item in
            item.loadFileRepresentation(forTypeIdentifier: rawImageType, completionHandler: {
                [weak self]
                (optionalURL, optionalError) in
                guard let `self` = self else { return }
                guard let url = optionalURL else {
                    print("ERROR: Failed to get raw image's URL: \(optionalError?.localizedDescription ?? "Unknown reason.")")
                    self.rawComplete += 1
                    return
                }
                let localURL = FilterFileManager.savedImagesDirectory.appendingPathComponent(url.lastPathComponent)
                do {
                    try FileManager.default.copyItem(at: url, to: localURL)
                } catch let error as NSError {
                    // If the error is that the file already exists, we'll just ignore the error.
                    guard error.code == 516 else {
                        print("ERROR: Unable to make local copy of image: \(error.localizedDescription)")
                        self.rawComplete += 1
                        return
                    }
                }
                let uti = item.registeredTypeIdentifiers.first ?? self.rawImageType
                let op = LoadAndRenderRawImageOperation(url: localURL, uti: uti, completion: self.handleRawRenderComplete)
                self.rawQueue.addOperation(op)
                let message = NSLocalizedString("drop.convertRaw", value: "Converting RAW images…", comment: "Displayed when the app begins working on converting raw images.")
                NotificationCenter.default.post(name: NotificationNames.updateStatus, object: nil, userInfo: ["status" : message])
            })
        })
    }
    
    func handleRawRenderComplete(image: UIImage?) {
        if let image = image {
            self.collectedImages.append(image)
        }
        self.rawComplete += 1
    }
    
    func checkIfWorkComplete() {
        if imagesComplete && rawComplete == rawCount {
            delegate?.filterDropManager(self, didReceive: collectedImages, at: workingIndexPath)
            self.collectedImages = []
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        let hasImages = session.hasItemsConforming(toTypeIdentifiers: UIImage.readableTypeIdentifiersForItemProvider)
        let hasRawImages = session.hasItemsConforming(toTypeIdentifiers: [rawImageType])
        return hasImages || hasRawImages
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
