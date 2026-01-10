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
        return home.identifier == identifier && home.cityName == cityName
    }

    func offsetFromHome(home: WidgetTimeZone?) -> String? {
        guard let home = home, home.identifier != identifier || home.cityName != cityName else {
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

// MARK: - App Intent for Timezone Selection
struct TimeZoneEntity: AppEntity {
    var id: String
    var cityName: String
    var abbreviation: String
    var identifier: String
    var isHome: Bool

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Timezone"
    static var defaultQuery = TimeZoneQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(cityName) (\(abbreviation))")
    }

    init(from widgetTimeZone: WidgetTimeZone) {
        self.id = "\(widgetTimeZone.identifier)_\(widgetTimeZone.cityName)"
        self.cityName = widgetTimeZone.cityName
        self.abbreviation = widgetTimeZone.abbreviation
        self.identifier = widgetTimeZone.identifier
        self.isHome = widgetTimeZone.isHome
    }

    init(id: String, cityName: String, abbreviation: String, identifier: String, isHome: Bool) {
        self.id = id
        self.cityName = cityName
        self.abbreviation = abbreviation
        self.identifier = identifier
        self.isHome = isHome
    }

    func toWidgetTimeZone() -> WidgetTimeZone {
        WidgetTimeZone(identifier: identifier, cityName: cityName, abbreviation: abbreviation, isHome: isHome)
    }
}

// MARK: - Available World Timezones
struct AvailableTimeZones {
    static let all: [(identifier: String, cityName: String, abbreviation: String)] = [
        // Americas
        ("America/New_York", "New York", "EST"),
        ("America/Los_Angeles", "Los Angeles", "PST"),
        ("America/Chicago", "Chicago", "CST"),
        ("America/Denver", "Denver", "MST"),
        ("America/Phoenix", "Phoenix", "MST"),
        ("America/Anchorage", "Anchorage", "AKST"),
        ("Pacific/Honolulu", "Honolulu", "HST"),
        ("America/Toronto", "Toronto", "EST"),
        ("America/Vancouver", "Vancouver", "PST"),
        ("America/Montreal", "Montreal", "EST"),
        ("America/Mexico_City", "Mexico City", "CST"),
        ("America/Sao_Paulo", "São Paulo", "BRT"),
        ("America/Buenos_Aires", "Buenos Aires", "ART"),
        ("America/Lima", "Lima", "PET"),
        ("America/Bogota", "Bogotá", "COT"),
        ("America/Santiago", "Santiago", "CLT"),
        ("America/Caracas", "Caracas", "VET"),
        ("America/Los_Angeles", "San Francisco", "PST"),
        ("America/Los_Angeles", "Seattle", "PST"),
        ("America/New_York", "Boston", "EST"),
        ("America/New_York", "Miami", "EST"),
        ("America/New_York", "Atlanta", "EST"),
        ("America/Detroit", "Detroit", "EST"),
        ("America/Chicago", "Dallas", "CST"),
        ("America/Chicago", "Houston", "CST"),

        // Europe
        ("Europe/London", "London", "GMT"),
        ("Europe/Paris", "Paris", "CET"),
        ("Europe/Berlin", "Berlin", "CET"),
        ("Europe/Rome", "Rome", "CET"),
        ("Europe/Madrid", "Madrid", "CET"),
        ("Europe/Amsterdam", "Amsterdam", "CET"),
        ("Europe/Brussels", "Brussels", "CET"),
        ("Europe/Vienna", "Vienna", "CET"),
        ("Europe/Zurich", "Zurich", "CET"),
        ("Europe/Stockholm", "Stockholm", "CET"),
        ("Europe/Oslo", "Oslo", "CET"),
        ("Europe/Copenhagen", "Copenhagen", "CET"),
        ("Europe/Helsinki", "Helsinki", "EET"),
        ("Europe/Warsaw", "Warsaw", "CET"),
        ("Europe/Prague", "Prague", "CET"),
        ("Europe/Budapest", "Budapest", "CET"),
        ("Europe/Athens", "Athens", "EET"),
        ("Europe/Moscow", "Moscow", "MSK"),
        ("Europe/Istanbul", "Istanbul", "TRT"),
        ("Europe/Dublin", "Dublin", "GMT"),
        ("Europe/Lisbon", "Lisbon", "WET"),
        ("Europe/Kiev", "Kyiv", "EET"),
        ("Europe/Bucharest", "Bucharest", "EET"),

        // Asia
        ("Asia/Tokyo", "Tokyo", "JST"),
        ("Asia/Shanghai", "Shanghai", "CST"),
        ("Asia/Hong_Kong", "Hong Kong", "HKT"),
        ("Asia/Singapore", "Singapore", "SGT"),
        ("Asia/Seoul", "Seoul", "KST"),
        ("Asia/Bangkok", "Bangkok", "ICT"),
        ("Asia/Jakarta", "Jakarta", "WIB"),
        ("Asia/Manila", "Manila", "PHT"),
        ("Asia/Kuala_Lumpur", "Kuala Lumpur", "MYT"),
        ("Asia/Ho_Chi_Minh", "Ho Chi Minh", "ICT"),
        ("Asia/Taipei", "Taipei", "CST"),
        ("Asia/Kolkata", "Mumbai", "IST"),
        ("Asia/Kolkata", "Chennai", "IST"),
        ("Asia/Kolkata", "Delhi", "IST"),
        ("Asia/Kolkata", "Bangalore", "IST"),
        ("Asia/Kolkata", "Hyderabad", "IST"),
        ("Asia/Dubai", "Dubai", "GST"),
        ("Asia/Riyadh", "Riyadh", "AST"),
        ("Asia/Tel_Aviv", "Tel Aviv", "IST"),
        ("Asia/Jerusalem", "Jerusalem", "IST"),
        ("Asia/Beirut", "Beirut", "EET"),
        ("Asia/Karachi", "Karachi", "PKT"),
        ("Asia/Dhaka", "Dhaka", "BST"),
        ("Asia/Colombo", "Colombo", "IST"),
        ("Asia/Kathmandu", "Kathmandu", "NPT"),
        ("Asia/Yangon", "Yangon", "MMT"),
        ("Asia/Ho_Chi_Minh", "Hanoi", "ICT"),
        ("Asia/Tokyo", "Osaka", "JST"),
        ("Asia/Shanghai", "Beijing", "CST"),
        ("Asia/Shanghai", "Shenzhen", "CST"),
        ("Asia/Shanghai", "Guangzhou", "CST"),

        // Oceania
        ("Australia/Sydney", "Sydney", "AEST"),
        ("Australia/Melbourne", "Melbourne", "AEST"),
        ("Australia/Brisbane", "Brisbane", "AEST"),
        ("Australia/Perth", "Perth", "AWST"),
        ("Australia/Adelaide", "Adelaide", "ACST"),
        ("Pacific/Auckland", "Auckland", "NZST"),
        ("Pacific/Fiji", "Fiji", "FJT"),
        ("Pacific/Guam", "Guam", "ChST"),

        // Africa
        ("Africa/Cairo", "Cairo", "EET"),
        ("Africa/Johannesburg", "Johannesburg", "SAST"),
        ("Africa/Lagos", "Lagos", "WAT"),
        ("Africa/Nairobi", "Nairobi", "EAT"),
        ("Africa/Casablanca", "Casablanca", "WET"),
        ("Africa/Cape_Town", "Cape Town", "SAST"),
        ("Africa/Accra", "Accra", "GMT"),
        ("Africa/Addis_Ababa", "Addis Ababa", "EAT"),

        // Middle East
        ("Asia/Kuwait", "Kuwait City", "AST"),
        ("Asia/Qatar", "Doha", "AST"),
        ("Asia/Muscat", "Muscat", "GST"),
        ("Asia/Bahrain", "Manama", "AST"),
        ("Asia/Tehran", "Tehran", "IRST"),
        ("Asia/Baghdad", "Baghdad", "AST"),
        ("Asia/Amman", "Amman", "EET"),
    ]
}

struct TimeZoneQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [TimeZoneEntity] {
        return identifiers.compactMap { id in
            // First try to find in available timezones
            if let tz = AvailableTimeZones.all.first(where: { "\($0.identifier)_\($0.cityName)" == id }) {
                return TimeZoneEntity(
                    id: "\(tz.identifier)_\(tz.cityName)",
                    cityName: tz.cityName,
                    abbreviation: tz.abbreviation,
                    identifier: tz.identifier,
                    isHome: false
                )
            }
            // Also check saved timezones
            let saved = loadSavedTimeZones()
            if let savedTz = saved.first(where: { "\($0.identifier)_\($0.cityName)" == id }) {
                return TimeZoneEntity(from: savedTz)
            }
            return nil
        }
    }

    func suggestedEntities() async throws -> [TimeZoneEntity] {
        // Return all available world timezones
        AvailableTimeZones.all.map { tz in
            TimeZoneEntity(
                id: "\(tz.identifier)_\(tz.cityName)",
                cityName: tz.cityName,
                abbreviation: tz.abbreviation,
                identifier: tz.identifier,
                isHome: false
            )
        }
    }

    func defaultResult() async -> TimeZoneEntity? {
        // Return first saved timezone or San Francisco
        let saved = loadSavedTimeZones()
        if let first = saved.first {
            return TimeZoneEntity(from: first)
        }
        return TimeZoneEntity(
            id: "America/Los_Angeles_San Francisco",
            cityName: "San Francisco",
            abbreviation: "PST",
            identifier: "America/Los_Angeles",
            isHome: false
        )
    }

    private func loadSavedTimeZones() -> [WidgetTimeZone] {
        let defaults = UserDefaults(suiteName: "group.com.daylight.app")
        if let data = defaults?.data(forKey: "SavedTimeZones"),
           let decoded = try? JSONDecoder().decode([WidgetTimeZone].self, from: data) {
            return decoded
        }
        return []
    }
}

