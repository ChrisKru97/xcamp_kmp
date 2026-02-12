import Foundation

enum ContentState<T> {
    case loading
    case loaded(T, isStale: Bool = false)
    case refreshing(T)
    case error(Error)
}
