import Foundation
import SwiftUI
import Combine
import WidgetKit

struct TimeZoneItem: Identifiable, Codable, Equatable {
    let id: UUID
    let identifier: String
    let cityName: String
    let abbreviation: String
    var isHome: Bool

    var timeZone: TimeZone {
        TimeZone(identifier: identifier) ?? .current
    }

    init(id: UUID = UUID(), identifier: String, cityName: String, abbreviation: String, isHome: Bool = false) {
        self.id = id
        self.identifier = identifier
        self.cityName = cityName
        self.abbreviation = abbreviation
        self.isHome = isHome
    }

    func currentHour(offsetBy hours: Double = 0) -> Int {
        let date = Date().addingTimeInterval(hours * 3600)
        let calendar = Calendar.current
        var calendarWithZone = calendar
        calendarWithZone.timeZone = timeZone
        return calendarWithZone.component(.hour, from: date)
    }

    func currentMinute(offsetBy hours: Double = 0) -> Int {
        let date = Date().addingTimeInterval(hours * 3600)
        let calendar = Calendar.current
        var calendarWithZone = calendar
        calendarWithZone.timeZone = timeZone
        return calendarWithZone.component(.minute, from: date)
    }

    func formattedTime(offsetBy hours: Double = 0) -> String {
        let date = Date().addingTimeInterval(hours * 3600)
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "h:mma"
        return formatter.string(from: date).uppercased()
    }

    func isDaylight(offsetBy hours: Double = 0) -> Bool {
        let hour = currentHour(offsetBy: hours)
        return hour >= 6 && hour < 18
    }
}

class TimeZoneStore: ObservableObject {
    @Published var timeZones: [TimeZoneItem] = []

    private let saveKey = "SavedTimeZones"

    init() {
        loadTimeZones()
        if timeZones.isEmpty {
            addDefaultTimeZones()
        }
    }

    private func addDefaultTimeZones() {
        let defaults: [TimeZoneItem] = [
            TimeZoneItem(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST", isHome: true),
            TimeZoneItem(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false),
            TimeZoneItem(identifier: "Asia/Dubai", cityName: "Dubai", abbreviation: "GST", isHome: false)
        ]
        timeZones = defaults
        saveTimeZones()
    }

    func addTimeZone(_ item: TimeZoneItem) {
        timeZones.append(item)
        saveTimeZones()
    }

    func removeTimeZone(at offsets: IndexSet) {
        timeZones.remove(atOffsets: offsets)
        if !timeZones.contains(where: { $0.isHome }) && !timeZones.isEmpty {
            timeZones[0].isHome = true
        }
        saveTimeZones()
    }

    func removeTimeZone(_ item: TimeZoneItem) {
        timeZones.removeAll { $0.id == item.id }
        if !timeZones.contains(where: { $0.isHome }) && !timeZones.isEmpty {
            timeZones[0].isHome = true
        }
        saveTimeZones()
    }

    func setAsHome(_ item: TimeZoneItem) {
        for i in 0..<timeZones.count {
            timeZones[i].isHome = (timeZones[i].id == item.id)
        }
        saveTimeZones()
    }

    func moveTimeZone(from source: IndexSet, to destination: Int) {
        timeZones.move(fromOffsets: source, toOffset: destination)
        saveTimeZones()
    }

    private func saveTimeZones() {
        if let encoded = try? JSONEncoder().encode(timeZones) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
            // Also save to App Group for widget access
            let sharedDefaults = UserDefaults(suiteName: "group.com.daylight.app")
            sharedDefaults?.set(encoded, forKey: saveKey)
            // Reload widgets when data changes
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func loadTimeZones() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([TimeZoneItem].self, from: data) {
            timeZones = decoded
        }
    }
}

struct AvailableTimeZone: Identifiable {
    let id = UUID()
    let identifier: String
    let cityName: String
    let abbreviation: String

