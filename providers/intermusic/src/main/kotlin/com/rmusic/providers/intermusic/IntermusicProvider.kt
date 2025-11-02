package com.rmusic.providers.intermusic

import com.rmusic.providers.intermusic.auth.IntermusicAuthService
import com.rmusic.providers.intermusic.models.IntermusicLocale
import com.rmusic.providers.intermusic.models.account.*
import com.rmusic.providers.intermusic.models.response.PlayerResponse
import com.rmusic.providers.intermusic.pages.*
import com.rmusic.providers.intermusic.parser.*
import io.ktor.client.call.body
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.StateFlow
import java.util.Locale
import java.net.HttpURLConnection
import java.net.URI
class IntermusicProvider {
    private val api = IntermusicAPI()
    private val authService = IntermusicAuthService(api)

    var locale: IntermusicLocale
        get() = api.locale
        set(value) { api.locale = value }
    // visitorData setter/getter provisto por propiedad; evitar duplicados de setVisitorData
    var visitorData: String?
        get() = api.visitorData
        set(value) { api.visitorData = value }
    var cookie: String?
        get() = api.cookie
        set(value) { api.cookie = value }
    // Proxy eliminado: no expuesto ni usado

    // ========== FUNCIONES BÁSICAS (SIN AUTENTICACIÓN REQUERIDA) ==========
    
    suspend fun search(query: String, filter: SearchFilter? = null): Result<SearchResult> = runCatching {
        parseSearchResults(api.search(query = query, params = filter?.params).body())
    }
    
    suspend fun getAlbum(browseId: String): Result<AlbumResult> = runCatching { 
        parseAlbumPage(api.album(browseId).body()) 
    }
    
    suspend fun getArtist(browseId: String): Result<ArtistResult> = runCatching { 
        parseArtistPage(api.artist(browseId).body()) 
    }
    
    suspend fun getPlaylist(playlistId: String): Result<PlaylistResult> = runCatching { 
        parsePlaylistPage(api.playlist(playlistId).body()) 
    }

    private val qualityRank = mapOf(
        "AUDIO_QUALITY_HIGH" to 3,
        "AUDIO_QUALITY_MEDIUM" to 2,
        "AUDIO_QUALITY_LOW" to 1
    )

    private val defaultClientOrder = listOf(
        ClientProfile.OCULUS,
        ClientProfile.IOS,
        ClientProfile.ANDROID
    )

    // Devuelve un SongResult listo para convertir a MediaItem
    suspend fun getPlayer(videoId: String): Result<SongResult> = runCatching {
        val response = firstPlayablePlayer(videoId, defaultClientOrder)
            ?: error("Player response not available")
        parseStreamingData(response)
    }

    // Permite seleccionar explícitamente el cliente a usar
    enum class ClientProfile { OCULUS, IOS, ANDROID }

    private suspend fun playerFor(videoId: String, client: ClientProfile): PlayerResponse = when (client) {
        ClientProfile.OCULUS -> api.playerOculus(videoId)
        ClientProfile.IOS -> api.playeriOS(videoId)
        ClientProfile.ANDROID -> api.playerAndroid(videoId)
    }

    private suspend fun firstPlayablePlayer(
        videoId: String,
        clients: List<ClientProfile>
    ): PlayerResponse? {
        clients.forEach { client ->
            val player = runCatching { playerFor(videoId, client) }.getOrNull() ?: return@forEach
            if (player.playabilityStatus?.status == "OK") return player
        }
        return null
    }

    private fun PlayerResponse.audioFormats(): List<PlayerResponse.Format> {
        val data = streamingData ?: return emptyList()
        val adaptive = data.adaptiveFormats.orEmpty().filter { it.isAudio }
        val progressive = data.formats.orEmpty().filter { it.isAudio || it.hasEmbeddedAudio }
        return (adaptive + progressive).filter { !it.url.isNullOrEmpty() }
    }

    private fun ensureRateBypass(url: String): String =
        if (url.contains("ratebypass=")) url
        else url + (if (url.contains('?')) "&" else "?") + "ratebypass=yes"

    private fun chooseBestFormat(formats: List<PlayerResponse.Format>): PlayerResponse.Format? =
        formats.maxByOrNull {
            (qualityRank[it.audioQuality] ?: 0) * 1_000_000 + (it.bitrate ?: it.averageBitrate ?: 0)
        }

