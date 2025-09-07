import XCTest
@testable import notification_schedule_ios

final class EventStoreServiceTests: XCTestCase {
    func testAlarmOffset() {
        let service = EventStoreService()
        XCTAssertEqual(service.alarmOffset(for: 10), -600)
    }
}
