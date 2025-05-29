//
//  SettingsViewModel.swift
//  CursorSync
//
//  Created by Daniel612 on 5/20/25.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    let settings: SettingsModel
    
    init(settings: SettingsModel) {
        self.settings = settings
    }
}
