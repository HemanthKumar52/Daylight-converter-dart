import SwiftUI

struct TimeSlider: View {
    @Binding var hourOffset: Double
    let homeTimeZone: TimeZoneItem?
    var colorScheme: ColorScheme = .dark

    private var theme: ThemeColors {
        ThemeColors(colorScheme: colorScheme)
    }

    @State private var lastHapticHour: Int = 0
    @State private var dragStartOffset: Double = 0
    @State private var isDragging: Bool = false

    private let daylightGradient = LinearGradient(
        colors: [Color(hex: "FFD900"), Color(hex: "FF9900")],
        startPoint: .leading,
        endPoint: .trailing
    )

    // Calculate current hour in home timezone (0-24)
    private var currentHomeHour: Double {
        guard let home = homeTimeZone else { return 12 }
        let now = Date()
        let calendar = Calendar.current
        var calendarWithZone = calendar
        calendarWithZone.timeZone = home.timeZone
        let hour = calendarWithZone.component(.hour, from: now)
        let minute = calendarWithZone.component(.minute, from: now)
        return Double(hour) + Double(minute) / 60.0
    }

    var body: some View {
        GeometryReader { geometry in
            let sliderWidth = geometry.size.width
            let trackPadding: CGFloat = 25.5
            let trackWidth = sliderWidth - (trackPadding * 2)
            let knobWidth: CGFloat = 38
            let knobHeight: CGFloat = 24

            // Center position (where "Now" / offset 0 is)
            let centerX = trackWidth / 2

            // Knob position: center + offset mapped to pixels
            let pixelsPerHour = trackWidth / 24.0
            let knobX = centerX + (CGFloat(hourOffset) * pixelsPerHour)

            // Get current hour for day/night segment calculation
            let currentHour = currentHomeHour

            VStack(spacing: 8) {
                // "Now" label at top with gradient text and reset button
                HStack(spacing: 8) {
                    Text(abs(hourOffset) < 0.01 ? "Now" : formatTimeLabel())
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(daylightGradient)

                    if abs(hourOffset) >= 0.01 {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                hourOffset = 0
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(theme.closeButton)
                        }
                    }
                }

                // Track and knob
                ZStack {
                    // Draw the track with day/night segments using Canvas
                    Canvas { context, size in
                        let trackHeight: CGFloat = 6
                        let trackY = (size.height - trackHeight) / 2

                        // Calculate all day segments that might be visible in the -12 to +12 range
                        // We need to handle wrapping across multiple days
                        let segments = calculateDaySegments(currentHour: currentHour, pixelsPerHour: pixelsPerHour, centerX: centerX, trackWidth: trackWidth)

                        // Draw night background first (full track)
                        let nightRect = CGRect(x: 0, y: trackY, width: trackWidth, height: trackHeight)
                        let nightPath = Path(roundedRect: nightRect, cornerRadius: trackHeight / 2)
                        context.fill(nightPath, with: .color(theme.nightBlock))

                        // Draw daylight segments on top
                        let dayGradient = Gradient(colors: [Color(hex: "FFD900"), Color(hex: "FF9900")])
                        for segment in segments {
                            let segmentX = max(0, segment.startX)
                            let segmentEndX = min(trackWidth, segment.endX)
                            let segmentWidth = max(0, segmentEndX - segmentX)

                            if segmentWidth > 0 {
                                let dayRect = CGRect(x: segmentX, y: trackY, width: segmentWidth, height: trackHeight)

                                // Apply rounded corners only at the ends of the track
                                let leftRadius: CGFloat = segmentX <= 0 ? trackHeight / 2 : 0
                                let rightRadius: CGFloat = segmentEndX >= trackWidth ? trackHeight / 2 : 0

                                let dayPath = Path(roundedRect: dayRect, cornerRadii: RectangleCornerRadii(topLeading: leftRadius, bottomLeading: leftRadius, bottomTrailing: rightRadius, topTrailing: rightRadius))
                                context.fill(dayPath, with: .linearGradient(
                                    dayGradient,
                                    startPoint: CGPoint(x: segment.startX, y: trackY),
                                    endPoint: CGPoint(x: segment.endX, y: trackY)
                                ))
                            }
                        }
                    }
                    .frame(width: trackWidth, height: 24)

                    // Knob (movable) with liquid glass effect when dragging
                    Capsule()
                        .fill(isDragging ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color.white))
                        .frame(width: knobWidth, height: knobHeight)
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(isDragging ? 0.8 : 0),
                                            Color.white.opacity(isDragging ? 0.2 : 0)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: isDragging ? Color(hex: "FF9900").opacity(0.4) : .black.opacity(0.12), radius: isDragging ? 8 : 6.5, x: 0, y: isDragging ? 0 : 3)
                        .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 0.25)
                        .offset(x: knobX - centerX)
                        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isDragging)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isDragging {
                                    isDragging = true
                                    dragStartOffset = hourOffset
                                }
                                let dragHours = Double(value.translation.width / pixelsPerHour)
                                let rawOffset = max(-12, min(12, dragStartOffset + dragHours))

                                // Snap to absolute 15-minute clock intervals (:00, :15, :30, :45)
                                let currentMinute = Double(Calendar.current.component(.minute, from: Date()))
                                let currentMinuteFraction = currentMinute / 60.0
                                // Calculate offset needed to snap to nearest 15-min mark
                                let targetTime = currentMinuteFraction + rawOffset
                                let snappedTarget = (targetTime * 4).rounded() / 4
                                let snappedOffset = snappedTarget - currentMinuteFraction

                                // Trigger haptic feedback at each 15-minute interval
                                let currentInterval = Int(snappedOffset * 4)
                                if currentInterval != lastHapticHour {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    lastHapticHour = currentInterval
                                }

                                hourOffset = snappedOffset
                            }
                            .onEnded { _ in
                                isDragging = false
                                dragStartOffset = hourOffset
                            }
                    )
                }
                .frame(width: trackWidth)

                // Tick marks below track
                tickMarks(trackWidth: trackWidth, knobX: knobX, centerX: centerX)

                // Current location time at bottom (always shows actual current time, not affected by slider)
                if let home = homeTimeZone {
                    HStack(spacing: 4) {
                        Image("navigation")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                            .foregroundColor(theme.sliderText)

                        Text(home.formattedTime(offsetBy: 0))
                            .font(.system(size: 18, weight: .ultraLight))
                            .foregroundColor(theme.sliderText)
                    }
                }
            }
            .padding(.horizontal, trackPadding)
            .padding(.vertical, 16)
            .frame(width: sliderWidth)
            .background {
                ZStack {
                    // Base tint for frosted effect
                    RoundedRectangle(cornerRadius: 66)
                        .fill(colorScheme == .dark
                            ? Color.white.opacity(0.08)
                            : Color.black.opacity(0.04))

                    // Glass material layer
                    RoundedRectangle(cornerRadius: 66)
                        .fill(.ultraThinMaterial)

                    // Inner highlight at top edge
                    RoundedRectangle(cornerRadius: 66)
                        .strokeBorder(
                            LinearGradient(
                                colors: colorScheme == .dark
                                    ? [
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.15),
                                        Color.clear
                                    ]
                                    : [
                                        Color.white.opacity(0.8),
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )

                    // Subtle inner glow at corners
                    RoundedRectangle(cornerRadius: 66)
                        .stroke(
                            AngularGradient(
                                colors: colorScheme == .dark
                                    ? [
                                        Color.white.opacity(0.25),
                                        Color.clear,
                                        Color.white.opacity(0.1),
                                        Color.clear,
                                        Color.white.opacity(0.25)
                                    ]
                                    : [
                                        Color.white.opacity(0.6),
                                        Color.clear,
                                        Color.white.opacity(0.3),
                                        Color.clear,
                                        Color.white.opacity(0.6)
                                    ],
                                center: .center
                            ),
                            lineWidth: 0.5
                        )
                        .blur(radius: 0.5)
                }
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
            }
            .onTapGesture(count: 2) {
                withAnimation(.spring(response: 0.3)) {
                    hourOffset = 0
                }
            }
        }
        .frame(height: 161)
        .padding(.horizontal, 12)
    }

    private func formatTimeLabel() -> String {
        if let home = homeTimeZone {
            return home.formattedTime(offsetBy: hourOffset)
        }
        let hours = Int(round(hourOffset))
        return "\(abs(hours))h \(hours > 0 ? "later" : "earlier")"
    }

    private func tickMarks(trackWidth: CGFloat, knobX: CGFloat, centerX: CGFloat) -> some View {
        // 9 main ticks (at hours -12, -9, -6, -3, 0, 3, 6, 9, 12)
        // Plus smaller ticks in between = 17 total
        let totalTicks = 17

        return ZStack {
            HStack(spacing: 0) {
                ForEach(0..<totalTicks, id: \.self) { index in
                    let isMajor = index % 2 == 0
                    let tickX = CGFloat(index) * (trackWidth / CGFloat(totalTicks - 1))
                    let isAtKnob = abs(tickX - knobX) < (trackWidth / CGFloat(totalTicks - 1) / 2)

                    Circle()
                        .fill(isAtKnob ? Color(hex: "FF9900") : theme.tickMark)
                        .frame(width: isMajor ? 4 : 4, height: isMajor ? 4 : 4)
                        .opacity(isAtKnob ? 1.0 : (isMajor ? 1.0 : 0.5))
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(width: trackWidth)
        }
    }

    // Helper struct for day segments
    private struct DaySegment {
        let startX: CGFloat
        let endX: CGFloat
    }

    // Calculate daylight segments visible in the -12 to +12 hour range
    private func calculateDaySegments(currentHour: Double, pixelsPerHour: CGFloat, centerX: CGFloat, trackWidth: CGFloat) -> [DaySegment] {
        var segments: [DaySegment] = []

        // Daylight hours are 6 AM (hour 6) to 6 PM (hour 18)
        // The slider shows hours from -12 to +12 relative to now
        // We need to find all daylight periods that fall within this range

        // Check multiple days to handle edge cases
        for dayOffset in -1...1 {
            let dayOffsetHours = Double(dayOffset) * 24.0

            // 6 AM for this day
            let dayStart = 6.0 + dayOffsetHours
            // 6 PM for this day
            let dayEnd = 18.0 + dayOffsetHours

            // Calculate hours from now to these times
            let hoursToStart = dayStart - currentHour
            let hoursToEnd = dayEnd - currentHour

            // Only include if any part falls within -12 to +12 range
            if hoursToEnd >= -12 && hoursToStart <= 12 {
                let clampedStart = max(-12, hoursToStart)
                let clampedEnd = min(12, hoursToEnd)

                // Convert to X positions
                let startX = centerX + CGFloat(clampedStart) * pixelsPerHour
                let endX = centerX + CGFloat(clampedEnd) * pixelsPerHour

                if endX > startX {
                    segments.append(DaySegment(startX: startX, endX: endX))
                }
            }
        }

        return segments
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            Spacer()
            TimeSlider(
                hourOffset: .constant(0),
                homeTimeZone: TimeZoneItem(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST", isHome: true)
            )
        }
    }
}
