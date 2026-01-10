import SwiftUI

struct ContentView: View {
    @StateObject private var store = TimeZoneStore()
    @Environment(AppSettings.self) private var settings
    @Environment(\.colorScheme) private var colorScheme
    @State private var hourOffset: Double = 0
    @State private var showingAddTimeZone = false
    @State private var showingEditList = false
    @State private var showingSettings = false
    @State private var selectedTimeZone: TimeZoneItem?

    private var theme: ThemeColors {
        ThemeColors(colorScheme: colorScheme)
    }

    var homeTimeZone: TimeZoneItem? {
        store.timeZones.first(where: { $0.isHome })
    }

    // Sort timezones: behind (negative offset) at top, ahead (positive offset) at bottom
    var sortedTimeZones: [TimeZoneItem] {
        guard let home = homeTimeZone else { return store.timeZones }

        let homeOffset = home.timeZone.secondsFromGMT()

        return store.timeZones.sorted { tz1, tz2 in
            let offset1 = tz1.timeZone.secondsFromGMT() - homeOffset
            let offset2 = tz2.timeZone.secondsFromGMT() - homeOffset
            return offset1 < offset2 // Negative (behind) first, positive (ahead) last
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header at top
                header

                // Scrollable timezone cards
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(sortedTimeZones) { timeZone in
                            TimeZoneCard(timeZone: timeZone, hourOffset: hourOffset, homeTimeZone: homeTimeZone, showCenterLine: settings.showCenterLine, colorScheme: colorScheme)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 180) // Extra padding so content can scroll under slider
                }
            }

            // Slider overlays at bottom with liquid glass effect
            VStack {
                Spacer()
                TimeSlider(hourOffset: $hourOffset, homeTimeZone: homeTimeZone, colorScheme: colorScheme)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $showingAddTimeZone) {
            AddTimeZoneView(store: store)
        }
        .sheet(isPresented: $showingEditList) {
            EditListView(store: store)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: settings)
        }
    }

    private var header: some View {
        HStack {
            Text("Daylight")
                .font(.system(size: 30, weight: .black))
                .foregroundColor(theme.headerText)

            Spacer()

            Menu {
                Button {
                    showingAddTimeZone = true
                } label: {
                    Label("Add Timezone", systemImage: "plus")
                }
                .keyboardShortcut("a", modifiers: .command)

                Button {
                    showingEditList = true
                } label: {
                    Label("Edit List", systemImage: "pencil")
                }

                Divider()

                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            } label: {
                Image("brand")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(theme.headerText)
                    .frame(width: 48, height: 48)
                    .background {
                        Circle()
                            .fill(colorScheme == .dark
                                ? AnyShapeStyle(.ultraThinMaterial.opacity(0.6))
                                : AnyShapeStyle(Color.black.opacity(0.08)))
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: colorScheme == .dark
                                                ? [
                                                    Color.white.opacity(0.5),
                                                    Color.white.opacity(0.1),
                                                    Color.clear
                                                ]
                                                : [
                                                    Color.black.opacity(0.15),
                                                    Color.black.opacity(0.05),
                                                    Color.clear
                                                ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: .black.opacity(colorScheme == .dark ? 0.15 : 0.1), radius: 8, x: 0, y: 4)
                    }
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 12)
    }
}

struct EditListView: View {
    @ObservedObject var store: TimeZoneStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.timeZones) { timeZone in
                    HStack {
                        if timeZone.isHome {
                            Image(systemName: "house.fill")
                                .foregroundColor(Color(hex: "FF9900"))
                        }

                        VStack(alignment: .leading) {
                            Text(timeZone.cityName)
                                .font(.headline)
                            Text(timeZone.abbreviation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                }
                .onDelete(perform: store.removeTimeZone)
                .onMove(perform: store.moveTimeZone)
            }
            .navigationTitle("Edit List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    ContentView()
}
