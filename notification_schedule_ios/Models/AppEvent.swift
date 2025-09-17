import EventKit

struct AppEvent: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let notes: String?
    let minutesBefore: Int

    init(event: EKEvent) {
        self.id = event.eventIdentifier
        self.title = event.title
        self.startDate = event.startDate
        self.notes = event.notes
        if let offset = event.alarms?.first?.relativeOffset {
            let minutes = Int(round((-offset) / 60))
            minutesBefore = max(0, minutes)
        } else {
            minutesBefore = 0
        }
    }
}