// MARK: - Small Widget Intent
struct SmallWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Timezone"
    static var description = IntentDescription("Choose which timezone to display")

    @Parameter(title: "Timezone")
    var timezone: TimeZoneEntity?
}

// MARK: - Medium Widget Intent
struct MediumWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Timezones"
    static var description = IntentDescription("Choose up to 3 timezones to display")

    @Parameter(title: "Timezone 1")
    var timezone1: TimeZoneEntity?

    @Parameter(title: "Timezone 2")
    var timezone2: TimeZoneEntity?

    @Parameter(title: "Timezone 3")
    var timezone3: TimeZoneEntity?
}

// MARK: - Large Widget Intent
struct LargeWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Timezones"
    static var description = IntentDescription("Choose up to 6 timezones to display")

    @Parameter(title: "Timezone 1")
    var timezone1: TimeZoneEntity?

    @Parameter(title: "Timezone 2")
    var timezone2: TimeZoneEntity?

    @Parameter(title: "Timezone 3")
    var timezone3: TimeZoneEntity?

    @Parameter(title: "Timezone 4")
    var timezone4: TimeZoneEntity?

    @Parameter(title: "Timezone 5")
    var timezone5: TimeZoneEntity?

    @Parameter(title: "Timezone 6")
    var timezone6: TimeZoneEntity?
}