    private fun PlayerResponse.pickBestUrl(): String? {
        val formats = audioFormats()
        if (formats.isEmpty()) {
            val data = streamingData ?: return null
            return listOfNotNull(data.hlsManifestUrl, data.serverAbrStreamingUrl, data.dashManifestUrl).firstOrNull()
        }
        val chosen = chooseBestFormat(formats) ?: return null
        val rawUrl = chosen.url ?: return null
        return ensureRateBypass(rawUrl)
    }

    private fun buildAudioStream(format: PlayerResponse.Format, player: PlayerResponse): AudioStreamInfo = AudioStreamInfo(
        url = ensureRateBypass(format.url!!),
        itag = format.itag,
        bitrate = format.bitrate,
        averageBitrate = format.averageBitrate,
        mimeType = format.mimeType,
        audioQuality = format.audioQuality,
        audioSampleRate = format.audioSampleRate,
        loudnessDb = format.loudnessDb ?: player.playerConfig?.audioConfig?.loudnessDb,
        contentLength = format.contentLength,
        captionLanguages = player.captions?.playerCaptionsTracklistRenderer?.captionTracks
            ?.mapNotNull { it.languageCode }
            ?.distinct()
            .orEmpty(),
        initRange = format.initRange?.let { range ->
            range.start.toLongOrNull() to range.end.toLongOrNull()
        }?.takeIf { it.first != null && it.second != null }?.let { it.first!! to it.second!! },
        indexRange = format.indexRange?.let { range ->
            range.start.toLongOrNull() to range.end.toLongOrNull()
        }?.takeIf { it.first != null && it.second != null }?.let { it.first!! to it.second!! }
    )

    // Usa cliente Oculus por defecto, fallback a iOS/Android
    suspend fun getStreamUrl(videoId: String): Result<String?> = runCatching {
        val player = firstPlayablePlayer(videoId, defaultClientOrder) ?: return@runCatching null
        player.pickBestUrl()
    }

    // Variante que permite elegir el cliente explícitamente
    suspend fun getStreamUrl(videoId: String, client: ClientProfile): Result<String?> = runCatching {
        val player = firstPlayablePlayer(videoId, listOf(client)) ?: return@runCatching null
        player.pickBestUrl()
    }

    suspend fun getBestAudioStream(videoId: String): Result<AudioStreamInfo?> = runCatching {
        val player = firstPlayablePlayer(videoId, defaultClientOrder) ?: return@runCatching null
        val chosen = chooseBestFormat(player.audioFormats()) ?: return@runCatching null
        buildAudioStream(chosen, player)
    }

    // Variante por cliente explícito
    suspend fun getBestAudioStream(videoId: String, client: ClientProfile): Result<AudioStreamInfo?> = runCatching {
        val player = firstPlayablePlayer(videoId, listOf(client)) ?: return@runCatching null
        val chosen = chooseBestFormat(player.audioFormats()) ?: return@runCatching null
        buildAudioStream(chosen, player)
    }

    // ========== FUNCIONES OPCIONALES (REQUIEREN AUTENTICACIÓN) ==========
    // Solo necesarias si quieres funciones de cuenta personal
    suspend fun login(credentials: LoginCredentials): Result<LoginResult> =
        authService.login(credentials).onSuccess { result ->
            if (result.success) {
                api.setOriginalHeaders(authService.buildRequestHeaders())
            }
        }
    fun logout() = authService.logout()
    fun isLoggedIn(): Boolean = authService.isLoggedIn()
    // Funciones que SÍ requieren autenticación
    suspend fun getAccountInfo(): Result<AccountInfo?> = authService.getAccountInfo()
    suspend fun getLibraryPlaylists(): Result<List<LibraryPlaylist>> = authService.getLibraryPlaylists()
    suspend fun getLikedSongsInfo(): Result<LikedSongsInfo> = authService.getLikedSongsInfo()
    suspend fun addToLiked(videoId: String): Result<Boolean> = authService.addToLiked(videoId)
    suspend fun removeFromLiked(videoId: String): Result<Boolean> = authService.removeFromLiked(videoId)
    suspend fun createPlaylist(
        title: String,
        description: String? = null,
        isPrivate: Boolean = true,
        videoIds: List<String>? = null
    ): Result<String> = authService.createPlaylist(title, description, isPrivate, videoIds)
    suspend fun addToPlaylist(playlistId: String, videoId: String): Result<Boolean> = authService.addToPlaylist(playlistId, videoId)
    suspend fun removeFromPlaylist(playlistId: String, videoId: String, setVideoId: String? = null): Result<Boolean> =
        authService.removeFromPlaylist(playlistId, videoId, setVideoId)

