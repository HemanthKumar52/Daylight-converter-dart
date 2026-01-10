import WidgetKit
import SwiftUI

@main
struct DaylightWidgetBundle: WidgetBundle {
    var body: some Widget {
        SmallDaylightWidget()
        MediumDaylightWidget()
        LargeDaylightWidget()
    }
}
