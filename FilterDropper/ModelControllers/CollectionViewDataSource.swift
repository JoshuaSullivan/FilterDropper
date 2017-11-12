//
//  CollectionViewDataSource.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 10/31/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

/// A simple class that provides single-section data to a UICollectionView.
class CollectionViewDataSource<T>: NSObject, UICollectionViewDataSource {
    
    typealias CellConfiguration = (UICollectionViewCell, T) -> Void
    
    var data: [T]
    let cellIdentifier: String
    let config: CellConfiguration
    
    init(data: [T], cellIdentifier: String, config: @escaping CellConfiguration) {
        self.data = data
        self.cellIdentifier = cellIdentifier
        self.config = config
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        config(cell, data[indexPath.row])
        return cell
    }
}
