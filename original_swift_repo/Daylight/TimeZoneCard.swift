import SwiftUI

struct TimeZoneCard: View {
    let timeZone: TimeZoneItem
    let hourOffset: Double
    let homeTimeZone: TimeZoneItem?
    var showCenterLine: Bool = true
    var colorScheme: ColorScheme = .dark

    private var theme: ThemeColors {
        ThemeColors(colorScheme: colorScheme)
    }

    private let daylightGradient = LinearGradient(
        colors: [Color(hex: "FFD900"), Color(hex: "FF9900")],
        startPoint: .leading,
        endPoint: .trailing
    )

    private var nightColor: Color {
        theme.nightBlock
    }

    private let blockWidth: CGFloat = 190
    private let blockSpacing: CGFloat = 2
    private let cardHeight: CGFloat = 108

    // Format the day and date for the timezone (e.g., "Mon 3rd")
    private var formattedDayDate: String {
        let now = Date()
        let adjustedDate = now.addingTimeInterval(hourOffset * 3600)

        let formatter = DateFormatter()
        formatter.timeZone = timeZone.timeZone

        // Get day abbreviation (Mon, Tue, etc.)
        formatter.dateFormat = "EEE"
        let dayName = formatter.string(from: adjustedDate)

        // Get day number
        formatter.dateFormat = "d"
        let dayNumber = Int(formatter.string(from: adjustedDate)) ?? 1

        // Add ordinal suffix
        let suffix: String
        switch dayNumber {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }

        return "\(dayName) \(dayNumber)\(suffix)"
    }

    // Check if this is the home timezone
    private var isHomeTimezone: Bool {
        guard let home = homeTimeZone else { return false }
        return home.id == timeZone.id
    }

