import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Shared Data Model
struct WidgetTimeZone: Codable, Hashable {
    let identifier: String
    let cityName: String
    let abbreviation: String
    let isHome: Bool

    var timeZone: TimeZone {
        TimeZone(identifier: identifier) ?? .current
    }

    func currentHour() -> Int {
        let calendar = Calendar.current
        var calendarWithZone = calendar
        calendarWithZone.timeZone = timeZone
        return calendarWithZone.component(.hour, from: Date())
    }

    func currentMinute() -> Int {
        let calendar = Calendar.current
        var calendarWithZone = calendar
        calendarWithZone.timeZone = timeZone
        return calendarWithZone.component(.minute, from: Date())
    }

    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "h:mma"
        return formatter.string(from: Date()).uppercased()
    }

    func isHomeTimezone(home: WidgetTimeZone?) -> Bool {
        guard let home = home else { return false }
        return home.identifier == identifier
    }

    func offsetFromHome(home: WidgetTimeZone?) -> String? {
        guard let home = home, home.identifier != identifier else {
            return nil
        }

        let homeZone = home.timeZone
        let thisZone = timeZone
        let now = Date()

        let homeOffset = homeZone.secondsFromGMT(for: now)
        let thisOffset = thisZone.secondsFromGMT(for: now)
        let diffSeconds = thisOffset - homeOffset
        let diffMinutes = diffSeconds / 60
        let hours = abs(diffMinutes) / 60
        let minutes = abs(diffMinutes) % 60

        let sign = diffMinutes >= 0 ? "+" : "-"
        if minutes == 0 {
            return "\(sign)\(hours)h"
        } else {
            return "\(sign)\(hours)h \(minutes)m"
        }
    }
}

// MARK: - Available Timezones
// (Truncated list for brevity, simulating the original)
struct AvailableTimeZones {
    static let all: [(identifier: String, cityName: String, abbreviation: String)] = [
        ("America/New_York", "New York", "EST"),
        ("America/Los_Angeles", "Los Angeles", "PST"),
        ("Europe/London", "London", "GMT"),
        ("Asia/Tokyo", "Tokyo", "JST"),
        ("Australia/Sydney", "Sydney", "AEST")
        // Add full list if needed
    ]
}

// MARK: - TimeZone Entity for AppIntents
struct TimeZoneEntity: AppEntity {
    var id: String
    var cityName: String
    var abbreviation: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Time Zone"
    static var defaultQuery = TimeZoneQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(cityName)", subtitle: "\(abbreviation)")
    }

    func toWidgetTimeZone(isHome: Bool = false) -> WidgetTimeZone {
        let identifier = id.components(separatedBy: "_").first ?? id
        return WidgetTimeZone(identifier: identifier, cityName: cityName, abbreviation: abbreviation, isHome: isHome)
    }
}

struct TimeZoneQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [TimeZoneEntity] {
        identifiers.compactMap { id in
            // Simplified lookup
             if let tz = AvailableTimeZones.all.first(where: { $0.identifier == id || "\($0.identifier)_\($0.cityName)" == id }) {
                return TimeZoneEntity(id: "\(tz.identifier)_\(tz.cityName)", cityName: tz.cityName, abbreviation: tz.abbreviation)
            }
            return nil
        }
    }

    func suggestedEntities() async throws -> [TimeZoneEntity] {
        AvailableTimeZones.all.map { tz in
            TimeZoneEntity(id: "\(tz.identifier)_\(tz.cityName)", cityName: tz.cityName, abbreviation: tz.abbreviation)
        }
    }

    func defaultResult() async -> TimeZoneEntity? {
        TimeZoneEntity(id: "America/Los_Angeles_San Francisco", cityName: "San Francisco", abbreviation: "PST")
    }
}

// MARK: - Intents
struct SmallWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Time Zone"
    static var description = IntentDescription("Choose a time zone to display")

    @Parameter(title: "Time Zone")
    var timeZone: TimeZoneEntity?

    init() {}
}

struct MediumWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Time Zones"
    static var description = IntentDescription("Choose up to 3 time zones to display")

    @Parameter(title: "Time Zone 1")
    var timeZone1: TimeZoneEntity?
    @Parameter(title: "Time Zone 2")
    var timeZone2: TimeZoneEntity?
    @Parameter(title: "Time Zone 3")
    var timeZone3: TimeZoneEntity?

    init() {}
}

struct LargeWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Time Zones"
    static var description = IntentDescription("Choose up to 6 time zones to display")
    @Parameter(title: "Time Zone 1") var timeZone1: TimeZoneEntity?
    @Parameter(title: "Time Zone 2") var timeZone2: TimeZoneEntity?
    @Parameter(title: "Time Zone 3") var timeZone3: TimeZoneEntity?
    @Parameter(title: "Time Zone 4") var timeZone4: TimeZoneEntity?
    @Parameter(title: "Time Zone 5") var timeZone5: TimeZoneEntity?
    @Parameter(title: "Time Zone 6") var timeZone6: TimeZoneEntity?
    init() {}
}

