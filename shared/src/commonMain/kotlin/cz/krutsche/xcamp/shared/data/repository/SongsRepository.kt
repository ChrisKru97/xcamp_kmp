package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.domain.model.Song

class SongsRepository(
    databaseManager: DatabaseManager,
    firestoreService: FirestoreService
) : BaseRepository<Song>(databaseManager, firestoreService) {

    override val collectionName = "songs"

    suspend fun getAllSongs(): List<Song> = withDatabase {
        queries.selectAllSongs().executeAsList().map(::mapToSong)
    }

    suspend fun getSongByNumber(number: Long): Song? = withDatabase {
        queries.selectSongByNumber(number).executeAsOneOrNull()?.let(::mapToSong)
    }

    suspend fun searchSongs(query: String): List<Song> = withDatabase {
        val searchQuery = "%$query%"
        queries.searchSongs(searchQuery, searchQuery).executeAsList().map(::mapToSong)
    }

    suspend fun insertSongs(songs: List<Song>) = withDatabase {
        queries.transaction {
            songs.forEach { song ->
                queries.insertSong(
                    number = song.number,
                    name = song.name,
                    text = song.text
                )
            }
        }
    }

    suspend fun syncFromFirestore(): Result<Unit> =
        syncFromFirestore(Song.serializer(), ::insertSongs)

    private fun mapToSong(dbSong: cz.krutsche.xcamp.shared.db.Song): Song =
        cz.krutsche.xcamp.shared.domain.model.Song(
            number = dbSong.number,
            name = dbSong.name,
            text = dbSong.text
        )
}