    // Calculate the time difference from home timezone (without day/date)
    private var offsetFromHomeText: String? {
        guard let home = homeTimeZone, home.id != timeZone.id else {
            return nil
        }

        let homeZone = home.timeZone
        let thisZone = timeZone.timeZone
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

    private var currentTimeHours: Double {
        let currentHour = timeZone.currentHour(offsetBy: hourOffset)
        let currentMinute = timeZone.currentMinute(offsetBy: hourOffset)
        return Double(currentHour) + Double(currentMinute) / 60.0
    }

    private func calculateOffsetX(cardWidth: CGFloat) -> CGFloat {
        // Normalize time: 6AM = 0, 6PM = 12, next 6AM = 24
        let normalizedTime = (currentTimeHours - 6 + 24).truncatingRemainder(dividingBy: 24)

        // Position within the middle day (index 6-7 in our 14-block timeline)
        let middleDayStart = (blockWidth + blockSpacing) * 6
        let posInCurrentBlock = (normalizedTime / 12.0) * blockWidth
        let currentPosInTimeline = middleDayStart + posInCurrentBlock

        return (cardWidth / 2) - currentPosInTimeline
    }

    private func isBlockAtCenter(dayIndex: Int, isDayBlock: Bool, offsetX: CGFloat, cardWidth: CGFloat) -> Bool {
        let pairWidth = blockWidth * 2 + blockSpacing * 2
        var blockStartX = offsetX + CGFloat(dayIndex) * pairWidth

        if !isDayBlock {
            blockStartX += blockWidth + blockSpacing
        }

        let blockEndX = blockStartX + blockWidth
        let centerX = cardWidth / 2

        return blockStartX <= centerX && centerX <= blockEndX
    }

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width
            let offsetX = calculateOffsetX(cardWidth: cardWidth)

            Canvas { context, size in
                // Draw all blocks
                let nightBlockColor = nightColor
                for day in 0..<7 {
                    let dayBlockX = offsetX + CGFloat(day) * (blockWidth * 2 + blockSpacing * 2)
                    let nightBlockX = dayBlockX + blockWidth + blockSpacing

                    // Day block
                    let dayRect = CGRect(x: dayBlockX, y: 0, width: blockWidth, height: cardHeight)
                    let dayPath = Path(roundedRect: dayRect, cornerRadius: 5)

                    // Create gradient for day block
                    let dayGradient = Gradient(colors: [Color(hex: "FFD900"), Color(hex: "FF9900")])
                    context.fill(dayPath, with: .linearGradient(
                        dayGradient,
                        startPoint: CGPoint(x: dayRect.minX, y: dayRect.midY),
                        endPoint: CGPoint(x: dayRect.maxX, y: dayRect.midY)
                    ))

                    // Night block
                    let nightRect = CGRect(x: nightBlockX, y: 0, width: blockWidth, height: cardHeight)
                    let nightPath = Path(roundedRect: nightRect, cornerRadius: 5)
                    context.fill(nightPath, with: .color(nightBlockColor))
                }
            }
            .clipped()

            // Overlay text labels only on the block at center
            HStack(spacing: blockSpacing) {
                ForEach(0..<7, id: \.self) { day in
                    // Day block - show text only if at center
                    Group {
                        if isBlockAtCenter(dayIndex: day, isDayBlock: true, offsetX: offsetX, cardWidth: cardWidth) {
                            timeLabel(isDaylight: true)
                        } else {
                            Color.clear
                        }
                    }
                    .frame(width: blockWidth, height: cardHeight)

                    // Night block - show text only if at center
                    Group {
                        if isBlockAtCenter(dayIndex: day, isDayBlock: false, offsetX: offsetX, cardWidth: cardWidth) {
                            timeLabel(isDaylight: false)
                        } else {
                            Color.clear
                        }
                    }
                    .frame(width: blockWidth, height: cardHeight)
                }
            }
            .offset(x: offsetX)
            .clipped()

            // Center line indicator
            if showCenterLine {
                Rectangle()
                    .fill(theme.centerLine)
                    .frame(width: 2, height: cardHeight)
                    .position(x: cardWidth / 2, y: cardHeight / 2)
            }
        }
        .frame(height: cardHeight)
    }

    private func timeLabel(isDaylight: Bool) -> some View {
        let textColor = isDaylight ? Color(hex: "BE3C00") : theme.nightText

        return VStack(spacing: 3) {
            Image(isDaylight ? "sun" : "moon")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundColor(textColor)

            Text(timeZone.formattedTime(offsetBy: hourOffset))
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(textColor)

            Text("\(timeZone.cityName) (\(timeZone.abbreviation))")
                .font(.system(size: 18, weight: .ultraLight, design: .rounded))
                .foregroundColor(textColor)

            // Show navigation icon for home, or offset text for others, with day/date
            HStack(spacing: 3) {
                if isHomeTimezone {
                    Image("navigation")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12)
                        .foregroundColor(textColor)
                } else if let offset = offsetFromHomeText {
                    Text("\(offset),")
                        .font(.system(size: 14, weight: .ultraLight, design: .rounded))
                        .foregroundColor(textColor)
                }

                Text(formattedDayDate)
                    .font(.system(size: 14, weight: .ultraLight, design: .rounded))
                    .foregroundColor(textColor)
            }
        }
    }
}

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

#Preview {
    let home = TimeZoneItem(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST", isHome: true)

    VStack(spacing: 12) {
        TimeZoneCard(
            timeZone: TimeZoneItem(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false),
            hourOffset: 0,
            homeTimeZone: home
        )
        TimeZoneCard(
            timeZone: TimeZoneItem(identifier: "America/New_York", cityName: "New York", abbreviation: "EST", isHome: false),
            hourOffset: 0,
            homeTimeZone: home
        )
        TimeZoneCard(
            timeZone: TimeZoneItem(identifier: "Europe/London", cityName: "London", abbreviation: "GMT", isHome: false),
            hourOffset: 0,
            homeTimeZone: home
        )
        TimeZoneCard(
            timeZone: TimeZoneItem(identifier: "Asia/Dubai", cityName: "Dubai", abbreviation: "GST", isHome: false),
            hourOffset: 0,
            homeTimeZone: home
        )
        TimeZoneCard(
            timeZone: home,
            hourOffset: 0,
            homeTimeZone: home
        )
    }
    .padding(.horizontal, 16)
    .background(Color.black)
}
