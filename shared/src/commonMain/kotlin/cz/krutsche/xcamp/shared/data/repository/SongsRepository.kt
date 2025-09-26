package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.domain.model.Song
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class SongsRepository(
    private val databaseManager: DatabaseManager,
    private val firestoreService: FirestoreService
) {
    private val queries = databaseManager.queries

    suspend fun getAllSongs(): List<Song> {
        return withContext(Dispatchers.Default) {
            queries.selectAllSongs().executeAsList().map { dbSong ->
                Song(
                    number = dbSong.number,
                    name = dbSong.name,
                    text = dbSong.text
                )
            }
        }
    }

    suspend fun getSongByNumber(number: Long): Song? {
        return withContext(Dispatchers.Default) {
            queries.selectSongByNumber(number).executeAsOneOrNull()?.let { dbSong ->
                Song(
                    number = dbSong.number,
                    name = dbSong.name,
                    text = dbSong.text
                )
            }
        }
    }

    suspend fun searchSongs(query: String): List<Song> {
        return withContext(Dispatchers.Default) {
            val searchQuery = "%$query%"
            queries.searchSongs(searchQuery, searchQuery).executeAsList().map { dbSong ->
                Song(
                    number = dbSong.number,
                    name = dbSong.name,
                    text = dbSong.text
                )
            }
        }
    }

    suspend fun insertSongs(songs: List<Song>) {
        withContext(Dispatchers.Default) {
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
    }

    suspend fun syncFromFirestore(): Result<Unit> {
        return try {
            val result = firestoreService.getCollection("songs", Song.serializer())
            result.fold(
                onSuccess = { songs ->
                    insertSongs(songs)
                    Result.success(Unit)
                },
                onFailure = { error ->
                    Result.failure(error)
                }
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}