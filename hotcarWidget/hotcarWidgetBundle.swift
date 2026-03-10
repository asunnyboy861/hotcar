//
//  WidgetBundle.swift
//  hotcarWidget
//
//  HotCar Widget Bundle
//

import WidgetKit
import SwiftUI

@main
struct HotCarWidgets: WidgetBundle {
    var body: some Widget {
        WarmUpTimerWidget()
        TemperatureWidget()
        QuickStartWidget()
    }
}
