//
//  hotcarWidgetLiveActivity.swift
//  hotcarWidget
//
//  Created by MacMini4 on 2026/3/9.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct hotcarWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct hotcarWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: hotcarWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension hotcarWidgetAttributes {
    fileprivate static var preview: hotcarWidgetAttributes {
        hotcarWidgetAttributes(name: "World")
    }
}

extension hotcarWidgetAttributes.ContentState {
    fileprivate static var smiley: hotcarWidgetAttributes.ContentState {
        hotcarWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: hotcarWidgetAttributes.ContentState {
         hotcarWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: hotcarWidgetAttributes.preview) {
   hotcarWidgetLiveActivity()
} contentStates: {
    hotcarWidgetAttributes.ContentState.smiley
    hotcarWidgetAttributes.ContentState.starEyes
}
