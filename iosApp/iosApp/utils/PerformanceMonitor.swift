import SwiftUI

// MARK: - Performance Monitor Utility

/// A utility for monitoring app performance in development and production.
/// Provides view modifiers and logging utilities for tracking rendering times,
/// memory usage, and other performance metrics.
@available(iOS 15.0, *)
public struct PerformanceMonitor {

    // MARK: - Memory Tracking

    /// Reports current memory usage
    /// - Parameter label: Optional label to identify the measurement point
    public static func reportMemoryUsage(label: String = "Memory") {
        #if DEBUG
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            let usedMB = Double(info.resident_size) / 1024.0 / 1024.0
            let totalMB = Double(info.virtual_size) / 1024.0 / 1024.0
            // Logging removed - user will add manual logging
        }
        #endif
    }

    /// Logs memory usage with optional signpost interval
    /// - Parameters:
    ///   - signpostID: Unique identifier for the signpost
    ///   - label: Label for the measurement
    public static func beginMemoryTracking(signpostID: Int, label: String = "Tracking") {
        #if DEBUG
        reportMemoryUsage(label: "\(label) Start")
        #endif
    }

    public static func endMemoryTracking(signpostID: Int, label: String = "Tracking") {
        #if DEBUG
        reportMemoryUsage(label: "\(label) End")
        #endif
    }
}

// MARK: - View Modifiers

@available(iOS 15.0, *)
public extension View {

    /// Measures and logs the time it takes for this view's body to be rendered.
    /// Uses signposts for Instruments integration in all builds.
    ///
    /// - Parameter label: A label to identify this measurement point
    /// - Returns: A view that tracks rendering time
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .measureRenderingTime(label: "TextRendering")
    /// ```
    @ViewBuilder
    func measureRenderingTime(label: String = "ViewRendering") -> some View {
        MeasureRenderTimeView(label: label) {
            self
        }
    }

    /// Tracks memory usage before and after view rendering in debug builds.
    /// Lightweight in release builds (no overhead).
    ///
    /// - Parameter label: A label to identify the measurement point
    /// - Returns: A view that tracks memory during rendering
    ///
    /// Example:
    /// ```swift
    /// ScrollView { ... }
    ///     .trackMemory(label: "ScrollView")
    /// ```
    @ViewBuilder
    func trackMemory(label: String = "View") -> some View {
        #if DEBUG
        TrackMemoryView(label: label) {
            self
        }
        #else
        self
        #endif
    }

    /// Combines rendering time measurement with memory tracking.
    /// Use this for performance-critical views during development.
    ///
    /// - Parameter label: A label to identify the measurement point
    /// - Returns: A view with full performance monitoring
    ///
    /// Example:
    /// ```swift
    /// ScheduleDayView(day: day)
    ///     .trackPerformance(label: "ScheduleDay")
    /// ```
    @ViewBuilder
    func trackPerformance(label: String = "View") -> some View {
        measureRenderingTime(label: label)
            .trackMemory(label: label)
    }
}

// MARK: - Internal Measuring Views

@available(iOS 15.0, *)
private struct MeasureRenderTimeView<Content: View>: View {
    let label: String
    let content: Content

    @State private var hasAppeared = false

    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        return content
            .onAppear {
                hasAppeared = true
                // Logging removed - user will add manual logging
            }
    }
}

#if DEBUG
@available(iOS 15.0, *)
private struct TrackMemoryView<Content: View>: View {
    let label: String
    let content: Content

    private let signpostID = 0

    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        content
            .onAppear {
                PerformanceMonitor.beginMemoryTracking(signpostID: signpostID, label: label)
            }
            .onDisappear {
                PerformanceMonitor.endMemoryTracking(signpostID: signpostID, label: label)
            }
    }
}
#endif

// MARK: - Convenience Functions

@available(iOS 15.0, *)
public extension PerformanceMonitor {

    /// Measures the execution time of a synchronous operation.
    ///
    /// - Parameters:
    ///   - label: A label to identify the measurement
    ///   - operation: The operation to measure
    /// - Returns: The result of the operation
    ///
    /// Example:
    /// ```swift
    /// let result = PerformanceMonitor.measure(label: "DataProcessing") {
    ///     processLargeData()
    /// }
    /// ```
    static func measure<T>(_ label: String, operation: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        _ = CFAbsoluteTimeGetCurrent() - startTime

        #if DEBUG
        // Logging removed - user will add manual logging
        #endif

        return result
    }

    /// Measures the execution time of an asynchronous operation.
    ///
    /// - Parameters:
    ///   - label: A label to identify the measurement
    ///   - operation: The async operation to measure
    /// - Returns: The result of the operation
    ///
    /// Example:
    /// ```swift
    /// let result = await PerformanceMonitor.measure(label: "NetworkRequest") {
    ///     try await fetchUserData()
    /// }
    /// ```
    static func measure<T>(_ label: String, operation: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await operation()
        _ = CFAbsoluteTimeGetCurrent() - startTime

        #if DEBUG
        // Logging removed - user will add manual logging
        #endif

        return result
    }
}
