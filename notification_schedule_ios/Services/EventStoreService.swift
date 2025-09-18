import EventKit

enum EventStoreError: LocalizedError {
    case accessDenied
    case failed

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "カレンダーへのアクセスが許可されていません。"
        case .failed:
            return "処理に失敗しました。"
        }
    }
}

final class EventStoreService {
    private let store = EKEventStore()

    func authorizationStatus() -> EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    func requestAccess() async -> Bool {
        do {
            return try await store.requestAccess(to: .event)
        } catch {
            return false
        }
    }

    func fetchUpcomingEvents(limit: Int = 30) async throws -> [AppEvent] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 90, to: start) else {
            return []
        }
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let events = store.events(matching: predicate).sorted { $0.startDate < $1.startDate }
        return events.prefix(limit).map { AppEvent(event: $0) }
    }

    func createEvent(title: String, startDate: Date, notes: String?, minutesBefore: Int) async throws {
        guard authorizationStatus() == .authorized else {
            throw EventStoreError.accessDenied
        }
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(30 * 60)
        event.notes = notes
        event.calendar = store.defaultCalendarForNewEvents
        event.alarms?.forEach { event.removeAlarm($0) }
        let alarm = EKAlarm(relativeOffset: alarmOffset(for: minutesBefore))
        event.addAlarm(alarm)
        do {
            try store.save(event, span: .thisEvent)
        } catch {
            throw EventStoreError.failed
        }
    }

    func updateEvent(identifier: String, title: String, startDate: Date, notes: String?, minutesBefore: Int) async throws {
        guard authorizationStatus() == .authorized else {
            throw EventStoreError.accessDenied
        }
        guard let event = store.event(withIdentifier: identifier) else {
            throw EventStoreError.failed
        }
        let duration = event.endDate.timeIntervalSince(event.startDate)
        event.title = title
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(duration)
        event.notes = notes
        event.alarms?.forEach { event.removeAlarm($0) }
        let alarm = EKAlarm(relativeOffset: alarmOffset(for: minutesBefore))
        event.addAlarm(alarm)
        do {
            try store.save(event, span: .thisEvent)
        } catch {
            throw EventStoreError.failed
        }
    }

    func deleteEvent(identifier: String) throws {
        guard let event = store.event(withIdentifier: identifier) else { return }
        try store.remove(event, span: .thisEvent)
    }

    func alarmOffset(for minutes: Int) -> TimeInterval {
        -Double(minutes) * 60
    }
}
