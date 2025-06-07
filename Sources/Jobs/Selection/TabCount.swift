import Models
import StructuredQueries

@Selection
struct TabCount: QueryRepresentable, Equatable, Sendable {
    var activeCount: Int
    var archivedCount: Int
}

extension Select where Columns == TabCount.Columns.QueryValue?, From == JobApplication, Joins == Void {
    static func tabCount(isArchivedTab: Bool) -> Self {
        JobApplication
            .select {
                let jobApplicationStatusCountsColumn: TabCount.Columns? = TabCount.Columns(
                    activeCount: $0.archivedStatusCount(isArchived: isArchivedTab),
                    archivedCount: $0.archivedStatusCount(isArchived: !isArchivedTab)
                )
                return jobApplicationStatusCountsColumn
            }
    }
}

private extension JobApplication.TableColumns {
    func archivedStatusCount(isArchived: Bool) -> some QueryExpression<Int> {
        Case()
            .when(
                self.isArchived.eq(isArchived),
                then: 1
            )
            .count()
    }
}
