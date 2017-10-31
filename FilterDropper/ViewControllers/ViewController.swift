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
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var interactionPrompt: UILabel!
    
    var filterNames: [String] = []

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

