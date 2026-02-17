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
        const val RETRY = "Zkusit znovu"
        const val LOADING = "Načítám..."
        const val ERROR_TITLE = "Chyba"
        const val STALE_DATA = "Data mohou být neaktuální"
        const val ERROR_NETWORK = "Chyba sítě. Zkontrolujte připojení."
        const val ERROR_STORAGE = "Chyba úložiště. Zkuste to znovu."
        const val ERROR_VALIDATION = "Ověření dat selhalo."
        const val ERROR_NOT_FOUND = "Položka nebyla nalezena."
        const val ERROR_NOTIFICATION_PERMISSION = "Chyba oprávnění oznámení."
        const val ERROR_NOTIFICATION_SCHEDULE = "Chyba plánování oznámení."
        const val ERROR_NOTIFICATION_DISABLED = "Oznámení jsou zakázána."
        const val ERROR_UNKNOWN = "Neznámá chyba"
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
        const val PLACE_NOT_FOUND = "Místo nenalezeno"
    }

    object Schedule {
        const val LOADING = "Načítám program..."
        const val ERROR_TITLE = "Nepodařilo se načíst program"
        const val NOT_FOUND = "Žádný program nenalezen"
        const val RETRY = "Zkusit znovu"
        const val FAVORITES = "Pouze oblíbené"
        const val FILTER = "Zobrazený program"
        const val FILTER_MENU = "Filtrovat"

        object SectionType {
            const val SECTIONTYPE_MAIN = "Hlavní"
            const val SECTIONTYPE_INTERNAL = "Pro registrované"
            const val SECTIONTYPE_GOSPEL = "Evangelizace"
            const val SECTIONTYPE_FOOD = "Jídlo"
            const val SECTIONTYPE_OTHER = "Ostatní"
        }

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
            const val PLACE_UNKNOWN = "Neznámé místo"
            const val DETAIL_SPEAKERS = "Řečníci"
            const val DETAIL_LEADER = "Vedoucí"
            const val DETAIL_TYPE = "Typ"
            const val DETAIL_DESCRIPTION = "Popis"
        }
    }

    object Rating {
        const val COMING_SOON = "Připravujeme"
    }

    object Notifications {
        const val TITLE = "Oznámení"

        const val NEWS_ENABLED = "Důležitá oznámení"
        const val NEWS_ENABLED_DESCRIPTION = "Zobrazovat oznámení o důležitých informacích"

        const val PRAYER_DAY_ENABLED = "Den modlitby"
        const val PRAYER_DAY_ENABLED_DESCRIPTION = "Měsíční připomínka dne modlitby za Xcamp"

        const val SCHEDULE_NOTIFICATIONS = "Upozornění programu"
        const val SCHEDULE_NOTIFICATIONS_DESCRIPTION = "Zobrazovat upozornění 15 minut před začátkem"

        const val MODE_OFF = "Vypnuto"
        const val MODE_FAVORITES = "Pouze oblíbené"
        const val MODE_ALL = "Všechny"

        const val PERMISSION_DENIED_TITLE = "Oznámení zakázána"
        const val PERMISSION_DENIED_MESSAGE = "Pro správnou funkčnost připomínek programu povolte oznámení v nastavení systému."
        const val OPEN_SETTINGS = "Otevřít nastavení"
        const val CANCEL = "Zrušit"

        const val NOTIFICATION_IN_MINUTES = "za 15 minut"
        const val NOTIFICATION_STARTING_SOON = "Začíná"

        const val PRAYER_NOTIFICATION_TITLE = "Den modlitby za Xcamp"
    }

    object DataCollection {
        const val SECTION_HEADER = "Soukromí"
        const val TOGGLE_TITLE = "Sběr dat"
        const val SECTION_FOOTER = "Pomozte zlepšit aplikaci sdílením údajů o používání a hlášení chyb"
    }

    object ForceUpdate {
        const val TITLE = "Aktualizace vyžadována"
        const val MESSAGE = "Tato verze aplikace již není podporována. Pro správnou funkčnost prosím aktualizujte na nejnovější verzi."
        const val UPDATE_NOW = "Aktualizovat"
        const val MAYBE_LATER = "Později"
        const val WARNING_TITLE = "Upozornění"
        const val WARNING_MESSAGE = "Používáte nepodporovanou verzi aplikace. Některé funkce nemusí fungovat správně."
        const val WARNING_OK = "Rozumím"
    }
}
