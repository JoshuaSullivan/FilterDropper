//
//  ViewController.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 10/30/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {
    
    @IBOutlet weak var resultCollectionView: UICollectionView! {
        didSet {
            resultCollectionView.allowsSelection = false
            resultCollectionView.delegate = self
        }
    }
    @IBOutlet weak var filterCollectionView: UICollectionView! {
        didSet {
            filterCollectionView.allowsSelection = false
            filterCollectionView.delegate = self
        }
    }
    @IBOutlet weak var interactionPrompt: UILabel!
    
    var filterNames: [String] = []
    var renderResults: [RenderResult] = []
    var renderedImages: [UIImage] = [] {
        didSet {
            interactionPrompt.isHidden = !renderedImages.isEmpty
            resultDataSource.data = renderedImages
            resultCollectionView.reloadData()
        }
    }
    
    var filterDataSource: CollectionViewDataSource<String>!
    var resultDataSource: CollectionViewDataSource<UIImage>!
    
    var filterDropDelegate: FilterCollectionDropManager!
    var resultDragDelegate: ResultCollectionDragManager!
    
    var filterCellSize: CGSize = CGSize(width: 300.0, height: 300.0)
    
    var queueObserver: NSKeyValueObservation!
    
    let renderQueue: OperationQueue = {
        let oq = OperationQueue()
        oq.maxConcurrentOperationCount = 1
        oq.qualityOfService = .default
        return oq
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let decoder = JSONDecoder()
        guard
            let filtersURL = Bundle.main.url(forResource: "filters", withExtension: "json"),
            let filtersData = try? Data(contentsOf: filtersURL),
            let filters = try? decoder.decode([String].self, from: filtersData)
        else {
            fatalError("Couldn't load the filters.")
        }
        self.filterNames = filters
        ThumbnailService.shared.generateThumbnailsIfNeeded(for: filters)
        filterDataSource = CollectionViewDataSource<String>(data: filters, cellIdentifier: "FilterCell", config: {
            (cell, filterName) in
            guard let filterCell = cell as? FilterCollectionViewCell else { return }
            filterCell.configure(with: filterName)
        })
        filterCollectionView.dataSource = filterDataSource
        filterDropDelegate = FilterCollectionDropManager()
        filterDropDelegate.delegate = self
        filterCollectionView.dropDelegate = filterDropDelegate
        filterCellSize = size(for: view.bounds.width)
        
        resultDataSource = CollectionViewDataSource<UIImage>(data: [], cellIdentifier: "ResultCell", config: {
            (cell, image) in
            guard let resultCell = cell as? ResultImageCollectionViewCell else { return }
            resultCell.imageView.image = image
        })
        resultCollectionView.dataSource = resultDataSource
        
        resultDragDelegate = ResultCollectionDragManager()
        resultCollectionView.dragDelegate = resultDragDelegate
        resultDragDelegate.dataSource = self
        
        let keyPath = \OperationQueue.operationCount
        queueObserver = renderQueue.observe(keyPath, changeHandler: self.queueCountDidChange)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        queueObserver.invalidate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.filterCellSize = self.size(for: size.width)
        filterCollectionView.reloadData()
    }
    
    private func size(for width: CGFloat) -> CGSize {
        var dim: CGFloat = 0.0
        let edge: CGFloat = 20.0
        let itemSpacing:CGFloat = 10.0
        switch width {
        case ..<340.0:
            dim = width - 2 * edge
        case 340.0..<560.0:
            let padding = 2 * edge + itemSpacing
            dim = (width - padding) / 2.0
        default:
            let padding = 2 * (edge + itemSpacing)
            dim = (width - padding) / 3.0
        }
        dim = floor(dim)
        return CGSize(width: dim, height: dim)
    }
    
    func apply(filterName: String, to images: [UIImage]) {
        let ops = images.map({ ApplyFilterOperation(image: $0, filterName: filterName, completion: self.renderComplete) })
        renderQueue.addOperations(ops, waitUntilFinished: false)
    }
    
    func renderComplete(result: RenderResult?) {
        guard let result = result else { return }
        renderResults.append(result)
        if let image = UIImage(contentsOfFile: result.previewURL.path) {
            renderedImages.append(image)
        }
    }
    
    func queueCountDidChange(_ queue: OperationQueue, _ value: NSKeyValueObservedChange<Int>) {
        if queue.operationCount == 0 {
            print("Queue complete!")
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == filterCollectionView {
            return filterCellSize
        } else if collectionView == resultCollectionView {
            let image = renderedImages[indexPath.item]
            return image.size / UIScreen.main.scale
        } else {
            fatalError("Where did this collection view come from?")
        }
    }
}

extension ViewController: FilterCollectionDropManagerDelegate {
    func filterDropManager(_ filterDropManager: FilterCollectionDropManager, didReceive images: [UIImage], at indexPath: IndexPath) {
        let filterName = self.filterNames[indexPath.item]
        self.apply(filterName: filterName, to: images)
    }
}

extension ViewController: ResultCollectionDragManagerDataSource {
    func image(for indexPath: IndexPath) -> UIImage? {
        let result = self.renderResults[indexPath.item]
        guard
            let data = try? Data(contentsOf: result.fullResolutionURL),
            let image = UIImage(data: data)
        else {
            return nil
        }
        return image
    }
    
    
}
