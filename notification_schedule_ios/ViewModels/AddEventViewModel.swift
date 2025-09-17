import Foundation
import SwiftUI

@MainActor
final class AddEventViewModel: ObservableObject {
    enum Mode {
        case create
        case edit
    }

    @Published var title = ""
    @Published var date = Date()
    @Published var notes = ""
    @Published var minutesBefore = 10
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isSuccess = false

    private let service: EventStoreService
    private let mode: Mode
    private let eventIdentifier: String?

    init(event: AppEvent? = nil, service: EventStoreService = EventStoreService()) {
        self.service = service
        if let event {
            mode = .edit
            eventIdentifier = event.id
            title = event.title
            date = event.startDate
            notes = event.notes ?? ""
            minutesBefore = event.minutesBefore
        } else {
            mode = .create
            eventIdentifier = nil
        }
    }

    var canSave: Bool {
        !title.isEmpty && date > Date()
    }

    var navigationTitle: String {
        switch mode {
        case .create:
            return "予定を追加"
        case .edit:
            return "予定を編集"
        }
    }

    var confirmButtonTitle: String {
        switch mode {
        case .create:
            return "保存"
        case .edit:
            return "更新"
        }
    }

    private var successMessage: String {
        switch mode {
        case .create:
            return "保存しました。"
        case .edit:
            return "更新しました。"
        }
    }

    func save() async {
        guard canSave else {
            alertMessage = "入力を確認してください。"
            isSuccess = false
            showAlert = true
            return
        }
        do {
            switch mode {
            case .create:
                try await service.createEvent(
                    title: title,
                    startDate: date,
                    notes: notes.isEmpty ? nil : notes,
                    minutesBefore: minutesBefore
                )
            case .edit:
                guard let eventIdentifier else {
                    alertMessage = EventStoreError.failed.errorDescription ?? "処理に失敗しました。"
                    isSuccess = false
                    showAlert = true
                    return
                }
                try await service.updateEvent(
                    identifier: eventIdentifier,
                    title: title,
                    startDate: date,
                    notes: notes.isEmpty ? nil : notes,
                    minutesBefore: minutesBefore
                )
            }
            alertMessage = successMessage
            isSuccess = true
        } catch {
            alertMessage = error.localizedDescription
            isSuccess = false
        }
        showAlert = true
    }
}