// MARK: - Timeline Entry
struct DaylightEntry: TimelineEntry {
    let date: Date
    let timeZones: [WidgetTimeZone]

    var homeTimeZone: WidgetTimeZone? {
        timeZones.first(where: { $0.isHome }) ?? timeZones.first
    }
}

// MARK: - Small Widget Provider
struct SmallWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> DaylightEntry {
        DaylightEntry(date: Date(), timeZones: sampleTimeZones())
    }

    func snapshot(for configuration: SmallWidgetIntent, in context: Context) async -> DaylightEntry {
        let tz = configuration.timezone?.toWidgetTimeZone() ?? sampleTimeZones().first!
        return DaylightEntry(date: Date(), timeZones: [tz])
    }

    func timeline(for configuration: SmallWidgetIntent, in context: Context) async -> Timeline<DaylightEntry> {
        let tz = configuration.timezone?.toWidgetTimeZone() ?? loadTimeZones().first ?? sampleTimeZones().first!
        let homeTimeZone = loadTimeZones().first(where: { $0.isHome })

        var entries: [DaylightEntry] = []
        let currentDate = Date()
        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            var tzList = [tz]
            if let home = homeTimeZone, home.identifier != tz.identifier || home.cityName != tz.cityName {
                tzList.insert(home, at: 0)
            }
            entries.append(DaylightEntry(date: entryDate, timeZones: tzList))
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    private func loadTimeZones() -> [WidgetTimeZone] {
        let defaults = UserDefaults(suiteName: "group.com.daylight.app")
        if let data = defaults?.data(forKey: "SavedTimeZones"),
           let decoded = try? JSONDecoder().decode([WidgetTimeZone].self, from: data) {
            return decoded
        }
        return sampleTimeZones()
    }

    private func sampleTimeZones() -> [WidgetTimeZone] {
        [
            WidgetTimeZone(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST", isHome: true),
            WidgetTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false)
        ]
    }
}

