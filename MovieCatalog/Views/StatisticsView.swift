import SwiftUI

struct StatisticsView: View {
    let movieCount: Int
    let watchedCount: Int
    let averageRatingText: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Каталог") {
                    LabeledContent("Всего фильмов", value: "\(movieCount)")
                    LabeledContent("Просмотрено", value: "\(watchedCount)")
                    LabeledContent("Средняя оценка", value: averageRatingText)
                }
            }
            .navigationTitle("Статистика")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}
