import SwiftUI
import shared

// MARK: - Service Environment Values

extension EnvironmentValues {
    @Entry var scheduleService = ScheduleService()
    @Entry var speakersService = SpeakersService()
    @Entry var placesService = PlacesService()
}