    suspend fun testUrlAccess(url: String): Result<Boolean> = runCatching {
        try {
            val conn = createHttpConnection(url).apply {
                requestMethod = "HEAD"
                // Sin headers extra; solo HEAD
                connectTimeout = 5000
                readTimeout = 5000
            }
            val code = conn.responseCode
            conn.disconnect()
            code in 200..299 || code == 206
        } catch (e: Exception) { false }
    }

    // Obtiene Content-Length mediante HEAD (si está disponible)
    suspend fun headContentLength(url: String): Result<Long?> = runCatching {
        val conn = createHttpConnection(url)
        try {
            conn.requestMethod = "HEAD"
            // No enviar headers adicionales
            conn.connectTimeout = 5000
            conn.readTimeout = 5000
            conn.getHeaderField("Content-Length")?.toLongOrNull()
        } finally {
            runCatching { conn.disconnect() }
        }
    }

    // Verifica soporte de rangos intentando solicitar los últimos 2 bytes
    suspend fun supportsByteRanges(url: String, totalLength: Long): Result<Boolean> = runCatching {
        if (totalLength < 2) return@runCatching false
        val start = totalLength - 2
        val end = totalLength - 1
        val conn = createHttpConnection(url)
        try {
            conn.requestMethod = "GET"
            // Solo header Range, como en index.js
            conn.setRequestProperty("Range", "bytes=${'$'}start-${'$'}end")
            conn.connectTimeout = 5000
            conn.readTimeout = 5000
            conn.responseCode == 206
        } catch (e: Exception) {
            false
        } finally {
            runCatching { conn.disconnect() }
        }
    }

    // Función para obtener información detallada de formatos de audio disponibles
    suspend fun getAudioFormatsInfo(videoId: String): Result<List<AudioFormatInfo>> = runCatching {
        val qRank = mapOf("AUDIO_QUALITY_HIGH" to 3, "AUDIO_QUALITY_MEDIUM" to 2, "AUDIO_QUALITY_LOW" to 1)
        
        var pr = api.playeriOS(videoId)
        if (pr.playabilityStatus?.status != "OK") {
            pr = api.playerAndroid(videoId)
            if (pr.playabilityStatus?.status != "OK") return@runCatching emptyList()
        }
        
        val sd = pr.streamingData ?: return@runCatching emptyList()
        val allFormats = (sd.adaptiveFormats.orEmpty() + sd.formats.orEmpty())
            .filter { it.isAudio }
            .sortedWith(compareByDescending<PlayerResponse.Format> {
                qRank[it.audioQuality] ?: 0
            }.thenByDescending {
                it.bitrate ?: it.averageBitrate ?: 0
            })
        
        allFormats.map { fmt ->
            AudioFormatInfo(
                itag = fmt.itag,
                mimeType = fmt.mimeType,
                bitrate = fmt.bitrate,
                averageBitrate = fmt.averageBitrate,
                audioQuality = fmt.audioQuality,
                audioSampleRate = fmt.audioSampleRate,
                loudnessDb = fmt.loudnessDb ?: pr.playerConfig?.audioConfig?.loudnessDb,
                contentLength = fmt.contentLength,
                hasUrl = !fmt.url.isNullOrEmpty()
            )
        }
    }

    data class AudioFormatInfo(
        val itag: Int,
        val mimeType: String?,
        val bitrate: Int?,
        val averageBitrate: Int?,
        val audioQuality: String?,
        val audioSampleRate: String?,
        val loudnessDb: Float?,
        val contentLength: String?,
        val hasUrl: Boolean,
    // campos relacionados a cipher eliminados
    )

    data class AudioStreamInfo(
        val url: String,
        val itag: Int,
        val bitrate: Int?,
        val averageBitrate: Int?,
        val mimeType: String?,
        val audioQuality: String?,
        val audioSampleRate: String?,
        val loudnessDb: Float?,
        val contentLength: String?,
        val captionLanguages: List<String> = emptyList(),
        val initRange: Pair<Long, Long>? = null, // start, end
        val indexRange: Pair<Long, Long>? = null // start, end
    )

