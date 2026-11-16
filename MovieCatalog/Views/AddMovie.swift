import SwiftUI
import SwiftData

struct AddMovieView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var year = Calendar.current.component(.year, from: .now)
    @State private var genre = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Название", text: $title)
                TextField("Жанр", text: $genre)

                Stepper(
                    "Год: \(year)",
                    value: $year,
                    in: 1888...2100
                )
            }
            .navigationTitle("Новый фильм")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveMovie()
                    }
                    .disabled(cleanTitle.isEmpty || cleanGenre.isEmpty)
                }
            }
        }
    }

    private var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanGenre: String {
        genre.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func saveMovie() {
        let movie = Movie(
            title: cleanTitle,
            year: year,
            genre: cleanGenre
        )
        modelContext.insert(movie)
        dismiss()
    }
}
