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
        ("Asia/Dubai", "Dubai", "GST"),
        ("Asia/Riyadh", "Riyadh", "AST"),
        ("Asia/Tel_Aviv", "Tel Aviv", "IST"),
        ("Asia/Beirut", "Beirut", "EET"),
        ("Asia/Karachi", "Karachi", "PKT"),
        ("Asia/Dhaka", "Dhaka", "BST"),
        ("Asia/Colombo", "Colombo", "IST"),
        ("Asia/Kathmandu", "Kathmandu", "NPT"),

        // Oceania
        ("Australia/Sydney", "Sydney", "AEST"),
        ("Australia/Melbourne", "Melbourne", "AEST"),
        ("Australia/Brisbane", "Brisbane", "AEST"),
        ("Australia/Perth", "Perth", "AWST"),
        ("Australia/Adelaide", "Adelaide", "ACST"),
        ("Pacific/Auckland", "Auckland", "NZST"),
        ("Pacific/Fiji", "Fiji", "FJT"),

        // Africa
        ("Africa/Cairo", "Cairo", "EET"),
        ("Africa/Johannesburg", "Johannesburg", "SAST"),
        ("Africa/Lagos", "Lagos", "WAT"),
        ("Africa/Nairobi", "Nairobi", "EAT"),
        ("Africa/Casablanca", "Casablanca", "WET"),
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
        // Extract the actual timezone identifier (before the underscore)
        let identifier = id.components(separatedBy: "_").first ?? id
        return WidgetTimeZone(identifier: identifier, cityName: cityName, abbreviation: abbreviation, isHome: isHome)
    }
}

struct TimeZoneQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [TimeZoneEntity] {
        identifiers.compactMap { id in
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

// MARK: - Small Widget Intent
struct SmallWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Time Zone"
    static var description = IntentDescription("Choose a time zone to display")

    @Parameter(title: "Time Zone")
    var timeZone: TimeZoneEntity?

    init() {}

    init(timeZone: TimeZoneEntity) {
        self.timeZone = timeZone
    }
}

// MARK: - Medium Widget Intent
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

    init(timeZone1: TimeZoneEntity?, timeZone2: TimeZoneEntity?, timeZone3: TimeZoneEntity?) {
        self.timeZone1 = timeZone1
        self.timeZone2 = timeZone2
        self.timeZone3 = timeZone3
    }
}

// MARK: - Large Widget Intent
struct LargeWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Time Zones"
    static var description = IntentDescription("Choose up to 6 time zones to display")

    @Parameter(title: "Time Zone 1")
    var timeZone1: TimeZoneEntity?

    @Parameter(title: "Time Zone 2")
    var timeZone2: TimeZoneEntity?

    @Parameter(title: "Time Zone 3")
    var timeZone3: TimeZoneEntity?

    @Parameter(title: "Time Zone 4")
    var timeZone4: TimeZoneEntity?

    @Parameter(title: "Time Zone 5")
    var timeZone5: TimeZoneEntity?

    @Parameter(title: "Time Zone 6")
    var timeZone6: TimeZoneEntity?

    init() {}

    init(timeZone1: TimeZoneEntity?, timeZone2: TimeZoneEntity?, timeZone3: TimeZoneEntity?, timeZone4: TimeZoneEntity?, timeZone5: TimeZoneEntity?, timeZone6: TimeZoneEntity?) {
        self.timeZone1 = timeZone1
        self.timeZone2 = timeZone2
        self.timeZone3 = timeZone3
        self.timeZone4 = timeZone4
        self.timeZone5 = timeZone5
        self.timeZone6 = timeZone6
    }
}

// MARK: - Timeline Entry
struct DaylightEntry: TimelineEntry {
    let date: Date
    let timeZones: [WidgetTimeZone]

    var homeTimeZone: WidgetTimeZone? {
        // Try to get home from saved data
        let defaults = UserDefaults(suiteName: "group.com.daylight.app")
        if let data = defaults?.data(forKey: "SavedTimeZones"),
           let decoded = try? JSONDecoder().decode([WidgetTimeZone].self, from: data),
           let home = decoded.first(where: { $0.isHome }) {
            return home
        }
        return timeZones.first
    }
}