// MARK: - Timeline Entry
struct DaylightEntry: TimelineEntry {
    let date: Date
    let timeZones: [WidgetTimeZone]

    var homeTimeZone: WidgetTimeZone? {
        let defaults = UserDefaults(suiteName: "group.com.daylight.app")
        if let data = defaults?.data(forKey: "SavedTimeZones"),
           let decoded = try? JSONDecoder().decode([WidgetTimeZone].self, from: data),
           let home = decoded.first(where: { $0.isHome }) {
            return home
        }
        return timeZones.first
    }
}

// MARK: - Providers
struct SmallWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> DaylightEntry {
        DaylightEntry(date: Date(), timeZones: [WidgetTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false)])
    }
    func snapshot(for configuration: SmallWidgetIntent, in context: Context) async -> DaylightEntry {
        let tz = configuration.timeZone?.toWidgetTimeZone() ?? WidgetTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false)
        return DaylightEntry(date: Date(), timeZones: [tz])
    }
    func timeline(for configuration: SmallWidgetIntent, in context: Context) async -> Timeline<DaylightEntry> {
        let tz = configuration.timeZone?.toWidgetTimeZone() ?? WidgetTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false)
        let currentDate = Date()
        var entries: [DaylightEntry] = []
        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            entries.append(DaylightEntry(date: entryDate, timeZones: [tz]))
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct MediumWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> DaylightEntry { DaylightEntry(date: Date(), timeZones: sampleTimeZones()) }
    func snapshot(for configuration: MediumWidgetIntent, in context: Context) async -> DaylightEntry { DaylightEntry(date: Date(), timeZones: extractTimeZones(from: configuration)) }
    func timeline(for configuration: MediumWidgetIntent, in context: Context) async -> Timeline<DaylightEntry> {
        let timeZones = extractTimeZones(from: configuration)
        var entries: [DaylightEntry] = []
        let currentDate = Date()
        for minuteOffset in 0..<60 {
             let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
             entries.append(DaylightEntry(date: entryDate, timeZones: timeZones))
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
    private func extractTimeZones(from configuration: MediumWidgetIntent) -> [WidgetTimeZone] {
        var result: [WidgetTimeZone] = []
        if let tz1 = configuration.timeZone1 { result.append(tz1.toWidgetTimeZone()) }
        if let tz2 = configuration.timeZone2 { result.append(tz2.toWidgetTimeZone()) }
        if let tz3 = configuration.timeZone3 { result.append(tz3.toWidgetTimeZone()) }
        return result.isEmpty ? sampleTimeZones() : result
    }
    private func sampleTimeZones() -> [WidgetTimeZone] {
        [WidgetTimeZone(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST", isHome: true),
         WidgetTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false),
         WidgetTimeZone(identifier: "America/Chicago", cityName: "Dallas", abbreviation: "CST", isHome: false)]
    }
}

struct LargeWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> DaylightEntry { DaylightEntry(date: Date(), timeZones: sampleTimeZones()) }
    func snapshot(for configuration: LargeWidgetIntent, in context: Context) async -> DaylightEntry { DaylightEntry(date: Date(), timeZones: extractTimeZones(from: configuration)) }
    func timeline(for configuration: LargeWidgetIntent, in context: Context) async -> Timeline<DaylightEntry> {
        let timeZones = extractTimeZones(from: configuration)
        var entries: [DaylightEntry] = []
        let currentDate = Date()
        for minuteOffset in 0..<60 {
             let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
             entries.append(DaylightEntry(date: entryDate, timeZones: timeZones))
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
    private func extractTimeZones(from configuration: LargeWidgetIntent) -> [WidgetTimeZone] {
        var result: [WidgetTimeZone] = []
        if let tz1 = configuration.timeZone1 { result.append(tz1.toWidgetTimeZone()) }
        if let tz2 = configuration.timeZone2 { result.append(tz2.toWidgetTimeZone()) }
        if let tz3 = configuration.timeZone3 { result.append(tz3.toWidgetTimeZone()) }
         if let tz4 = configuration.timeZone4 { result.append(tz4.toWidgetTimeZone()) }
          if let tz5 = configuration.timeZone5 { result.append(tz5.toWidgetTimeZone()) }
           if let tz6 = configuration.timeZone6 { result.append(tz6.toWidgetTimeZone()) }
        return result.isEmpty ? sampleTimeZones() : result
    }
    private func sampleTimeZones() -> [WidgetTimeZone] {
         [WidgetTimeZone(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST", isHome: true),
         WidgetTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false),
         WidgetTimeZone(identifier: "America/Chicago", cityName: "Dallas", abbreviation: "CST", isHome: false),
         WidgetTimeZone(identifier: "Europe/London", cityName: "London", abbreviation: "GMT", isHome: false)]
    }
}

// MARK: - Views
struct SmallWidgetView: View {
    let entry: DaylightEntry
    @Environment(\.colorScheme) var colorScheme
    var displayTimeZone: WidgetTimeZone { entry.timeZones.first ?? WidgetTimeZone(identifier: "UTC", cityName: "UTC", abbreviation: "UTC", isHome: true) }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if displayTimeZone.isHomeTimezone(home: entry.homeTimeZone) {
                Image(systemName: "location.fill").font(.system(size: 10))  // Placeholder for nav icon
            } else if let offset = displayTimeZone.offsetFromHome(home: entry.homeTimeZone) {
                Text(offset).font(.system(size: 8, weight: .thin))
            }
            Text(displayTimeZone.formattedTime()).font(.system(size: 24, weight: .black, design: .rounded)).minimumScaleFactor(0.5)
            Spacer()
            Text(displayTimeZone.cityName).font(.system(size: 12, weight: .semibold))
            Text(displayTimeZone.abbreviation).font(.system(size: 8, weight: .thin))
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            LinearGradient(colors: colorScheme == .dark ? [Color.black, Color(red: 0.11, green: 0.11, blue: 0.11)] : [Color.white, Color(red: 0.95, green: 0.95, blue: 0.97)], startPoint: .top, endPoint: .bottom)
        }
    }
}

