package cz.krutsche.xcamp.shared.data

import cz.krutsche.xcamp.shared.data.config.AppConfigService
import cz.krutsche.xcamp.shared.data.config.AppPreferences
import cz.krutsche.xcamp.shared.data.config.LinksService
import cz.krutsche.xcamp.shared.data.config.PlacesService
import cz.krutsche.xcamp.shared.data.config.ScheduleService
import cz.krutsche.xcamp.shared.data.config.SpeakersService
import cz.krutsche.xcamp.shared.data.firebase.AuthService
import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.firebase.RemoteConfigService
import cz.krutsche.xcamp.shared.data.firebase.StorageService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.data.network.ConnectivityObserver
import cz.krutsche.xcamp.shared.data.notification.NotificationService
import cz.krutsche.xcamp.shared.data.repository.PlacesRepository
import cz.krutsche.xcamp.shared.data.repository.ScheduleRepository
import cz.krutsche.xcamp.shared.data.repository.SpeakersRepository
import cz.krutsche.xcamp.shared.data.repository.SongsRepository
import cz.krutsche.xcamp.shared.data.repository.UsersRepository

expect object ServiceFactory {
    fun getAuthService(): AuthService
    fun getFirestoreService(): FirestoreService
    fun getStorageService(): StorageService
    fun getRemoteConfigService(): RemoteConfigService
    fun getNotificationService(): NotificationService
    fun getConnectivityObserver(): ConnectivityObserver
    fun getAppPreferences(): AppPreferences
    fun getDatabaseManager(): DatabaseManager
    fun getScheduleRepository(): ScheduleRepository
    fun getPlacesRepository(): PlacesRepository
    fun getSpeakersRepository(): SpeakersRepository
    fun getSongsRepository(): SongsRepository
    fun getUsersRepository(): UsersRepository
    fun getAppConfigService(): AppConfigService
    fun getLinksService(): LinksService
    fun getScheduleService(): ScheduleService
    fun getSpeakersService(): SpeakersService
    fun getPlacesService(): PlacesService
}
