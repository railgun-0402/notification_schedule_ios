import Foundation
import SwiftUI

@MainActor
final class AddEventViewModel: ObservableObject {
    @Published var title = ""
    @Published var date = Date()
    @Published var notes = ""
    @Published var minutesBefore = 10
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isSuccess = false

    private let service: EventStoreService

    init(service: EventStoreService = EventStoreService()) {
        self.service = service
    }

    var canSave: Bool {
        !title.isEmpty && date > Date()
    }

    func save() async {
        guard canSave else {
            alertMessage = "入力を確認してください。"
            isSuccess = false
            showAlert = true
            return
        }
        do {
            try await service.createEvent(
                title: title,
                startDate: date,
                notes: notes.isEmpty ? nil : notes,
                minutesBefore: minutesBefore
            )
            alertMessage = "保存しました。"
            isSuccess = true
        } catch {
            alertMessage = error.localizedDescription
            isSuccess = false
        }
        showAlert = true
    }
}
