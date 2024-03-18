import _SentryPrivate
import Foundation
@testable import Sentry
import SentryTestUtils
import XCTest

class TestMetricsClient: SentryMetricsClient {

    init() throws {
        let testClient = try XCTUnwrap(TestClient(options: Options()))
        let statsdClient = SentryStatsdClient(client: testClient)

        super.init(client: statsdClient)
    }

    var beforeCaptureBlock: (() -> Void)?
    var captureInvocations = Invocations<[BucketTimestamp: [Metric]]>()
    override func capture(flushableBuckets: [BucketTimestamp: [Metric]]) {
        beforeCaptureBlock?()
        captureInvocations.record(flushableBuckets)
    }
}
