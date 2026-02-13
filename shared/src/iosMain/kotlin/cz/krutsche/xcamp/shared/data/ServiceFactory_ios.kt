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
import cz.krutsche.xcamp.shared.data.network.createConnectivityObserver
import cz.krutsche.xcamp.shared.data.notification.NotificationService
import cz.krutsche.xcamp.shared.data.repository.PlacesRepository
import cz.krutsche.xcamp.shared.data.repository.ScheduleRepository
import cz.krutsche.xcamp.shared.data.repository.SpeakersRepository
import cz.krutsche.xcamp.shared.data.repository.SongsRepository
import cz.krutsche.xcamp.shared.data.repository.UsersRepository

actual object ServiceFactory {
    private val _firestoreService: FirestoreService by lazy { FirestoreService() }
    private val _storageService: StorageService by lazy { StorageService() }
    private val _remoteConfigService: RemoteConfigService by lazy { RemoteConfigService() }
    private val _connectivityObserver: ConnectivityObserver by lazy { createConnectivityObserver() }
    private val _appPreferences: AppPreferences by lazy { AppPreferences }
    private val _databaseManager: DatabaseManager by lazy { DatabaseFactory.getDatabaseManager() }

    private val _scheduleRepository: ScheduleRepository by lazy {
        ScheduleRepository(_databaseManager, _firestoreService)
    }
    private val _notificationService: NotificationService by lazy { NotificationService() }
    private val _authService: AuthService by lazy { AuthService(getUsersRepository()) }
    private val _placesRepository: PlacesRepository by lazy {
        PlacesRepository(_databaseManager, _firestoreService, _storageService)
    }
    private val _speakersRepository: SpeakersRepository by lazy {
        SpeakersRepository(_databaseManager, _firestoreService, _storageService)
    }
    private val _songsRepository: SongsRepository by lazy {
        SongsRepository(_databaseManager, _firestoreService)
    }
    private val _usersRepository: UsersRepository by lazy {
        UsersRepository(_firestoreService)
    }
    private val _appConfigService: AppConfigService by lazy { AppConfigService(_remoteConfigService) }
    private val _linksService: LinksService by lazy { LinksService(_remoteConfigService) }
    private val _scheduleService: ScheduleService by lazy { ScheduleService() }
    private val _speakersService: SpeakersService by lazy { SpeakersService() }
    private val _placesService: PlacesService by lazy { PlacesService() }

    actual fun getAuthService() = _authService
    actual fun getFirestoreService() = _firestoreService
    actual fun getStorageService() = _storageService
    actual fun getRemoteConfigService() = _remoteConfigService
    actual fun getNotificationService() = _notificationService
    actual fun getConnectivityObserver() = _connectivityObserver
    actual fun getAppPreferences() = _appPreferences
    actual fun getDatabaseManager() = _databaseManager
    actual fun getScheduleRepository() = _scheduleRepository
    actual fun getPlacesRepository() = _placesRepository
    actual fun getSpeakersRepository() = _speakersRepository
    actual fun getSongsRepository() = _songsRepository
    actual fun getUsersRepository() = _usersRepository
    actual fun getAppConfigService() = _appConfigService
    actual fun getLinksService() = _linksService
    actual fun getScheduleService() = _scheduleService
    actual fun getSpeakersService() = _speakersService
    actual fun getPlacesService() = _placesService
}
