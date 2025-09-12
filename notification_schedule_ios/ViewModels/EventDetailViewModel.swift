import Foundation
import SwiftUI

@MainActor
final class EventDetailViewModel: ObservableObject {
    @Published var title: String
    @Published var date: Date
    @Published var notes: String
    @Published var minutesBefore: Int
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isSuccess = false

    private let service: EventStoreService
    private let eventId: String

    init(event: AppEvent, service: EventStoreService = EventStoreService()) {
        self.eventId = event.id
        self.title = event.title
        self.date = event.startDate
        self.notes = event.notes ?? ""
        self.minutesBefore = event.minutesBefore
        self.service = service
    }

    var canSave: Bool {
        !title.isEmpty && date > Date()
    }

    func update() async {
        guard canSave else {
            alertMessage = "入力を確認してください。"
            isSuccess = false
            showAlert = true
            return
        }
        do {
            try await service.updateEvent(
                identifier: eventId,
                title: title,
                startDate: date,
                notes: notes.isEmpty ? nil : notes,
                minutesBefore: minutesBefore
            )
            alertMessage = "更新しました。"
            isSuccess = true
        } catch {
            alertMessage = error.localizedDescription
            isSuccess = false
        }
        showAlert = true
    }
}
