package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.domain.model.ExpandedSection
import cz.krutsche.xcamp.shared.domain.model.SectionType
import kotlin.native.ObjCName
import kotlin.experimental.ExperimentalObjCName

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

// TODO shouldn't be done rather by sqlite query?
object ScheduleFilter {
    fun filterSections(
        sections: List<ExpandedSection>,
        selectedDay: Int,
        filterState: ScheduleFilterState
    ): List<ExpandedSection> {
        return sections.filter { section ->
            if (section.day != selectedDay) return@filter false

            if (!filterState.visibleTypes.contains(section.type)) return@filter false

            if (filterState.favoritesOnly && !section.favorite) return@filter false

            true
        }
    }
}
