package com.rmusic.providers.intermusic

import com.rmusic.providers.intermusic.debug.IntermusicDebugTracer
import com.rmusic.providers.intermusic.auth.IntermusicAuth
import com.rmusic.providers.intermusic.models.IntermusicLocale
import com.rmusic.providers.intermusic.models.response.BrowseResponse
import com.rmusic.providers.intermusic.models.response.PlayerResponse
import com.rmusic.providers.intermusic.pages.*
import com.rmusic.providers.intermusic.parser.*
import com.rmusic.providers.utils.runCatchingCancellable
import io.ktor.client.call.body
import io.ktor.client.statement.bodyAsText
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.StateFlow
import java.net.HttpURLConnection
import java.net.URI
import java.util.Locale
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.longOrNull

private const val HOME_BROWSE_ID = "FEmusic_home"
private const val QUICK_PICKS_BROWSE_ID = "FEmusic_quick_picks"
private const val DEFAULT_MOOD_STRIPE_COLOR: Long = 0xFF3C3C3CL
class IntermusicProvider(
    private var debugTracer: IntermusicDebugTracer = IntermusicDebugTracer.NO_OP
) {
    private val api = IntermusicAPI(debugTracer = debugTracer)
    private val jsonParser = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }

    var locale: IntermusicLocale
        get() = api.locale
        set(value) { api.locale = value }
    // visitorData setter/getter provisto por propiedad; evitar duplicados de setVisitorData
    var visitorData: String?
        get() = api.visitorData
        set(value) { api.visitorData = value }

    fun login(cookieString: String, authUser: String = "0", pageId: String? = null, idToken: String? = null) {
        api.auth = IntermusicAuth.fromCookieString(cookieString)
        api.authUser = authUser
        api.pageId = pageId
        api.idToken = idToken
    }

    fun logout() {
        api.auth = null
    }

    fun getCookies(): String? {
        return api.auth?.cookies
    }

    // ========== FUNCIONES BÁSICAS (SIN AUTENTICACIÓN REQUERIDA) ==========
    
    suspend fun search(query: String, filter: SearchFilter? = null): Result<SearchResult> = runCatching {
        parseSearchResults(api.search(query = query, params = filter?.params).body())
    }

    suspend fun getSearchSuggestions(input: String): Result<List<String>> = runCatchingCancellable {
        parseSearchSuggestions(api.searchSuggestions(input).body())
    }

    suspend fun getHome(continuation: String? = null): Result<HomeResult> = runCatching {
        val response = api.browse(
            browseId = if (continuation == null) HOME_BROWSE_ID else null,
            continuation = continuation
        )
        parseHomePage(response.body())
    }

    suspend fun getQuickPicks(continuation: String? = null): Result<HomeResult> = runCatching {
        val response = api.browse(
            browseId = if (continuation == null) QUICK_PICKS_BROWSE_ID else null,
            continuation = continuation
        ).body<BrowseResponse>()
        parseHomePage(response)
    }
    
    suspend fun getAlbum(browseId: String, params: String? = null): Result<AlbumResult> = runCatching {
        parseAlbumPage(api.browse(browseId = browseId, params = params).body())
    }
    
    suspend fun getArtist(browseId: String): Result<ArtistResult> = runCatching { 
        parseArtistPage(api.browse(browseId = browseId).body()) 
    }
    
    suspend fun getPlaylist(playlistId: String, params: String? = null): Result<PlaylistResult> = runCatching {
        val browseId = if (playlistId.startsWith("VL")) playlistId else "VL$playlistId"
        parsePlaylistPage(api.browse(browseId = browseId, params = params).body())
    }

    private val qualityRank = mapOf(
        "AUDIO_QUALITY_HIGH" to 3,
        "AUDIO_QUALITY_MEDIUM" to 2,
        "AUDIO_QUALITY_LOW" to 1
    )

    // Devuelve un SongResult listo para convertir a MediaItem
    suspend fun getPlayer(videoId: String): Result<SongResult> = runCatching {
        val response = playablePlayer(videoId)
            ?: error("Player response not available")
        parseStreamingData(response)
    }

    enum class SearchFilter(val params: String) {
        SONGS("EgWKAQIIAWoKEAkQBRAKEAMQBA%3D%3D"),
        VIDEOS("EgWKAQIQAWoKEAkQBRAKEAMQBA%3D%3D"),
        ALBUMS("EgWKAQIYAWoKEAkQBRAKEAMQBA%3D%3D"),
        ARTISTS("EgWKAQIgAWoKEAkQBRAKEAMQBA%3D%3D"),
        PLAYLISTS("EgWKAQIoAWoKEAkQBRAKEAMQBA%3D%3D")
    }

    private suspend fun playablePlayer(videoId: String): PlayerResponse? =
        runCatching { api.playerOculus(videoId) }
            .getOrNull()
            ?.takeIf { it.playabilityStatus?.status == "OK" }

    private fun PlayerResponse.audioFormats(): List<PlayerResponse.Format> {
        val data = streamingData ?: return emptyList()
        val adaptive = data.adaptiveFormats.orEmpty().filter { it.isAudio }
        val progressive = data.formats.orEmpty().filter { it.isAudio || it.hasEmbeddedAudio }
        return (adaptive + progressive).filter { !it.url.isNullOrEmpty() }
    }

    private fun ensureRateBypass(url: String): String =
        if (url.contains("ratebypass=")) url
        else url + (if (url.contains('?')) "&" else "?") + "ratebypass=yes"

    private fun PlayerResponse.bestAudioFormat(): PlayerResponse.Format? =
        audioFormats().maxByOrNull {
            (qualityRank[it.audioQuality] ?: 0) * 1_000_000 + (it.bitrate ?: it.averageBitrate ?: 0)
        }

    private fun PlayerResponse.pickBestUrl(): String? {
        val directUrl = bestAudioFormat()?.url
        if (!directUrl.isNullOrEmpty()) return ensureRateBypass(directUrl)
        val data = streamingData ?: return null
        return listOfNotNull(data.hlsManifestUrl, data.serverAbrStreamingUrl, data.dashManifestUrl).firstOrNull()
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
        initRange = format.initRange.toLongPair(),
        indexRange = format.indexRange.toLongPair()
    )

    private fun PlayerResponse.Range?.toLongPair(): Pair<Long, Long>? {
        val start = this?.start?.toLongOrNull()
        val end = this?.end?.toLongOrNull()
        return if (start != null && end != null) start to end else null
    }

    suspend fun getStreamUrl(videoId: String): Result<String?> = runCatching {
        val player = playablePlayer(videoId) ?: return@runCatching null
        player.pickBestUrl()
    }

    suspend fun getBestAudioStream(videoId: String): Result<AudioStreamInfo?> = runCatching {
        val player = playablePlayer(videoId) ?: return@runCatching null
        val chosen = player.bestAudioFormat() ?: return@runCatching null
        buildAudioStream(chosen, player)
    }

    suspend fun getWatchNextRadio(videoId: String, maxItems: Int = 25): Result<List<SongItem>> = runCatchingCancellable {
        val payload = api.next(videoId = videoId)
            .bodyAsText()
            .let { jsonParser.parseToJsonElement(it).jsonObject }

        val playlistPanel = payload
            .get("contents").asObject()
            ?.get("singleColumnMusicWatchNextResultsRenderer").asObject()
            ?.get("tabbedRenderer").asObject()
            ?.get("watchNextTabbedResultsRenderer").asObject()
            ?.get("tabs").asArray()
            ?.mapNotNull { it.asObject()?.get("tabRenderer").asObject() }
            ?.firstOrNull { tab ->
                tab["selected"].asPrimitive()?.booleanOrNull != false ||
                    tab["title"].asText()?.contains("queue", ignoreCase = true) == true
            }
            ?.get("content").asObject()
            ?.get("musicQueueRenderer").asObject()
            ?.get("content").asObject()
            ?.get("playlistPanelRenderer").asObject()
            ?: return@runCatchingCancellable emptyList()

        parseWatchNextPlaylist(playlistPanel, maxItems)
    }

    suspend fun testUrlAccess(url: String): Result<Boolean> = runCatching {
        withHttpConnection(url, method = "HEAD") {
            responseCode in 200..299 || responseCode == HttpURLConnection.HTTP_PARTIAL
        }
    }

    // Obtiene Content-Length mediante HEAD (si está disponible)
    suspend fun headContentLength(url: String): Result<Long?> = runCatching {
        withHttpConnection(url, method = "HEAD") {
            getHeaderField("Content-Length")?.toLongOrNull()
        }
    }

    // Verifica soporte de rangos intentando solicitar los últimos 2 bytes
    suspend fun supportsByteRanges(url: String, totalLength: Long): Result<Boolean> = runCatching {
        if (totalLength < 2) return@runCatching false
        val start = totalLength - 2
        val end = totalLength - 1
        withHttpConnection(
            target = url,
            method = "GET",
            configure = { setRequestProperty("Range", "bytes=${'$'}start-${'$'}end") }
        ) {
            responseCode == HttpURLConnection.HTTP_PARTIAL
        }
    }


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

    data class MoodItem(
        val title: String,
        val stripeColor: Long,
        val browseId: String?,
        val params: String?
    )

    data class MoodSection(
        val title: String,
        val items: List<MoodItem>
    )

    suspend fun getMoods(): Result<List<MoodSection>> = runCatching {
        val response = api.browse(browseId = "FEmusic_moods_and_genres")
        val payload = response.bodyAsText()
        val root = jsonParser.parseToJsonElement(payload).jsonObject
        extractMoodSections(root)
    }

    suspend fun getLyrics(videoId: String): Result<String?> = runCatching {
        val nextRoot = api.next(videoId = videoId)
            .bodyAsText()
            .let { jsonParser.parseToJsonElement(it).jsonObject }
        val endpoint = extractLyricsEndpoint(nextRoot) ?: return@runCatching null
        val lyricsRoot = api.browse(browseId = endpoint.browseId, params = endpoint.params)
            .bodyAsText()
            .let { jsonParser.parseToJsonElement(it).jsonObject }
        extractLyricsText(lyricsRoot)
    }

    private fun extractMoodSections(root: JsonObject): List<MoodSection> =
        root.sectionCandidates().mapNotNull(::parseMoodSection).toList()

    private fun parseMoodSection(section: JsonObject): MoodSection? {
        val collected = mutableListOf<MoodItem>()
        section["gridRenderer"].asObject()?.let { collected += parseMoodItemsFromGrid(it) }
        section["musicCarouselShelfRenderer"].asObject()?.let { collected += parseMoodItemsFromCarousel(it) }
        if (collected.isEmpty()) return null

        val distinctItems = collected.distinctBy { it.browseId to it.params }
        if (distinctItems.isEmpty()) return null

        val title = extractSectionTitle(section)
        return MoodSection(title = title.ifBlank { "" }, items = distinctItems)
    }

    private fun parseMoodItemsFromGrid(grid: JsonObject): List<MoodItem> =
        grid["items"].asArray()?.mapNotNull { element ->
            val button = element.asObject()?.get("musicNavigationButtonRenderer").asObject() ?: return@mapNotNull null
            parseMoodItem(button)
        } ?: emptyList()

    private fun parseMoodItemsFromCarousel(carousel: JsonObject): List<MoodItem> =
        carousel["contents"].asArray()?.mapNotNull { element ->
            val item = element.asObject() ?: return@mapNotNull null
            item["musicNavigationButtonRenderer"].asObject()?.let(::parseMoodItem)
        } ?: emptyList()

    private fun parseMoodItem(button: JsonObject): MoodItem? {
        val title = button["buttonText"].asText() ?: button["text"].asText() ?: return null
        val endpoint = button["clickCommand"].asObject()?.get("browseEndpoint").asObject()
            ?: button["navigationEndpoint"].asObject()?.get("browseEndpoint").asObject()
            ?: return null
        val browseId = endpoint["browseId"].asPrimitive()?.contentOrNull
        val params = endpoint["params"].asPrimitive()?.contentOrNull
        val colorPrimitive = button["solid"].asObject()?.get("leftStripeColor").asPrimitive()
        val stripeColor = colorPrimitive?.longOrNull
            ?: colorPrimitive?.contentOrNull?.toColorLong()
            ?: DEFAULT_MOOD_STRIPE_COLOR
        return MoodItem(
            title = title,
            stripeColor = stripeColor,
            browseId = browseId,
            params = params
        )
    }

    private fun extractSectionTitle(section: JsonObject): String {
        val candidates = listOfNotNull(
            section["gridRenderer"].asObject()
                ?.get("header").asObject()
                ?.get("gridHeaderRenderer").asObject()
                ?.get("title").asText(),
            section["musicCarouselShelfRenderer"].asObject()
                ?.get("header").asObject()
                ?.get("musicCarouselShelfBasicHeaderRenderer").asObject()
                ?.get("title").asText(),
            section["musicShelfRenderer"].asObject()
                ?.get("title").asText(),
            section["musicResponsiveHeaderRenderer"].asObject()
                ?.get("title").asText()
        )
        return candidates.firstOrNull { !it.isNullOrBlank() }?.trim().orEmpty()
    }

    private data class LyricsEndpoint(val browseId: String, val params: String?)

    private fun extractLyricsEndpoint(root: JsonObject): LyricsEndpoint? {
        val tabs = root["contents"].asObject()
            ?.get("singleColumnMusicWatchNextResultsRenderer").asObject()
            ?.get("tabbedRenderer").asObject()
            ?.get("watchNextTabbedResultsRenderer").asObject()
            ?.get("tabs").asArray() ?: return null

        val lyricsTab = tabs.firstNotNullOfOrNull { element ->
            val tabRenderer = element.asObject()?.get("tabRenderer").asObject() ?: return@firstNotNullOfOrNull null
            val titleText = tabRenderer["title"].asText()?.lowercase(Locale.getDefault())
            if (titleText != null && (titleText.contains("lyric") || titleText.contains("letra"))) tabRenderer else null
        } ?: tabs.getOrNull(1)?.asObject()?.get("tabRenderer").asObject()

        val endpoint = lyricsTab?.get("endpoint").asObject()?.get("browseEndpoint").asObject() ?: return null
        val browseId = endpoint["browseId"].asPrimitive()?.contentOrNull ?: return null
        val params = endpoint["params"].asPrimitive()?.contentOrNull
        return LyricsEndpoint(browseId = browseId, params = params)
    }

    private fun extractLyricsText(root: JsonObject): String? =
        root.sectionCandidates().mapNotNull { section ->
            val header = section["musicResponsiveHeaderRenderer"].asObject()
            val descriptionNode = section["musicDescriptionShelfRenderer"].asObject()?.get("description")
                ?: header?.get("description")
                ?: header?.get("secondSubtitle")
                ?: header?.get("subtitle")
                ?: header?.get("title")
            descriptionNode.asText()?.trim().takeUnless { it.isNullOrEmpty() }
        }.firstOrNull()

    private fun JsonObject.sectionCandidates(): Sequence<JsonObject> {
        val contents = this["contents"].asObject()
        val nested = contents
            ?.get("singleColumnBrowseResultsRenderer").asObject()
            ?.get("tabs").asArray()
            ?.firstOrNull().asObject()
            ?.get("tabRenderer").asObject()
            ?.get("content").asObject()
            ?.get("sectionListRenderer").asObject()
            ?.get("contents").asArray()
        val direct = contents
            ?.get("sectionListRenderer").asObject()
            ?.get("contents").asArray()
        return listOfNotNull(nested, direct)
            .asSequence()
            .flatMap { array -> array.asSequence().mapNotNull { it.asObject() } }
    }

    private fun JsonElement?.asObject(): JsonObject? = when (this) {
        is JsonObject -> this
        else -> null
    }

    private fun JsonElement?.asArray(): JsonArray? = when (this) {
        is JsonArray -> this
        else -> null
    }

    private fun JsonElement?.asPrimitive(): JsonPrimitive? = when (this) {
        is JsonPrimitive -> this
        else -> null
    }

    private fun JsonElement?.asText(): String? = when (this) {
        null -> null
        is JsonPrimitive -> contentOrNull
        is JsonObject -> {
            this["simpleText"].asText()
                ?: this["text"].asText()
                ?: this["runs"].asArray()?.mapNotNull { run -> run.asObject()?.get("text").asText() }
                    ?.joinToString(separator = "")?.takeIf { it.isNotBlank() }
                ?: this["musicDescriptionShelfRenderer"].asObject()?.get("description").asText()
                ?: this["description"].asText()
        }
        is JsonArray -> this.mapNotNull { it.asText() }.joinToString(separator = "").takeIf { it.isNotBlank() }
    }

    private fun parseWatchNextPlaylist(panel: JsonObject, maxItems: Int): List<SongItem> {
        val contents = panel["contents"].asArray() ?: return emptyList()

        val collected = mutableListOf<SongItem>()
        contents.forEach { element ->
            if (collected.size >= maxItems) return@forEach
            val renderer = element.asObject()
                ?.get("playlistPanelVideoRenderer").asObject()
                ?: element.asObject()
                    ?.get("playlistPanelVideoWrapperRenderer").asObject()
                    ?.get("primaryRenderer").asObject()
                    ?.get("playlistPanelVideoRenderer").asObject()
                ?: return@forEach

            val videoId = renderer["videoId"].asPrimitive()?.contentOrNull ?: return@forEach
            val title = renderer["title"].asText()?.takeIf { it.isNotBlank() } ?: return@forEach
            val artists = renderer["shortBylineText"].asObject()
                ?.get("runs").asArray().toArtistItems()
            val duration = renderer["lengthText"].asText()
            val thumbnails = renderer["thumbnail"].asObject()
                ?.get("thumbnails").asArray().toThumbnails()
            val explicit = renderer["badges"].asArray()
                ?.any { badge ->
                    badge.asObject()
                        ?.get("musicInlineBadgeRenderer").asObject()
                        ?.get("icon").asObject()
                        ?.get("iconType").asPrimitive()?.contentOrNull == "MUSIC_EXPLICIT_BADGE"
                } ?: false

            collected += SongItem(
                videoId = videoId,
                title = title,
                artists = artists,
                duration = duration,
                thumbnails = thumbnails,
                explicit = explicit
            )
        }

        return collected.distinctBy { it.videoId }.take(maxItems)
    }

    private fun JsonArray?.toThumbnails(): List<Thumbnail> = this?.mapNotNull { element ->
        val obj = element.asObject() ?: return@mapNotNull null
        val url = obj["url"].asText()?.takeIf { it.isNotBlank() } ?: return@mapNotNull null
        Thumbnail(
            url = url,
            width = obj["width"].asPrimitive()?.intOrNull,
            height = obj["height"].asPrimitive()?.intOrNull
        )
    } ?: emptyList()

    private fun JsonArray?.toArtistItems(): List<ArtistItem> = this?.mapNotNull { element ->
        val obj = element.asObject() ?: return@mapNotNull null
        val name = obj["text"].asText()?.trim().orEmpty()
        if (name.isBlank()) return@mapNotNull null
        val browseId = obj["navigationEndpoint"].asObject()
            ?.get("browseEndpoint").asObject()
            ?.get("browseId").asPrimitive()?.contentOrNull
        ArtistItem(browseId = browseId, name = name)
    } ?: emptyList()

    private fun String?.toColorLong(): Long? {
        if (this == null) return null
        val trimmed = trim()
        trimmed.toLongOrNull()?.let { return it }
        val normalized = trimmed.removePrefix("#").removePrefix("0x").removePrefix("0X")
        return normalized.toLongOrNull(16)
    }

    suspend fun getAvatarUrl(size: Int? = null): String? {
        return null
    }
    
    // Inicializa visitorData si no existe y la devuelve para persistirla
    suspend fun ensureVisitorData(): String? = api.ensureVisitorInitialized()

    internal fun updateDebugTracer(tracer: IntermusicDebugTracer) {
        debugTracer = tracer
        api.installDebugTracer(tracer)
    }
    
    fun close() { api.close() }
    
    companion object {
        private var instance: IntermusicProvider? = null
        fun shared(): IntermusicProvider {
            if (instance == null) {
                instance = IntermusicProvider()
            }
            return instance!!
        }
    }
}

private fun createHttpConnection(target: String): HttpURLConnection {
    // Use URI to avoid deprecated java.net.URL string constructor.
    return (URI.create(target).toURL().openConnection() as HttpURLConnection)
}

private inline fun <T> withHttpConnection(
    target: String,
    method: String,
    timeoutMs: Int = 5_000,
    configure: HttpURLConnection.() -> Unit = {},
    block: HttpURLConnection.() -> T,
): T {
    val conn = createHttpConnection(target)
    return try {
        conn.requestMethod = method
        conn.connectTimeout = timeoutMs
        conn.readTimeout = timeoutMs
        conn.configure()
        block(conn)
    } finally {
        runCatching { conn.disconnect() }
    }
}