// MARK: - Medium Widget Provider
struct MediumWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> DaylightEntry {
        DaylightEntry(date: Date(), timeZones: sampleTimeZones())
    }

    func snapshot(for configuration: MediumWidgetIntent, in context: Context) async -> DaylightEntry {
        let tzs = getTimeZones(from: configuration)
        return DaylightEntry(date: Date(), timeZones: tzs)
    }

    func timeline(for configuration: MediumWidgetIntent, in context: Context) async -> Timeline<DaylightEntry> {
        let tzs = getTimeZones(from: configuration)

        var entries: [DaylightEntry] = []
        let currentDate = Date()
        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            entries.append(DaylightEntry(date: entryDate, timeZones: tzs))
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    private func getTimeZones(from configuration: MediumWidgetIntent) -> [WidgetTimeZone] {
        var tzs: [WidgetTimeZone] = []
        if let tz1 = configuration.timezone1?.toWidgetTimeZone() { tzs.append(tz1) }
        if let tz2 = configuration.timezone2?.toWidgetTimeZone() { tzs.append(tz2) }
        if let tz3 = configuration.timezone3?.toWidgetTimeZone() { tzs.append(tz3) }

        if tzs.isEmpty {
            tzs = Array(loadTimeZones().prefix(3))
        }
        return tzs
    }

    private func loadTimeZones() -> [WidgetTimeZone] {
        let defaults = UserDefaults(suiteName: "group.com.daylight.app")
        if let data = defaults?.data(forKey: "SavedTimeZones"),
           let decoded = try? JSONDecoder().decode([WidgetTimeZone].self, from: data) {
            return decoded
        }
        return sampleTimeZones()
    }

    private func sampleTimeZones() -> [WidgetTimeZone] {
        [
            WidgetTimeZone(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST", isHome: true),
            WidgetTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false),
            WidgetTimeZone(identifier: "America/Chicago", cityName: "Dallas", abbreviation: "CST", isHome: false)
        ]
    }
}

