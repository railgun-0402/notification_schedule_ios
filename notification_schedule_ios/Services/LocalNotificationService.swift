import UserNotifications
import EventKit

final class LocalNotificationService {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func scheduleNotification(for event: EKEvent, minutesBefore: Int) async {
        let content = UNMutableNotificationContent()
        content.title = event.title ?? "予定"
        if let notes = event.notes {
            content.body = notes
        }
        let fireDate = event.startDate.addingTimeInterval(-Double(minutesBefore) * 60)
        guard fireDate > Date() else { return }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: fireDate.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: event.eventIdentifier, content: content, trigger: trigger)
        try? await center.add(request)
    }

    func removeNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
