import SwiftUI
import SwiftData

struct MovieDetailView: View {
    @Bindable var movie: Movie

    var body: some View {
        Form {
            Section("Фильм") {
                TextField("Название", text: $movie.title)
                TextField("Жанр", text: $movie.genre)

                Stepper(
                    "Год: \(movie.year)",
                    value: $movie.year,
                    in: 1888...2100
                )
            }

            Section("Статус") {
                Toggle("Просмотрено", isOn: $movie.isWatched)

                Stepper(
                    "Оценка: \(movie.rating)",
                    value: $movie.rating,
                    in: 0...5
                )
            }
        }
        .navigationTitle("Редактирование")
        .navigationBarTitleDisplayMode(.inline)
    }
}