// MARK: - Large Widget Provider
struct LargeWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> DaylightEntry {
        DaylightEntry(date: Date(), timeZones: sampleTimeZones())
    }

    func snapshot(for configuration: LargeWidgetIntent, in context: Context) async -> DaylightEntry {
        let tzs = getTimeZones(from: configuration)
        return DaylightEntry(date: Date(), timeZones: tzs)
    }

    func timeline(for configuration: LargeWidgetIntent, in context: Context) async -> Timeline<DaylightEntry> {
        let tzs = getTimeZones(from: configuration)

        var entries: [DaylightEntry] = []
        let currentDate = Date()
        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            entries.append(DaylightEntry(date: entryDate, timeZones: tzs))
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    private func getTimeZones(from configuration: LargeWidgetIntent) -> [WidgetTimeZone] {
        var tzs: [WidgetTimeZone] = []
        if let tz1 = configuration.timezone1?.toWidgetTimeZone() { tzs.append(tz1) }
        if let tz2 = configuration.timezone2?.toWidgetTimeZone() { tzs.append(tz2) }
        if let tz3 = configuration.timezone3?.toWidgetTimeZone() { tzs.append(tz3) }
        if let tz4 = configuration.timezone4?.toWidgetTimeZone() { tzs.append(tz4) }
        if let tz5 = configuration.timezone5?.toWidgetTimeZone() { tzs.append(tz5) }
        if let tz6 = configuration.timezone6?.toWidgetTimeZone() { tzs.append(tz6) }

        if tzs.isEmpty {
            tzs = Array(loadTimeZones().prefix(6))
        }
        return tzs
    }

    private func loadTimeZones() -> [WidgetTimeZone] {
        let defaults = UserDefaults(suiteName: "group.com.daylight.app")
        if let data = defaults?.data(forKey: "SavedTimeZones"),
           let decoded = try? JSONDecoder().decode([WidgetTimeZone].self, from: data) {
            return decoded
        }
        return sampleTimeZones()
    }

    private func sampleTimeZones() -> [WidgetTimeZone] {
        [
            WidgetTimeZone(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST", isHome: true),
            WidgetTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false),
            WidgetTimeZone(identifier: "America/Chicago", cityName: "Dallas", abbreviation: "CST", isHome: false),
            WidgetTimeZone(identifier: "Europe/London", cityName: "London", abbreviation: "GMT", isHome: false),
            WidgetTimeZone(identifier: "Asia/Tokyo", cityName: "Tokyo", abbreviation: "JST", isHome: false),
            WidgetTimeZone(identifier: "Australia/Sydney", cityName: "Sydney", abbreviation: "AEST", isHome: false)
        ]
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: DaylightEntry
    @Environment(\.colorScheme) var colorScheme

    var displayTimeZone: WidgetTimeZone {
        // Show the non-home timezone if available, otherwise show first
        entry.timeZones.first(where: { !$0.isHome }) ?? entry.timeZones.first ?? WidgetTimeZone(identifier: "UTC", cityName: "UTC", abbreviation: "UTC", isHome: true)
    }

    var isDaylight: Bool {
        let hour = displayTimeZone.currentHour()
        return hour >= 6 && hour < 18
    }

    var textGradient: LinearGradient {
        if isDaylight {
            return LinearGradient(
                colors: [Color(hex: "FFD900"), Color(hex: "FF9900")],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [Color(hex: "FFFFFF"), Color(hex: "757575")],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    var iconName: String {
        isDaylight ? "sun" : "moon"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Sun/Moon icon
            Image(iconName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundStyle(textGradient)

            // Offset from home (navigation icon if home, text otherwise)
            if displayTimeZone.isHomeTimezone(home: entry.homeTimeZone) {
                Image("navigation")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                    .foregroundStyle(textGradient)
            } else if let offset = displayTimeZone.offsetFromHome(home: entry.homeTimeZone) {
                Text(offset)
                    .font(.system(size: 12, weight: .thin))
                    .foregroundStyle(textGradient)
            }

            // Time
            Text(displayTimeZone.formattedTime())
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(textGradient)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            // City name
            Text(displayTimeZone.cityName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(textGradient)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            // Abbreviation
            Text(displayTimeZone.abbreviation)
                .font(.system(size: 12, weight: .thin))
                .foregroundStyle(textGradient)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.black, Color(hex: "1C1C1D")]
                    : [Color.white, Color(hex: "F2F2F7")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: DaylightEntry
    @Environment(\.colorScheme) var colorScheme

    var displayTimeZones: [WidgetTimeZone] {
        Array(entry.timeZones.prefix(3))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    ForEach(Array(displayTimeZones.enumerated()), id: \.1.cityName) { index, tz in
                        TimeZoneRow(
                            timeZone: tz,
                            homeTimeZone: entry.homeTimeZone,
                            width: geometry.size.width - 32,
                            colorScheme: colorScheme
                        )

                        if index < displayTimeZones.count - 1 {
                            Spacer().frame(height: 8)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)

                // Center line
                Rectangle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.2))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.black, Color(hex: "1C1C1D")]
                    : [Color.white, Color(hex: "F2F2F7")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - Time Zone Row (for Medium/Large Widget)
struct TimeZoneRow: View {
    let timeZone: WidgetTimeZone
    let homeTimeZone: WidgetTimeZone?
    let width: CGFloat
    var colorScheme: ColorScheme

    private let daylightGradient = LinearGradient(
        colors: [Color(hex: "FFD900"), Color(hex: "FF9900")],
        startPoint: .leading,
        endPoint: .trailing
    )

    private var nightColor: Color {
        colorScheme == .dark ? Color(hex: "757575").opacity(0.2) : Color(hex: "C7C7CC")
    }

    private var currentHour: Double {
        let hour = timeZone.currentHour()
        let minute = timeZone.currentMinute()
        return Double(hour) + Double(minute) / 60.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // City name and time
            HStack {
                Text(timeZone.cityName)
                    .font(.system(size: 8, weight: .thin))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Spacer()

                Text(timeZone.formattedTime())
                    .font(.system(size: 8, weight: .thin))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }

            // Day/Night bar
            GeometryReader { geometry in
                let barWidth = geometry.size.width
                let segments = calculateDaySegments(barWidth: barWidth)

                ZStack(alignment: .leading) {
                    // Night background
                    Capsule()
                        .fill(nightColor)
                        .frame(height: 6)

                    // Daylight segments
                    ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                        Capsule()
                            .fill(daylightGradient)
                            .frame(width: segment.width, height: 6)
                            .offset(x: segment.startX)
                    }
                }
            }
            .frame(height: 6)
        }
    }

    private struct DaySegment {
        let startX: CGFloat
        let width: CGFloat
    }

    private func calculateDaySegments(barWidth: CGFloat) -> [DaySegment] {
        var segments: [DaySegment] = []

        let pixelsPerHour = barWidth / 24.0
        let centerX = barWidth / 2.0

        for dayOffset in -1...1 {
            let dayOffsetHours = Double(dayOffset) * 24.0
            let dayStart = 6.0 + dayOffsetHours
            let dayEnd = 18.0 + dayOffsetHours
            let hoursToStart = dayStart - currentHour
            let hoursToEnd = dayEnd - currentHour

            if hoursToEnd >= -12 && hoursToStart <= 12 {
                let clampedStart = max(-12, hoursToStart)
                let clampedEnd = min(12, hoursToEnd)
                let startX = centerX + CGFloat(clampedStart) * pixelsPerHour
                let endX = centerX + CGFloat(clampedEnd) * pixelsPerHour
                let segmentStartX = max(0, startX)
                let segmentEndX = min(barWidth, endX)
                let segmentWidth = max(0, segmentEndX - segmentStartX)

                if segmentWidth > 0 {
                    segments.append(DaySegment(startX: segmentStartX, width: segmentWidth))
                }
            }
        }

        return segments
    }
}

// MARK: - Large Widget View (continuation of Medium - more rows)
struct LargeWidgetView: View {
    let entry: DaylightEntry
    @Environment(\.colorScheme) var colorScheme

    var displayTimeZones: [WidgetTimeZone] {
        Array(entry.timeZones.prefix(6))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    ForEach(Array(displayTimeZones.enumerated()), id: \.1.cityName) { index, tz in
                        TimeZoneRow(
                            timeZone: tz,
                            homeTimeZone: entry.homeTimeZone,
                            width: geometry.size.width - 32,
                            colorScheme: colorScheme
                        )

                        if index < displayTimeZones.count - 1 {
                            Spacer().frame(height: 8)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)

                // Center line
                Rectangle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.2))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.black, Color(hex: "1C1C1D")]
                    : [Color.white, Color(hex: "F2F2F7")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - Small Widget
struct SmallDaylightWidget: Widget {
    let kind: String = "SmallDaylightWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SmallWidgetIntent.self, provider: SmallWidgetProvider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("Daylight")
        .description("View a single timezone")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Medium Widget
struct MediumDaylightWidget: Widget {
    let kind: String = "MediumDaylightWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: MediumWidgetIntent.self, provider: MediumWidgetProvider()) { entry in
            MediumWidgetView(entry: entry)
        }
        .configurationDisplayName("Daylight")
        .description("View up to 3 timezones")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Large Widget
struct LargeDaylightWidget: Widget {
    let kind: String = "LargeDaylightWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: LargeWidgetIntent.self, provider: LargeWidgetProvider()) { entry in
            LargeWidgetView(entry: entry)
        }
        .configurationDisplayName("Daylight")
        .description("View up to 6 timezones")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    SmallDaylightWidget()
} timeline: {
    DaylightEntry(date: Date(), timeZones: [
        WidgetTimeZone(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST", isHome: true),
        WidgetTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false)
    ])
}

#Preview(as: .systemMedium) {
    MediumDaylightWidget()
} timeline: {
    DaylightEntry(date: Date(), timeZones: [
        WidgetTimeZone(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST", isHome: true),
        WidgetTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false),
        WidgetTimeZone(identifier: "America/Chicago", cityName: "Dallas", abbreviation: "CST", isHome: false)
    ])
}

#Preview(as: .systemLarge) {
    LargeDaylightWidget()
} timeline: {
    DaylightEntry(date: Date(), timeZones: [
        WidgetTimeZone(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST", isHome: true),
        WidgetTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false),
        WidgetTimeZone(identifier: "America/Chicago", cityName: "Dallas", abbreviation: "CST", isHome: false),
        WidgetTimeZone(identifier: "Europe/London", cityName: "London", abbreviation: "GMT", isHome: false)
    ])
}
