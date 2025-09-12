import EventKit

struct AppEvent: Identifiable {
    let id: String
    var title: String
    var startDate: Date
    var notes: String?
    var minutesBefore: Int

    init(event: EKEvent) {
        self.id = event.eventIdentifier
        self.title = event.title
        self.startDate = event.startDate
        self.notes = event.notes
        if let alarm = event.alarms?.first {
            self.minutesBefore = Int(abs(alarm.relativeOffset) / 60)
        } else {
            self.minutesBefore = 0
        }
    }
}