    static let all: [AvailableTimeZone] = [
        // North America - United States
        AvailableTimeZone(identifier: "America/New_York", cityName: "New York", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/New_York", cityName: "Miami", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/New_York", cityName: "Boston", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/New_York", cityName: "Philadelphia", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/New_York", cityName: "Atlanta", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/New_York", cityName: "Washington D.C.", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/New_York", cityName: "Detroit", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/Chicago", cityName: "Chicago", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Chicago", cityName: "Houston", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Chicago", cityName: "Dallas", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Chicago", cityName: "Austin", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Chicago", cityName: "San Antonio", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Chicago", cityName: "New Orleans", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Chicago", cityName: "Minneapolis", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Chicago", cityName: "Nashville", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Denver", cityName: "Denver", abbreviation: "MST"),
        AvailableTimeZone(identifier: "America/Denver", cityName: "Salt Lake City", abbreviation: "MST"),
        AvailableTimeZone(identifier: "America/Denver", cityName: "Albuquerque", abbreviation: "MST"),
        AvailableTimeZone(identifier: "America/Phoenix", cityName: "Phoenix", abbreviation: "MST"),
        AvailableTimeZone(identifier: "America/Los_Angeles", cityName: "Los Angeles", abbreviation: "PST"),
        AvailableTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST"),
        AvailableTimeZone(identifier: "America/Los_Angeles", cityName: "San Diego", abbreviation: "PST"),
        AvailableTimeZone(identifier: "America/Los_Angeles", cityName: "Seattle", abbreviation: "PST"),
        AvailableTimeZone(identifier: "America/Los_Angeles", cityName: "Portland", abbreviation: "PST"),
        AvailableTimeZone(identifier: "America/Los_Angeles", cityName: "Las Vegas", abbreviation: "PST"),
        AvailableTimeZone(identifier: "America/Anchorage", cityName: "Anchorage", abbreviation: "AKST"),
        AvailableTimeZone(identifier: "Pacific/Honolulu", cityName: "Honolulu", abbreviation: "HST"),

        // North America - Canada
        AvailableTimeZone(identifier: "America/Toronto", cityName: "Toronto", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/Toronto", cityName: "Ottawa", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/Toronto", cityName: "Montreal", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/Winnipeg", cityName: "Winnipeg", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Edmonton", cityName: "Edmonton", abbreviation: "MST"),
        AvailableTimeZone(identifier: "America/Edmonton", cityName: "Calgary", abbreviation: "MST"),
        AvailableTimeZone(identifier: "America/Vancouver", cityName: "Vancouver", abbreviation: "PST"),
        AvailableTimeZone(identifier: "America/Halifax", cityName: "Halifax", abbreviation: "AST"),
        AvailableTimeZone(identifier: "America/St_Johns", cityName: "St. John's", abbreviation: "NST"),

        // North America - Mexico
        AvailableTimeZone(identifier: "America/Mexico_City", cityName: "Mexico City", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Cancun", cityName: "Cancun", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/Tijuana", cityName: "Tijuana", abbreviation: "PST"),
        AvailableTimeZone(identifier: "America/Monterrey", cityName: "Monterrey", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Guadalajara", cityName: "Guadalajara", abbreviation: "CST"),

        // Central America & Caribbean
        AvailableTimeZone(identifier: "America/Guatemala", cityName: "Guatemala City", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Panama", cityName: "Panama City", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/Costa_Rica", cityName: "San José", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Havana", cityName: "Havana", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Jamaica", cityName: "Kingston", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/Puerto_Rico", cityName: "San Juan", abbreviation: "AST"),
        AvailableTimeZone(identifier: "America/Santo_Domingo", cityName: "Santo Domingo", abbreviation: "AST"),

        // South America
        AvailableTimeZone(identifier: "America/Sao_Paulo", cityName: "São Paulo", abbreviation: "BRT"),
        AvailableTimeZone(identifier: "America/Sao_Paulo", cityName: "Rio de Janeiro", abbreviation: "BRT"),
        AvailableTimeZone(identifier: "America/Sao_Paulo", cityName: "Brasília", abbreviation: "BRT"),
        AvailableTimeZone(identifier: "America/Argentina/Buenos_Aires", cityName: "Buenos Aires", abbreviation: "ART"),
        AvailableTimeZone(identifier: "America/Santiago", cityName: "Santiago", abbreviation: "CLT"),
        AvailableTimeZone(identifier: "America/Lima", cityName: "Lima", abbreviation: "PET"),
        AvailableTimeZone(identifier: "America/Bogota", cityName: "Bogotá", abbreviation: "COT"),
        AvailableTimeZone(identifier: "America/Bogota", cityName: "Medellín", abbreviation: "COT"),
        AvailableTimeZone(identifier: "America/Caracas", cityName: "Caracas", abbreviation: "VET"),
        AvailableTimeZone(identifier: "America/Guayaquil", cityName: "Quito", abbreviation: "ECT"),
        AvailableTimeZone(identifier: "America/Guayaquil", cityName: "Guayaquil", abbreviation: "ECT"),
        AvailableTimeZone(identifier: "America/Montevideo", cityName: "Montevideo", abbreviation: "UYT"),
        AvailableTimeZone(identifier: "America/Asuncion", cityName: "Asunción", abbreviation: "PYT"),
        AvailableTimeZone(identifier: "America/La_Paz", cityName: "La Paz", abbreviation: "BOT"),

        // Europe - Western
        AvailableTimeZone(identifier: "Europe/London", cityName: "London", abbreviation: "GMT"),
        AvailableTimeZone(identifier: "Europe/London", cityName: "Edinburgh", abbreviation: "GMT"),
        AvailableTimeZone(identifier: "Europe/London", cityName: "Manchester", abbreviation: "GMT"),
        AvailableTimeZone(identifier: "Europe/Dublin", cityName: "Dublin", abbreviation: "GMT"),
        AvailableTimeZone(identifier: "Europe/Lisbon", cityName: "Lisbon", abbreviation: "WET"),
        AvailableTimeZone(identifier: "Atlantic/Reykjavik", cityName: "Reykjavik", abbreviation: "GMT"),

        // Europe - Central
        AvailableTimeZone(identifier: "Europe/Paris", cityName: "Paris", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Berlin", cityName: "Berlin", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Berlin", cityName: "Munich", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Berlin", cityName: "Frankfurt", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Amsterdam", cityName: "Amsterdam", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Brussels", cityName: "Brussels", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Zurich", cityName: "Zürich", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Zurich", cityName: "Geneva", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Vienna", cityName: "Vienna", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Rome", cityName: "Rome", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Rome", cityName: "Milan", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Madrid", cityName: "Madrid", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Madrid", cityName: "Barcelona", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Stockholm", cityName: "Stockholm", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Oslo", cityName: "Oslo", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Copenhagen", cityName: "Copenhagen", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Warsaw", cityName: "Warsaw", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Prague", cityName: "Prague", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Budapest", cityName: "Budapest", abbreviation: "CET"),

        // Europe - Eastern
        AvailableTimeZone(identifier: "Europe/Athens", cityName: "Athens", abbreviation: "EET"),
        AvailableTimeZone(identifier: "Europe/Helsinki", cityName: "Helsinki", abbreviation: "EET"),
        AvailableTimeZone(identifier: "Europe/Bucharest", cityName: "Bucharest", abbreviation: "EET"),
        AvailableTimeZone(identifier: "Europe/Sofia", cityName: "Sofia", abbreviation: "EET"),
        AvailableTimeZone(identifier: "Europe/Kiev", cityName: "Kyiv", abbreviation: "EET"),
        AvailableTimeZone(identifier: "Europe/Istanbul", cityName: "Istanbul", abbreviation: "TRT"),

        // Russia & CIS
        AvailableTimeZone(identifier: "Europe/Moscow", cityName: "Moscow", abbreviation: "MSK"),
        AvailableTimeZone(identifier: "Europe/Moscow", cityName: "St. Petersburg", abbreviation: "MSK"),
        AvailableTimeZone(identifier: "Europe/Samara", cityName: "Samara", abbreviation: "SAMT"),
        AvailableTimeZone(identifier: "Asia/Yekaterinburg", cityName: "Yekaterinburg", abbreviation: "YEKT"),
        AvailableTimeZone(identifier: "Asia/Novosibirsk", cityName: "Novosibirsk", abbreviation: "NOVT"),
        AvailableTimeZone(identifier: "Asia/Krasnoyarsk", cityName: "Krasnoyarsk", abbreviation: "KRAT"),
        AvailableTimeZone(identifier: "Asia/Irkutsk", cityName: "Irkutsk", abbreviation: "IRKT"),
        AvailableTimeZone(identifier: "Asia/Vladivostok", cityName: "Vladivostok", abbreviation: "VLAT"),
        AvailableTimeZone(identifier: "Asia/Almaty", cityName: "Almaty", abbreviation: "ALMT"),
        AvailableTimeZone(identifier: "Asia/Tashkent", cityName: "Tashkent", abbreviation: "UZT"),
        AvailableTimeZone(identifier: "Asia/Baku", cityName: "Baku", abbreviation: "AZT"),
        AvailableTimeZone(identifier: "Asia/Tbilisi", cityName: "Tbilisi", abbreviation: "GET"),
        AvailableTimeZone(identifier: "Asia/Yerevan", cityName: "Yerevan", abbreviation: "AMT"),
        AvailableTimeZone(identifier: "Europe/Minsk", cityName: "Minsk", abbreviation: "MSK"),

        // Middle East
        AvailableTimeZone(identifier: "Asia/Dubai", cityName: "Dubai", abbreviation: "GST"),
        AvailableTimeZone(identifier: "Asia/Dubai", cityName: "Abu Dhabi", abbreviation: "GST"),
        AvailableTimeZone(identifier: "Asia/Qatar", cityName: "Doha", abbreviation: "AST"),
        AvailableTimeZone(identifier: "Asia/Riyadh", cityName: "Riyadh", abbreviation: "AST"),
        AvailableTimeZone(identifier: "Asia/Riyadh", cityName: "Jeddah", abbreviation: "AST"),
        AvailableTimeZone(identifier: "Asia/Kuwait", cityName: "Kuwait City", abbreviation: "AST"),
        AvailableTimeZone(identifier: "Asia/Bahrain", cityName: "Manama", abbreviation: "AST"),
        AvailableTimeZone(identifier: "Asia/Muscat", cityName: "Muscat", abbreviation: "GST"),
        AvailableTimeZone(identifier: "Asia/Jerusalem", cityName: "Jerusalem", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Jerusalem", cityName: "Tel Aviv", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Beirut", cityName: "Beirut", abbreviation: "EET"),
        AvailableTimeZone(identifier: "Asia/Amman", cityName: "Amman", abbreviation: "EET"),
        AvailableTimeZone(identifier: "Asia/Baghdad", cityName: "Baghdad", abbreviation: "AST"),
        AvailableTimeZone(identifier: "Asia/Tehran", cityName: "Tehran", abbreviation: "IRST"),

        // South Asia
        AvailableTimeZone(identifier: "Asia/Kolkata", cityName: "Mumbai", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Kolkata", cityName: "Delhi", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Kolkata", cityName: "Bangalore", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Kolkata", cityName: "Kolkata", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Kolkata", cityName: "Hyderabad", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Kolkata", cityName: "Pune", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Kolkata", cityName: "Ahmedabad", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Karachi", cityName: "Karachi", abbreviation: "PKT"),
        AvailableTimeZone(identifier: "Asia/Karachi", cityName: "Lahore", abbreviation: "PKT"),
        AvailableTimeZone(identifier: "Asia/Karachi", cityName: "Islamabad", abbreviation: "PKT"),
        AvailableTimeZone(identifier: "Asia/Dhaka", cityName: "Dhaka", abbreviation: "BST"),
        AvailableTimeZone(identifier: "Asia/Colombo", cityName: "Colombo", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Kathmandu", cityName: "Kathmandu", abbreviation: "NPT"),

        // Southeast Asia
        AvailableTimeZone(identifier: "Asia/Singapore", cityName: "Singapore", abbreviation: "SGT"),
        AvailableTimeZone(identifier: "Asia/Kuala_Lumpur", cityName: "Kuala Lumpur", abbreviation: "MYT"),
        AvailableTimeZone(identifier: "Asia/Bangkok", cityName: "Bangkok", abbreviation: "ICT"),
        AvailableTimeZone(identifier: "Asia/Ho_Chi_Minh", cityName: "Ho Chi Minh City", abbreviation: "ICT"),
        AvailableTimeZone(identifier: "Asia/Ho_Chi_Minh", cityName: "Hanoi", abbreviation: "ICT"),
        AvailableTimeZone(identifier: "Asia/Jakarta", cityName: "Jakarta", abbreviation: "WIB"),
        AvailableTimeZone(identifier: "Asia/Makassar", cityName: "Bali", abbreviation: "WITA"),
        AvailableTimeZone(identifier: "Asia/Manila", cityName: "Manila", abbreviation: "PHT"),
        AvailableTimeZone(identifier: "Asia/Yangon", cityName: "Yangon", abbreviation: "MMT"),
        AvailableTimeZone(identifier: "Asia/Phnom_Penh", cityName: "Phnom Penh", abbreviation: "ICT"),

        // East Asia
        AvailableTimeZone(identifier: "Asia/Tokyo", cityName: "Tokyo", abbreviation: "JST"),
        AvailableTimeZone(identifier: "Asia/Tokyo", cityName: "Osaka", abbreviation: "JST"),
        AvailableTimeZone(identifier: "Asia/Tokyo", cityName: "Kyoto", abbreviation: "JST"),
        AvailableTimeZone(identifier: "Asia/Seoul", cityName: "Seoul", abbreviation: "KST"),
        AvailableTimeZone(identifier: "Asia/Seoul", cityName: "Busan", abbreviation: "KST"),
        AvailableTimeZone(identifier: "Asia/Shanghai", cityName: "Shanghai", abbreviation: "CST"),
        AvailableTimeZone(identifier: "Asia/Shanghai", cityName: "Beijing", abbreviation: "CST"),
        AvailableTimeZone(identifier: "Asia/Shanghai", cityName: "Guangzhou", abbreviation: "CST"),
        AvailableTimeZone(identifier: "Asia/Shanghai", cityName: "Shenzhen", abbreviation: "CST"),
        AvailableTimeZone(identifier: "Asia/Shanghai", cityName: "Chengdu", abbreviation: "CST"),
        AvailableTimeZone(identifier: "Asia/Hong_Kong", cityName: "Hong Kong", abbreviation: "HKT"),
        AvailableTimeZone(identifier: "Asia/Macau", cityName: "Macau", abbreviation: "CST"),
        AvailableTimeZone(identifier: "Asia/Taipei", cityName: "Taipei", abbreviation: "CST"),
        AvailableTimeZone(identifier: "Asia/Ulaanbaatar", cityName: "Ulaanbaatar", abbreviation: "ULAT"),

        // Africa - North
        AvailableTimeZone(identifier: "Africa/Cairo", cityName: "Cairo", abbreviation: "EET"),
        AvailableTimeZone(identifier: "Africa/Cairo", cityName: "Alexandria", abbreviation: "EET"),
        AvailableTimeZone(identifier: "Africa/Casablanca", cityName: "Casablanca", abbreviation: "WET"),
        AvailableTimeZone(identifier: "Africa/Casablanca", cityName: "Marrakech", abbreviation: "WET"),
        AvailableTimeZone(identifier: "Africa/Tunis", cityName: "Tunis", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Africa/Algiers", cityName: "Algiers", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Africa/Tripoli", cityName: "Tripoli", abbreviation: "EET"),

        // Africa - West
        AvailableTimeZone(identifier: "Africa/Lagos", cityName: "Lagos", abbreviation: "WAT"),
        AvailableTimeZone(identifier: "Africa/Lagos", cityName: "Abuja", abbreviation: "WAT"),
        AvailableTimeZone(identifier: "Africa/Accra", cityName: "Accra", abbreviation: "GMT"),
        AvailableTimeZone(identifier: "Africa/Dakar", cityName: "Dakar", abbreviation: "GMT"),

        // Africa - East
        AvailableTimeZone(identifier: "Africa/Nairobi", cityName: "Nairobi", abbreviation: "EAT"),
        AvailableTimeZone(identifier: "Africa/Addis_Ababa", cityName: "Addis Ababa", abbreviation: "EAT"),
        AvailableTimeZone(identifier: "Africa/Dar_es_Salaam", cityName: "Dar es Salaam", abbreviation: "EAT"),
        AvailableTimeZone(identifier: "Africa/Kampala", cityName: "Kampala", abbreviation: "EAT"),
        AvailableTimeZone(identifier: "Africa/Kigali", cityName: "Kigali", abbreviation: "CAT"),

        // Africa - South
        AvailableTimeZone(identifier: "Africa/Johannesburg", cityName: "Johannesburg", abbreviation: "SAST"),
        AvailableTimeZone(identifier: "Africa/Johannesburg", cityName: "Cape Town", abbreviation: "SAST"),
        AvailableTimeZone(identifier: "Africa/Johannesburg", cityName: "Durban", abbreviation: "SAST"),
        AvailableTimeZone(identifier: "Africa/Harare", cityName: "Harare", abbreviation: "CAT"),
        AvailableTimeZone(identifier: "Indian/Mauritius", cityName: "Port Louis", abbreviation: "MUT"),

        // Australia & New Zealand
        AvailableTimeZone(identifier: "Australia/Sydney", cityName: "Sydney", abbreviation: "AEST"),
        AvailableTimeZone(identifier: "Australia/Melbourne", cityName: "Melbourne", abbreviation: "AEST"),
        AvailableTimeZone(identifier: "Australia/Brisbane", cityName: "Brisbane", abbreviation: "AEST"),
        AvailableTimeZone(identifier: "Australia/Perth", cityName: "Perth", abbreviation: "AWST"),
        AvailableTimeZone(identifier: "Australia/Adelaide", cityName: "Adelaide", abbreviation: "ACST"),
        AvailableTimeZone(identifier: "Australia/Darwin", cityName: "Darwin", abbreviation: "ACST"),
        AvailableTimeZone(identifier: "Australia/Hobart", cityName: "Hobart", abbreviation: "AEST"),
        AvailableTimeZone(identifier: "Pacific/Auckland", cityName: "Auckland", abbreviation: "NZST"),
        AvailableTimeZone(identifier: "Pacific/Auckland", cityName: "Wellington", abbreviation: "NZST"),

        // Pacific Islands
        AvailableTimeZone(identifier: "Pacific/Fiji", cityName: "Suva", abbreviation: "FJT"),
        AvailableTimeZone(identifier: "Pacific/Guam", cityName: "Guam", abbreviation: "ChST"),
        AvailableTimeZone(identifier: "Pacific/Tahiti", cityName: "Papeete", abbreviation: "TAHT"),
        AvailableTimeZone(identifier: "Pacific/Port_Moresby", cityName: "Port Moresby", abbreviation: "PGT"),
        AvailableTimeZone(identifier: "Pacific/Noumea", cityName: "Nouméa", abbreviation: "NCT"),
        AvailableTimeZone(identifier: "Pacific/Apia", cityName: "Apia", abbreviation: "WST"),
        AvailableTimeZone(identifier: "Pacific/Tongatapu", cityName: "Nukuʻalofa", abbreviation: "TOT"),

        // Atlantic
        AvailableTimeZone(identifier: "Atlantic/Azores", cityName: "Azores", abbreviation: "AZOT"),
        AvailableTimeZone(identifier: "Atlantic/Cape_Verde", cityName: "Praia", abbreviation: "CVT"),
        AvailableTimeZone(identifier: "Atlantic/Bermuda", cityName: "Hamilton", abbreviation: "AST"),

        // UTC/Special
        AvailableTimeZone(identifier: "UTC", cityName: "UTC", abbreviation: "UTC")
    ]
}