struct MediumWidgetView: View {
    let entry: DaylightEntry
    @Environment(\.colorScheme) var colorScheme
    var displayTimeZones: [WidgetTimeZone] { Array(entry.timeZones.prefix(3)) }

    var body: some View {
        GeometryReader { geometry in
             ZStack {
                 VStack(spacing: 8) {
                     ForEach(displayTimeZones, id: \.identifier) { tz in
                         TimeZoneRow(timeZone: tz, width: geometry.size.width - 32, colorScheme: colorScheme)
                     }
                 }.padding(16)
                 
                 Rectangle().fill(colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.2))
                    .frame(width: 1).position(x: geometry.size.width / 2, y: geometry.size.height / 2)
             }
        }
        .containerBackground(for: .widget) {
             LinearGradient(colors: colorScheme == .dark ? [Color.black, Color(red: 0.11, green: 0.11, blue: 0.11)] : [Color.white, Color(red: 0.95, green: 0.95, blue: 0.97)], startPoint: .top, endPoint: .bottom)
        }
    }
}

struct LargeWidgetView: View {
    let entry: DaylightEntry
    @Environment(\.colorScheme) var colorScheme
    var displayTimeZones: [WidgetTimeZone] { Array(entry.timeZones.prefix(6)) }

    var body: some View {
        GeometryReader { geometry in
             ZStack {
                 VStack(spacing: 8) {
                     ForEach(displayTimeZones, id: \.identifier) { tz in
                         TimeZoneRow(timeZone: tz, width: geometry.size.width - 32, colorScheme: colorScheme)
                     }
                 }.padding(16)
                  Rectangle().fill(colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.2))
                    .frame(width: 1).position(x: geometry.size.width / 2, y: geometry.size.height / 2)
             }
        }
        .containerBackground(for: .widget) {
             LinearGradient(colors: colorScheme == .dark ? [Color.black, Color(red: 0.11, green: 0.11, blue: 0.11)] : [Color.white, Color(red: 0.95, green: 0.95, blue: 0.97)], startPoint: .top, endPoint: .bottom)
        }
    }
}

struct TimeZoneRow: View {
    let timeZone: WidgetTimeZone
    let width: CGFloat
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(timeZone.cityName).font(.system(size: 8, weight: .thin))
                Spacer()
                Text(timeZone.formattedTime()).font(.system(size: 8, weight: .thin))
            }
            // Bar placeholder
            Capsule().fill(Color.gray.opacity(0.2)).frame(height: 6)
        }
    }
}

struct SmallDaylightWidget: Widget {
    let kind: String = "SmallDaylightWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SmallWidgetIntent.self, provider: SmallWidgetProvider()) { entry in SmallWidgetView(entry: entry) }
        .configurationDisplayName("Daylight Small")
        .supportedFamilies([.systemSmall])
    }
}
struct MediumDaylightWidget: Widget {
    let kind: String = "MediumDaylightWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: MediumWidgetIntent.self, provider: MediumWidgetProvider()) { entry in MediumWidgetView(entry: entry) }
        .configurationDisplayName("Daylight Medium")
        .supportedFamilies([.systemMedium])
    }
}
struct LargeDaylightWidget: Widget {
    let kind: String = "LargeDaylightWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: LargeWidgetIntent.self, provider: LargeWidgetProvider()) { entry in LargeWidgetView(entry: entry) }
        .configurationDisplayName("Daylight Large")
        .supportedFamilies([.systemLarge])
    }
}

@main
struct DaylightWidgets: WidgetBundle {
    var body: some Widget {
        SmallDaylightWidget()
        MediumDaylightWidget()
        LargeDaylightWidget()
    }
}
