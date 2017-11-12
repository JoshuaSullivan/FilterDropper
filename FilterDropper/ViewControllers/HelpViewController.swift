//
//  HelpViewController.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/12/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @objc @IBAction func viewTapped(sender: UITapGestureRecognizer) {
        // This bad, but expedient.
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