    suspend fun getAvatarUrlOrNull(): String? = getAccountInfo().getOrNull()?.thumbnails?.firstOrNull()?.url
    fun buildSizedAvatarUrl(base: String, size: Int): String = base.replace(Regex("(?<=\\=s)\\d+"), size.toString())
    suspend fun getAvatarUrl(size: Int? = null): String? = getAvatarUrlOrNull()?.let { b -> size?.let { buildSizedAvatarUrl(b, it) } ?: b }
    suspend fun getAvatarUrls(sizes: List<Int>): Map<Int, String> = getAvatarUrlOrNull()?.let { b -> sizes.associateWith { buildSizedAvatarUrl(b, it) } } ?: emptyMap()
    fun getLibraryPlaylistsFlow(): Flow<List<LibraryPlaylist>> = authService.getLibraryPlaylistsFlow()
    fun getCurrentAccountFlow(): Flow<AccountInfo?> = authService.getCurrentAccountFlow()
    fun getAuthStateFlow(): StateFlow<AuthenticationState> = authService.authState
    suspend fun refreshTokens(): Result<TokenRefreshResult> = authService.refreshTokensIfNeeded()
    suspend fun validateSession(): Result<Boolean> = authService.validateSession()
    suspend fun getWatchHistory(): Result<List<LibraryPlaylist>> = authService.getWatchHistory()
    fun exportSessionData(): Result<AuthenticationState> = authService.exportSessionData()
    suspend fun importSessionData(state: AuthenticationState): Result<Boolean> = authService.importSessionData(state)
    fun getAdvancedLoginInstructions(): String = authService.getAdvancedLoginInstructions()
    fun hasFullAuthSupport(): Boolean = true
    fun getAuthCoverage(): Int = 100
    fun getAuthStatus(): Map<String, Any> = mapOf(
        "providerAuthStatus" to authService.isLoggedIn(),
        "apiAuthStatus" to api.isAuthenticationValid(),
        "authCoverage" to getAuthCoverage(),
        "hasFullSupport" to hasFullAuthSupport(),
        "authRequired" to false
    ) + api.getAuthStatus()
    fun getLoginInstructions(): String = """
        AUTENTICACIÓN OPCIONAL:
        
        Las funciones básicas (buscar, reproducir música, álbumes, artistas) funcionan SIN necesidad de iniciar sesión.
        
        Solo necesitas autenticarte si quieres:
        • Acceder a tus playlists personales
        • Guardar canciones en "Me gusta"
        • Crear/editar playlists
        • Ver tu historial
        
        ${authService.getAdvancedLoginInstructions()}
    """.trimIndent()
    fun close() { api.close(); authService.close() }
    
    // Inicializa visitorData si no existe y la devuelve para persistirla
    suspend fun ensureVisitorData(): String? = api.ensureVisitorInitialized()
    
    companion object {
        fun create(): IntermusicProvider = IntermusicProvider().apply { 
            locale = IntermusicLocale(gl = Locale.getDefault().country, hl = Locale.getDefault().toLanguageTag()) 
        }
        
        @Volatile private var sharedInstance: IntermusicProvider? = null
        fun shared(): IntermusicProvider = sharedInstance ?: synchronized(this) { 
            sharedInstance ?: create().also { sharedInstance = it } 
        }
    }
}

private fun createHttpConnection(target: String): HttpURLConnection {
    // Use URI to avoid deprecated java.net.URL string constructor.
    return (URI.create(target).toURL().openConnection() as HttpURLConnection)
}


enum class SearchFilter(val params: String) {
    SONGS("EgWKAQIIAWoKEAkQBRAKEAMQBA%3D%3D"),
    VIDEOS("EgWKAQIQAWoKEAkQBRAKEAMQBA%3D%3D"),
    ALBUMS("EgWKAQIYAWoKEAkQBRAKEAMQBA%3D%3D"),
    ARTISTS("EgWKAQIgAWoKEAkQBRAKEAMQBA%3D%3D"),
    PLAYLISTS("EgWKAQIoAWoKEAkQBRAKEAMQBA%3D%3D")
}
