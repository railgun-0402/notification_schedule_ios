import Foundation
import EventKit
import SwiftUI

@MainActor
final class EventListViewModel: ObservableObject {
    @Published var events: [AppEvent] = []
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var showError = false
    @Published var errorMessage = ""

    private let service = EventStoreService()

    func onAppear() async {
        authorizationStatus = service.authorizationStatus()
        if authorizationStatus == .notDetermined {
            let granted = await service.requestAccess()
            authorizationStatus = service.authorizationStatus()
            if !granted { return }
        }
        await loadEvents()
    }

    func loadEvents() async {
        do {
            events = try await service.fetchUpcomingEvents()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
