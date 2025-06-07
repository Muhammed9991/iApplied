import StructuredQueries

@Selection
struct TabCount: QueryRepresentable, Equatable, Sendable {
    var activeCount: Int
    var archivedCount: Int
}
