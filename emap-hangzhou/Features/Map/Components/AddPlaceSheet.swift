//
//  AddPlaceSheet.swift
//  emap-hangzhou
//

import SwiftUI
import CoreLocation

struct AddPlaceSheet: View {
    @Environment(\.dismiss) private var dismiss

    let coordinate: CLLocationCoordinate2D
    let onSave: (String, String, PlaceCategory) -> Void

    @State private var title = ""
    @State private var note = ""
    @State private var selectedCategory: PlaceCategory = .scenery

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                }

                Section {
                    TextField("Description (optional)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Category") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 10)], spacing: 10) {
                        ForEach(PlaceCategory.allCases, id: \.self) { category in
                            CategoryOptionButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    LabeledContent("Latitude") {
                        Text(coordinate.latitude, format: .number.precision(.fractionLength(6)))
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("Longitude") {
                        Text(coordinate.longitude, format: .number.precision(.fractionLength(6)))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("New Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(
                            title.trimmingCharacters(in: .whitespacesAndNewlines),
                            note.trimmingCharacters(in: .whitespacesAndNewlines),
                            selectedCategory
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct CategoryOptionButton: View {
    let category: PlaceCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: category.iconName)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : category.color)
                    .frame(width: 32, height: 32)
                    .background(
                        isSelected ? category.color : category.color.opacity(0.14),
                        in: RoundedRectangle(cornerRadius: 9, style: .continuous)
                    )

                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(category.color)
                }
            }
            .padding(10)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? category.color : .clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }
}
