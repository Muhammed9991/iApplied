import Dependencies
import Foundation
import Models
import OSLog
import UserNotifications

enum NotificationType: String {
    case followUp
}

struct NotificationConfig {
    let title: String
    let body: String
    let daysAfterDate: Int
    let baseDate: Date
    let identifier: String
    
    public init(
        title: String,
        body: String,
        daysAfterDate: Int = 7,
        baseDate: Date,
        identifier: String
    ) {
        self.title = title
        self.body = body
        self.daysAfterDate = daysAfterDate
        self.baseDate = baseDate
        self.identifier = identifier
    }
}

struct NotificationManager {
    var requestAuthorisation: @Sendable () async throws -> Bool
    var cancelNotification: @Sendable (_ identifier: String) -> Void
    var cancelAllNotifications: @Sendable () -> Void
    var scheduleFollowUpNotification: @Sendable (_ jobApplication: JobApplication) async throws -> Void
}

extension NotificationManager: DependencyKey {
    static var liveValue: Self {
        @Sendable func notificationIdentifier(for jobId: Int64, type: NotificationType) -> String {
            "com.mahmoodies.iApplied.notification.\(type.rawValue).\(jobId)"
        }
        
        @Sendable func cancelNotifications(for jobId: Int64, type: NotificationType) {
            let identifier = notificationIdentifier(for: jobId, type: type)
            cancelNotification(withIdentifier: identifier)
        }
        
        @Sendable func cancelNotification(withIdentifier identifier: String) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        }
        
        @Sendable func scheduleNotification(config: NotificationConfig, completion: ((Error?) -> Void)? = nil) async throws {
            let content = UNMutableNotificationContent()
            content.title = config.title
            content.body = config.body
            content.sound = .default
            
            #if DEBUG
            let notificationDate = Calendar.current.date(byAdding: .minute, value: 1, to: config.baseDate) ?? config.baseDate
            #else
            let notificationDate = Calendar.current.date(byAdding: .day, value: config.daysAfterDate, to: config.baseDate) ?? config.baseDate
            #endif
            
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: config.identifier, content: content, trigger: trigger)
            
            try await UNUserNotificationCenter.current().add(request)
            Logger.jobs.debug("Succesfully scheduled notification for \(config.title) at \(notificationDate)")
        }
        
        return Self {
            try await UNUserNotificationCenter.current().requestAuthorization()
            
        } cancelNotification: { identifier in
            cancelNotification(withIdentifier: identifier)
            Logger.jobs.debug("Cancelled notification with identifier: \(identifier)")
            
        } cancelAllNotifications: {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            Logger.jobs.debug("Cancelled all notifications")
            
        } scheduleFollowUpNotification: { jobApplication in
            precondition(jobApplication.id != nil, "Bruh how would this even be possible?")

            // Cancel any existing follow-up notifications for this job
            cancelNotifications(for: jobApplication.id!, type: .followUp)

            let notificationId = notificationIdentifier(for: jobApplication.id!, type: .followUp)
            let daysAfterDate = 7 // TODO: Move this to settings in the future

            // Check if the notification would be scheduled in the past
            let followUpDate = Calendar.current.date(byAdding: .day, value: daysAfterDate, to: jobApplication.dateApplied)!
            if followUpDate < Date() {
                Logger.jobs.debug("Skipping follow-up notification for job \(jobApplication.id!) — follow-up date is in the past.")
                return
            }

            let config = NotificationConfig(
                title: "Time to follow up!",
                body: "It's been \(daysAfterDate) days since you applied at \(jobApplication.company).",
                daysAfterDate: daysAfterDate,
                baseDate: jobApplication.dateApplied,
                identifier: notificationId
            )

            try await scheduleNotification(config: config)
        }
    }
}
