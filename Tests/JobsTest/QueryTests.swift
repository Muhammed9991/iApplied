import InlineSnapshotTesting
@testable import Jobs
import StructuredQueries
import StructuredQueriesTestSupport
import Testing

@Suite(.snapshots(record: .failed))
struct QueryTests {
    @Test
    func getAllJobApplicationsExcludingArchived() {
        assertInlineSnapshot(
            of: JobApplication
                .all
                .where { $0.status != ApplicationStatus.archived.rawValue }
                .order { $0.dateApplied.desc() },
            as: .sql
        ) {
            """
            SELECT "jobApplications"."id", "jobApplications"."title", "jobApplications"."company", "jobApplications"."createdAt", "jobApplications"."dateApplied", "jobApplications"."status", "jobApplications"."notes", "jobApplications"."lastFollowUpDate"
            FROM "jobApplications"
            WHERE ("jobApplications"."status" <> 'Archived')
            ORDER BY "jobApplications"."dateApplied" DESC
            """
        }
    }
}
