//
//  ViewController.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 10/30/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var resultCollectionView: UICollectionView!
    @IBOutlet weak var filterCollectionView: UICollectionView! {
        didSet {
            filterCollectionView.delegate = self
        }
    }
    @IBOutlet weak var interactionPrompt: UILabel!
    
    var filterNames: [String] = []
    
    var filterDataSource: CollectionViewDataSource<String>!
    
    var cellSize: CGSize = CGSize(width: 300.0, height: 300.0)

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
        cellSize = size(for: view.bounds.width)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.cellSize = self.size(for: size.width)
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
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}
