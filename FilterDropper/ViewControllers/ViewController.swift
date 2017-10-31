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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("Transitioning to size: \(size)")
        super.viewWillTransition(to: size, with: coordinator)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300.0, height: 300.0)
    }
}
