import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Movie.createdAt, order: .reverse)
    private var allMovies: [Movie]

    @State private var searchText = ""
    @State private var watchedFilter: WatchedFilter = .all
    @State private var sortOption: MovieSortOption = .dateAdded
    @State private var activeSheet: ContentSheet?

    private var watchedCount: Int {
        allMovies.filter { $0.isWatched }.count
    }

    private var averageRatingText: String {
        let ratedMovies = allMovies.filter { $0.rating > 0 }
        guard !ratedMovies.isEmpty else { return "—" }

        let total = ratedMovies.reduce(0) { $0 + $1.rating }
        let average = Double(total) / Double(ratedMovies.count)
        return average.formatted(.number.precision(.fractionLength(1)))
    }

    var body: some View {
        NavigationStack {
            List {
                Picker("Просмотр", selection: $watchedFilter) {
                    ForEach(WatchedFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)

                if allMovies.isEmpty {
                    ContentUnavailableView(
                        "Фильмов пока нет",
                        systemImage: "film",
                        description: Text("Добавьте первый фильм")
                    )
                } else {
                    MovieResultsView(
                        searchText: searchText,
                        watchedFilter: watchedFilter,
                        sortOption: sortOption
                    )
                }
            }
            .searchable(text: $searchText, prompt: "Название или жанр")
            .navigationTitle("Фильмы")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        ForEach(MovieSortOption.allCases) { option in
                            Button {
                                sortOption = option
                            } label: {
                                if sortOption == option {
                                    Label(option.title, systemImage: "checkmark")
                                } else {
                                    Text(option.title)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .accessibilityLabel("Сортировка")

                    Button {
                        activeSheet = .statistics
                    } label: {
                        Image(systemName: "chart.bar")
                    }
                    .accessibilityLabel("Статистика")

                    Button {
                        activeSheet = .addMovie
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Добавить фильм")
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .addMovie:
                    AddMovieView()
                case .statistics:
                    StatisticsView(
                        movieCount: allMovies.count,
                        watchedCount: watchedCount,
                        averageRatingText: averageRatingText
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
            }
        }
    }
}

private struct MovieResultsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var filteredMovies: [Movie]

    let sortOption: MovieSortOption

    init(searchText: String, watchedFilter: WatchedFilter, sortOption: MovieSortOption) {
        self.sortOption = sortOption

        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filterCode = watchedFilter.code

        let predicate = #Predicate<Movie> { movie in
            (search.isEmpty ||
                movie.title.contains(search) ||
                movie.genre.contains(search))
            &&
            (filterCode == 0 ||
                (filterCode == 1 && movie.isWatched == false) ||
                (filterCode == 2 && movie.isWatched == true))
        }

        _filteredMovies = Query(
            filter: predicate,
            sort: \Movie.createdAt,
            order: .reverse
        )
    }

    private var sortedMovies: [Movie] {
        switch sortOption {
        case .dateAdded:
            filteredMovies.sorted { $0.createdAt > $1.createdAt }
        case .title:
            filteredMovies.sorted {
                $0.title.localizedStandardCompare($1.title) == .orderedAscending
            }
        case .year:
            filteredMovies.sorted { $0.year < $1.year }
        case .rating:
            filteredMovies.sorted { $0.rating > $1.rating }
        }
    }

    var body: some View {
        Section {
            if sortedMovies.isEmpty {
                ContentUnavailableView(
                    "Ничего не найдено",
                    systemImage: "magnifyingglass",
                    description: Text("Измените поиск или фильтр")
                )
            } else {
                ForEach(sortedMovies) { movie in
                    NavigationLink {
                        MovieDetailView(movie: movie)
                    } label: {
                        MovieRow(movie: movie)
                    }
                }
                .onDelete(perform: deleteMovies)
            }
        }
    }

    private func deleteMovies(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedMovies[index])
        }
    }
}

private enum WatchedFilter: String, CaseIterable, Identifiable {
    case all
    case unwatched
    case watched

    var id: Self { self }

    var title: String {
        switch self {
        case .all: "Все"
        case .unwatched: "Не просмотрено"
        case .watched: "Просмотрено"
        }
    }

    var code: Int {
        switch self {
        case .all: 0
        case .unwatched: 1
        case .watched: 2
        }
    }
}

private enum MovieSortOption: String, CaseIterable, Identifiable {
    case dateAdded
    case title
    case year
    case rating

    var id: Self { self }

    var title: String {
        switch self {
        case .dateAdded: "Дата добавления"
        case .title: "Название"
        case .year: "Год"
        case .rating: "Оценка"
        }
    }
}

private enum ContentSheet: String, Identifiable {
    case addMovie
    case statistics

    var id: String { rawValue }
}

@MainActor
let moviePreviewContainer: ModelContainer = {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)

    do {
        let container = try ModelContainer(
            for: Movie.self,
            configurations: configuration
        )

        container.mainContext.insert(
            Movie(
                title: "Arrival",
                year: 2016,
                genre: "Science Fiction",
                isWatched: true,
                rating: 5
            )
        )

        container.mainContext.insert(
            Movie(
                title: "Spirited Away",
                year: 2001,
                genre: "Animation"
            )
        )

        return container
    } catch {
        fatalError("Preview container error: \(error)")
    }
}()

#Preview {
    ContentView()
        .modelContainer(moviePreviewContainer)
}
