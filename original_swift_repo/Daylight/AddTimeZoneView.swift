import SwiftUI

struct AddTimeZoneView: View {
    @ObservedObject var store: TimeZoneStore
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var filteredTimeZones: [AvailableTimeZone] {
        if searchText.isEmpty {
            return AvailableTimeZone.all
        }
        return AvailableTimeZone.all.filter {
            $0.cityName.localizedCaseInsensitiveContains(searchText) ||
            $0.abbreviation.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredTimeZones) { tz in
                Button {
                    addTimeZone(tz)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(tz.cityName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(tz.abbreviation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if isAlreadyAdded(tz) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "FF9900"))
                        }
                    }
                }
                .disabled(isAlreadyAdded(tz))
            }
            .searchable(text: $searchText, prompt: "Search cities")
            .navigationTitle("Add Timezone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func isAlreadyAdded(_ tz: AvailableTimeZone) -> Bool {
        store.timeZones.contains { $0.cityName == tz.cityName }
    }

    private func addTimeZone(_ tz: AvailableTimeZone) {
        let newItem = TimeZoneItem(
            identifier: tz.identifier,
            cityName: tz.cityName,
            abbreviation: tz.abbreviation,
            isHome: false
        )
        store.addTimeZone(newItem)
        dismiss()
    }
}

#Preview {
    AddTimeZoneView(store: TimeZoneStore())
}
