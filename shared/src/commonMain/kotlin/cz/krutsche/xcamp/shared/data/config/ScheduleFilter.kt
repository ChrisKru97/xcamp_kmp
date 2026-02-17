package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.domain.model.ExpandedSection
import cz.krutsche.xcamp.shared.domain.model.SectionType

data class ScheduleFilterState(
    val visibleTypes: Set<SectionType> = SectionType.entries.toSet(),
    val favoritesOnly: Boolean = false
) {
    fun toggleType(type: SectionType): ScheduleFilterState {
        val newTypes = if (visibleTypes.contains(type)) {
            visibleTypes - type
        } else {
            visibleTypes + type
        }
        return copy(visibleTypes = newTypes)
    }

    fun toggleFavoritesOnly(): ScheduleFilterState {
        return copy(favoritesOnly = !favoritesOnly)
    }
}

// Day filtering only - type and favorite filtering now done at SQL level
object ScheduleFilter {
    fun filterSectionsByDay(
        sections: List<ExpandedSection>,
        selectedDay: Int
    ): List<ExpandedSection> {
        return sections.filter { it.day == selectedDay }
    }
}
