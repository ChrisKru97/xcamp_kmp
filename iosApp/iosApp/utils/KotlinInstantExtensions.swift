import Foundation
import shared

extension KotlinInstant {
    var epochMillis: Int64 {
        return self.toEpochMilliseconds()
    }
}
