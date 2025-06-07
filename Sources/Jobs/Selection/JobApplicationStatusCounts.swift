import Models
import StructuredQueries

@Selection
public struct JobApplicationStatusCounts: QueryRepresentable, Equatable, Sendable {
    var appliedCount: Int
    var interviewCount: Int
    var offerCount: Int
    var declinedCount: Int

    func countForFilter(_ filterType: FilterType) -> Int {
        switch filterType {
        case .all: appliedCount + interviewCount + offerCount + declinedCount
        case .applied: appliedCount
        case .interview: interviewCount
        case .offer: offerCount
        case .declined: declinedCount
        }
    }
}

extension Select where Columns == JobApplicationStatusCounts.Columns.QueryValue?, From == JobApplication, Joins == Void {
    static func jobApplicationStatusCounts(isArchivedTab: Bool) -> Self {
        JobApplication
            .select {
                let jobApplicationStatusCountsColumn: JobApplicationStatusCounts.Columns? = JobApplicationStatusCounts.Columns(
                    appliedCount: $0.statusCount(status: .applied, isArchived: isArchivedTab),
                    interviewCount: $0.statusCount(status: .interview, isArchived: isArchivedTab),
                    offerCount: $0.statusCount(status: .offer, isArchived: isArchivedTab),
                    declinedCount: $0.statusCount(status: .declined, isArchived: isArchivedTab)
                )
                return jobApplicationStatusCountsColumn
            }
    }
}
