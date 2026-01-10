import SwiftUI
import Observation

enum AppTheme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@Observable
class AppSettings {
    var showCenterLine: Bool {
        get {
            UserDefaults.standard.object(forKey: "showCenterLine") as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "showCenterLine")
        }
    }

    var theme: AppTheme {
        get {
            let rawValue = UserDefaults.standard.string(forKey: "appTheme") ?? "Dark"
            return AppTheme(rawValue: rawValue) ?? .dark
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "appTheme")
        }
    }
}

struct ThemeColors {
    let colorScheme: ColorScheme

    var background: Color {
        colorScheme == .dark ? Color.black : Color.white
    }

    var headerText: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    var nightBlock: Color {
        colorScheme == .dark ? Color(hex: "1C1C1D") : Color(hex: "E5E5EA")
    }

    var nightText: Color {
        colorScheme == .dark ? Color(hex: "757575") : Color(hex: "3C3C43")
    }

    var centerLine: Color {
        colorScheme == .dark ? Color.white.opacity(0.25) : Color.black.opacity(0.15)
    }

    var sliderTrackBackground: Color {
        colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.1)
    }

    var sliderKnob: Color {
        colorScheme == .dark ? Color.white : Color.white
    }

    var sliderText: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    var tickMark: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    var closeButton: Color {
        colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.4)
    }
}

struct SettingsView: View {
    @Bindable var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Appearance", selection: $settings.theme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                } header: {
                    Text("Theme")
                }

                Section {
                    Toggle("Show Center Line", isOn: $settings.showCenterLine)
                } header: {
                    Text("Display")
                } footer: {
                    Text("Shows a vertical line at the center of timezone cards to indicate current time position")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    SettingsView(settings: AppSettings())
}
