import _SentryPrivate
import Foundation

class Something {
    
    private let currentDate: CurrentDateProvider
    
    init(currentDate: CurrentDateProvider) {
        self.currentDate = currentDate
    }
    
    func calc() -> Int {
        return 0
    }
}
