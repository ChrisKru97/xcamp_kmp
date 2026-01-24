import SwiftUI
import OSLog
import os.signpost

// MARK: - Performance Monitor Utility

/// A utility for monitoring app performance in development and production.
/// Provides view modifiers and logging utilities for tracking rendering times,
/// memory usage, and other performance metrics.
///
/// In debug builds, this provides detailed logging. In release builds,
/// it uses signposts for Instruments integration without console output.
@available(iOS 15.0, *)
public struct PerformanceMonitor {

    /// Logger subsystem for all performance-related logs
    public static let subsystem = "com.krutsche.xcamp"

    /// Category for view rendering performance
    public static let viewRendering = OSLog(subsystem: subsystem, category: "ViewRendering")

    /// Category for memory tracking
    public static let memory = OSLog(subsystem: subsystem, category: "Memory")

    /// Category for network operations
    public static let network = OSLog(subsystem: subsystem, category: "Network")

    /// Signpost log for Instruments
    public static let signposts = OSLog(subsystem: subsystem, category: "Performance")

    #if DEBUG
    /// Track memory usage in debug builds
    private static let enableMemoryLogging = true
    #else
    private static let enableMemoryLogging = false
    #endif

    // MARK: - Memory Tracking

    /// Reports current memory usage
    /// - Parameter label: Optional label to identify the measurement point
    public static func reportMemoryUsage(label: String = "Memory") {
        guard enableMemoryLogging else { return }

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
            logger.debug("\(label): Used \(String(format: "%.2f", usedMB)) MB / Total \(String(format: "%.2f", totalMB)) MB")

            // Signpost for Instruments
            os_signpost(.event, log: memory, name: "MemoryUsage", "Memory used in MB: %f", usedMB)
        }
    }

    /// Logs memory usage with optional signpost interval
    /// - Parameters:
    ///   - signpostID: Unique identifier for the signpost
    ///   - label: Label for the measurement
    public static func beginMemoryTracking(signpostID: OSSignpostID, label: String = "Tracking") {
        guard enableMemoryLogging else { return }
        os_signpost(.begin, log: memory, name: "MemoryTracking", signpostID: signpostID, "Memory tracking start: %{public}s", label)
        reportMemoryUsage(label: "\(label) Start")
    }

    public static func endMemoryTracking(signpostID: OSSignpostID, label: String = "Tracking") {
        guard enableMemoryLogging else { return }
        reportMemoryUsage(label: "\(label) End")
        os_signpost(.end, log: memory, name: "MemoryTracking", signpostID: signpostID)
    }

    // MARK: - View Rendering Timing

    /// Creates a unique signpost ID for view tracking
    public static func makeSignpostID() -> OSSignpostID {
        OSSignpostID(log: signposts)
    }
}

// MARK: - Private Logger

private extension PerformanceMonitor {
    static let logger = Logger(subsystem: subsystem, category: "PerformanceMonitor")
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
    private let logger = Logger(subsystem: PerformanceMonitor.subsystem, category: "MeasureRenderTime")

    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        let signpostID = PerformanceMonitor.makeSignpostID()
        _ = os_signpost(.begin, log: PerformanceMonitor.signposts, name: "ViewRender", signpostID: signpostID, "%{public}s", label)

        return content
            .onAppear {
                os_signpost(.end, log: PerformanceMonitor.signposts, name: "ViewRender", signpostID: signpostID, "%{public}s", label)
                hasAppeared = true
                #if DEBUG
                logger.debug("\(label): View appeared - use Instruments Time Profiler for accurate render metrics")
                #endif
            }
    }
}

#if DEBUG
@available(iOS 15.0, *)
private struct TrackMemoryView<Content: View>: View {
    let label: String
    let content: Content

    private let signpostID = PerformanceMonitor.makeSignpostID()

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
        let signpostID = makeSignpostID()
        os_signpost(.begin, log: signposts, name: "Operation", signpostID: signpostID, "Start: %{public}s", label)

        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        let duration = CFAbsoluteTimeGetCurrent() - startTime

        os_signpost(.end, log: signposts, name: "Operation", signpostID: signpostID, "End: %{public}s", label)

        #if DEBUG
        logger.debug("\(label): Completed in \(String(format: "%.2f", duration * 1000)) ms")
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
        let signpostID = makeSignpostID()
        os_signpost(.begin, log: signposts, name: "AsyncOperation", signpostID: signpostID, "Start: %{public}s", label)

        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await operation()
        let duration = CFAbsoluteTimeGetCurrent() - startTime

        os_signpost(.end, log: signposts, name: "AsyncOperation", signpostID: signpostID, "End: %{public}s", label)

        #if DEBUG
        logger.debug("\(label): Completed in \(String(format: "%.2f", duration * 1000)) ms")
        #endif

        return result
    }
}
