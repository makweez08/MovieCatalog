import SwiftUI
import SwiftData

struct MovieRow: View {
    @Bindable var movie: Movie

    var body: some View {
        HStack(spacing: 12) {
            Toggle("Просмотрено", isOn: $movie.isWatched)
                .labelsHidden()

            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .strikethrough(movie.isWatched)

                Text("\(movie.genre), \(movie.year)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if movie.rating > 0 {
                Label("\(movie.rating)", systemImage: "star.fill")
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}
