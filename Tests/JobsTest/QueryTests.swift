import InlineSnapshotTesting
@testable import Jobs
import StructuredQueries
import StructuredQueriesTestSupport
import Testing

//@Suite(.snapshots(record: .failed))
struct QueryTests {
    @Test
    func getAllJobApplicationsExcludingArchived() {
        assertInlineSnapshot(
            of: JobApplication
                .all
                .where { !$0.isArchived }
                .order { $0.dateApplied.desc() },
            as: .sql
        ) {
            """
            SELECT "jobApplications"."id", "jobApplications"."title", "jobApplications"."company", "jobApplications"."createdAt", "jobApplications"."dateApplied", "jobApplications"."status", "jobApplications"."notes", "jobApplications"."lastFollowUpDate", "jobApplications"."isArchived"
            FROM "jobApplications"
            WHERE NOT ("jobApplications"."isArchived")
            ORDER BY "jobApplications"."dateApplied" DESC
            """
        }
    }

    @Test
    func getAllArchivedApplications() {
        assertInlineSnapshot(
            of: JobApplication
                .all
                .where(\.isArchived)
                .order { $0.dateApplied.desc() },
            as: .sql
        ) {
            """
            SELECT "jobApplications"."id", "jobApplications"."title", "jobApplications"."company", "jobApplications"."createdAt", "jobApplications"."dateApplied", "jobApplications"."status", "jobApplications"."notes", "jobApplications"."lastFollowUpDate", "jobApplications"."isArchived"
            FROM "jobApplications"
            WHERE "jobApplications"."isArchived"
            ORDER BY "jobApplications"."dateApplied" DESC
            """
        }
    }
}
