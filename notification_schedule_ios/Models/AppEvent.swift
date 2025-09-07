import EventKit

struct AppEvent: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let notes: String?

    init(event: EKEvent) {
        self.id = event.eventIdentifier
        self.title = event.title
        self.startDate = event.startDate
        self.notes = event.notes
    }
}
