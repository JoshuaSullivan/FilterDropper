//
//  GlobalDeclarations.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/14/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import Foundation

struct NotificationNames {
    static let updateStatus = Notification.Name(rawValue: "updateStatusNotification")
    static let importError = Notification.Name(rawValue: "importErrorNotification")
    
    private init() {}
}
