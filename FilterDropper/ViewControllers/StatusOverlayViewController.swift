//
//  StatusOverlayViewController.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/14/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

class StatusOverlayViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleStatus(note:)), name: NotificationNames.updateStatus, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func handleStatus(note: Notification) {
        guard
            let info = note.userInfo,
            let status = info["status"] as? String
        else { return }
        DispatchQueue.main.async {
            self.statusLabel.text = status
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
