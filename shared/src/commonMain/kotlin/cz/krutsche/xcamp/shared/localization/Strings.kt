package cz.krutsche.xcamp.shared.localization

object Strings {

    object App {
        const val TITLE = "XcamP"
    }

    object Tabs {
        const val HOME = "Domů"
        const val SCHEDULE = "Program"
        const val SPEAKERS_AND_PLACES = "Informace"
        const val MEDIA = "Média"
        const val ABOUT_FESTIVAL = "O festivalu"
        const val RATING = "Hodnocení"
        // Keep for use in top tabs
        const val SPEAKERS = "Řečníci"
        const val PLACES = "Místa"
    }

    object Common {
        const val MORE_OPTIONS = "Další možnosti"
        const val CANCEL = "Zrušit"
    }

    object Countdown {
        const val TITLE = "Už za"
        const val DAYS = "dní"
        const val DAYS_FEW = "dny"
        const val DAY = "den"
    }

    object Info {
        const val IMPORTANT_INFO = "Důležité informace"
        const val MEDICAL_HELP_TITLE = "Zdravotnická pomoc"
        const val MEDICAL_HELP_TEXT = "Dostupná na informacích 24/7. V případě jakýchkoliv potíží se prosím obraťte na službu na Informacích."
        const val LEAVING_CAMP_TITLE = "Opuštění tábora"
        const val LEAVING_CAMP_TEXT = "V případě opuštění tábora tuto skutečnost prosím předem ohlaste na Informacích a svým skupinkovým vedoucím."
        const val CONTACT_US = "Kontakty"
        const val CONTACT_EMAIL = "info@xcamp.cz"
        const val CONTACT_WEB = "Webové stránky"
        const val CONTACT_ADDRESS = "Adresa"
        const val CONTACT_REGISTRATION = "Registrace"
        const val CONTACT_PHONE_LABEL = "Telefon:"
    }

    object Media {
        const val YOUTUBE = "YouTube"
        const val SPOTIFY = "Spotify"
        const val APPLE_PODCASTS = "Apple Podcasts"
        const val FACEBOOK = "Facebook"
        const val INSTAGRAM = "Instagram"
        const val GALLERY = "Galerie"
        const val WEBSITE = "Website"
    }

    object Places {
        const val LOADING = "Načítám místa..."
        const val EMPTY_TITLE = "Žádná místa"
        const val ERROR_TITLE = "Nepodařilo se načíst místa"
        const val RETRY = "Zkusit znovu"
        const val SHOW_ON_MAP = "Zobrazit na mapě"
        const val OPEN_IN_MAPS = "Otevřít v mapách"
        const val RETRY_HINT = "Tap to retry loading places"
        const val DETAIL_HINT = "Tap to view place details"
        const val DETAIL_DESCRIPTION_HINT = "Place description and information"
    }

    object Speakers {
        const val LOADING = "Načítám řečníky..."
        const val EMPTY_TITLE = "Žádní řečníci"
        const val ERROR_TITLE = "Nepodařilo se načíst řečníky"
        const val RETRY = "Zkusit znovu"
        const val RETRY_HINT = "Tap to retry loading speakers"
        const val DETAIL_HINT = "Tap to view speaker details"
        const val DETAIL_BIO_HINT = "Speaker biography and information"
        const val BIOGRAPHY = "Biografie"
    }

    object Schedule {
        const val LOADING = "Načítám program..."
        const val EMPTY_TITLE = "Žádný program"
        const val ERROR_TITLE = "Nepodařilo se načíst program"
        const val RETRY = "Zkusit znovu"
        const val FILTER_TITLE = "Filtr typů"
        const val FILTER_ALL = "Všechny typy"
        const val FAVORITES = "Oblíbené"
        const val SHOW_ALL = "Zobrazit vše"

        object SectionType {
            const val SECTIONTYPE_MAIN = "Hlavní"
            const val SECTIONTYPE_INTERNAL = "Pro registrované"
            const val SECTIONTYPE_GOSPEL = "Evangelizace"
            const val SECTIONTYPE_FOOD = "Jídlo"
            const val SECTIONTYPE_OTHER = "Ostatní"
        }

        const val HIDE_ALL = "Skrýt vše"
        const val DONE = "Hotovo"

        object Days {
            const val DAYS_SATURDAY = "Sobota"
            const val DAYS_SUNDAY = "Neděle"
            const val DAYS_MONDAY = "Pondělí"
            const val DAYS_TUESDAY = "Úterý"
            const val DAYS_WEDNESDAY = "Středa"
            const val DAYS_THURSDAY = "Čtvrtek"
            const val DAYS_FRIDAY = "Pátek"
        }

        object Detail {
            const val DETAIL_TIME = "Čas"
            const val DETAIL_PLACE = "Místo"
            const val DETAIL_SPEAKERS = "Řečníci"
            const val DETAIL_LEADER = "Vedoucí"
            const val DETAIL_TYPE = "Typ"
            const val DETAIL_DESCRIPTION = "Popis"
            const val DETAIL_ADD_TO_FAVORITES = "Přidat do oblíbených"
            const val DETAIL_REMOVE_FROM_FAVORITES = "Odebrat z oblíbených"
        }
    }
}
