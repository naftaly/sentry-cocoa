import Nimble
@testable import Sentry
import SentryTestUtils
import XCTest

final class SomethingTests: XCTestCase {

    func testExample() throws {
        let currentDate = TestCurrentDateProvider()
        let something = Something(currentDate: currentDate)
        
        expect(something.calc()) == 0
    }

}