// MARK: - Small Widget Provider
struct SmallWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> DaylightEntry {
        DaylightEntry(date: Date(), timeZones: [
            WidgetTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false)
        ])
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
            let entry = DaylightEntry(date: entryDate, timeZones: [tz])
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

// MARK: - Medium Widget Provider
struct MediumWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> DaylightEntry {
        DaylightEntry(date: Date(), timeZones: sampleTimeZones())
    }

    func snapshot(for configuration: MediumWidgetIntent, in context: Context) async -> DaylightEntry {
        let timeZones = extractTimeZones(from: configuration)
        return DaylightEntry(date: Date(), timeZones: timeZones)
    }

    func timeline(for configuration: MediumWidgetIntent, in context: Context) async -> Timeline<DaylightEntry> {
        let timeZones = extractTimeZones(from: configuration)

        let currentDate = Date()
        var entries: [DaylightEntry] = []

        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = DaylightEntry(date: entryDate, timeZones: timeZones)
            entries.append(entry)
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
        let timeZones = extractTimeZones(from: configuration)
        return DaylightEntry(date: Date(), timeZones: timeZones)
    }

    func timeline(for configuration: LargeWidgetIntent, in context: Context) async -> Timeline<DaylightEntry> {
        let timeZones = extractTimeZones(from: configuration)

        let currentDate = Date()
        var entries: [DaylightEntry] = []

        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = DaylightEntry(date: entryDate, timeZones: timeZones)
            entries.append(entry)
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
        entry.timeZones.first ?? WidgetTimeZone(identifier: "UTC", cityName: "UTC", abbreviation: "UTC", isHome: true)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Offset from home (navigation icon if home, text otherwise)
            if displayTimeZone.isHomeTimezone(home: entry.homeTimeZone) {
                Image("navigation")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10, height: 10)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            } else if let offset = displayTimeZone.offsetFromHome(home: entry.homeTimeZone) {
                Text(offset)
                    .font(.system(size: 8, weight: .thin))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }

            // Time
            Text(displayTimeZone.formattedTime())
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Spacer()

            // City name
            Text(displayTimeZone.cityName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            // Abbreviation
            Text(displayTimeZone.abbreviation)
                .font(.system(size: 8, weight: .thin))
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
        .padding(18)
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
                    ForEach(Array(displayTimeZones.enumerated()), id: \.1.identifier) { index, tz in
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
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
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

        // The bar represents 24 hours, centered on now
        // Daylight is 6 AM to 6 PM
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
                    ForEach(Array(displayTimeZones.enumerated()), id: \.1.identifier) { index, tz in
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
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
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

// MARK: - Small Widget Configuration
struct SmallDaylightWidget: Widget {
    let kind: String = "SmallDaylightWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SmallWidgetIntent.self, provider: SmallWidgetProvider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("Daylight")
        .description("View a single time zone")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Medium Widget Configuration
struct MediumDaylightWidget: Widget {
    let kind: String = "MediumDaylightWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: MediumWidgetIntent.self, provider: MediumWidgetProvider()) { entry in
            MediumWidgetView(entry: entry)
        }
        .configurationDisplayName("Daylight")
        .description("View up to 3 time zones")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Large Widget Configuration
struct LargeDaylightWidget: Widget {
    let kind: String = "LargeDaylightWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: LargeWidgetIntent.self, provider: LargeWidgetProvider()) { entry in
            LargeWidgetView(entry: entry)
        }
        .configurationDisplayName("Daylight")
        .description("View up to 6 time zones")
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

// MARK: - Previews
#Preview(as: .systemSmall) {
    SmallDaylightWidget()
} timeline: {
    DaylightEntry(date: Date(), timeZones: [
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
        WidgetTimeZone(identifier: "Europe/London", cityName: "London", abbreviation: "GMT", isHome: false),
        WidgetTimeZone(identifier: "Asia/Tokyo", cityName: "Tokyo", abbreviation: "JST", isHome: false),
        WidgetTimeZone(identifier: "Australia/Sydney", cityName: "Sydney", abbreviation: "AEST", isHome: false)
    ])
}
