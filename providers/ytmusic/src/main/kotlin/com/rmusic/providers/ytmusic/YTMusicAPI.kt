package com.rmusic.providers.ytmusic

import com.rmusic.providers.ytmusic.models.YTMusicContext
import com.rmusic.providers.ytmusic.models.YTMusicLocale
import com.rmusic.providers.ytmusic.models.body.AccountMenuBody
import com.rmusic.providers.ytmusic.models.body.AddPlaylistItemBody
import com.rmusic.providers.ytmusic.models.body.BrowseBody
import com.rmusic.providers.ytmusic.models.body.CreatePlaylistBody
import com.rmusic.providers.ytmusic.models.body.EditPlaylistBody
import com.rmusic.providers.ytmusic.models.body.LikeBody
import com.rmusic.providers.ytmusic.models.body.NextBody
import com.rmusic.providers.ytmusic.models.body.PlayerBody
import com.rmusic.providers.ytmusic.models.body.RemovePlaylistItemBody
import com.rmusic.providers.ytmusic.models.body.SearchBody
import com.rmusic.providers.ytmusic.models.response.PlayerResponse
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.engine.okhttp.OkHttp
import io.ktor.client.plugins.compression.ContentEncoding
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.defaultRequest
import io.ktor.client.request.*
import io.ktor.client.statement.HttpResponse
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.contentType
import io.ktor.http.userAgent
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonArray
import java.util.Locale
import kotlin.random.Random

class YTMusicAPI(
    var baseHeaders: Map<String, String> = emptyMap(),
) {
    var proxy: java.net.Proxy? = null

    private fun computedBaselineHeaders(): Map<String,String> = mapOf(
        "accept" to "*/*",
        "accept-language" to listOf(locale.hl, "en-US", "es-419", "es").distinct().joinToString(",") { it + ";q=0.9" },
        "priority" to "u=1, i",
    )

    private val chromeClientHintPrefix = setOf(
        "sec-ch-ua","sec-ch-ua-arch","sec-ch-ua-bitness","sec-ch-ua-form-factors","sec-ch-ua-full-version","sec-ch-ua-full-version-list","sec-ch-ua-mobile","sec-ch-ua-model","sec-ch-ua-platform","sec-ch-ua-platform-version","sec-ch-ua-wow64"
    )

    fun setOriginalHeaders(headers: Map<String,String>) {
        baseHeaders = headers
        headers["cookie"]?.let { cookie = it }
    }

    fun setSession(
        authorization: String? = null,
        cookieHeader: String? = null,
        xGoogAuthUser: String? = "0",
        xGoogVisitorId: String? = null,
        extra: Map<String,String> = emptyMap()
    ) {
        val mutable = baseHeaders.toMutableMap()
        authorization?.let { mutable["authorization"] = it }
        xGoogAuthUser?.let { mutable["x-goog-authuser"] = it }
        xGoogVisitorId?.let { mutable["x-goog-visitor-id"] = it }
        cookieHeader?.let { mutable["cookie"] = it; cookie = it }
        mutable += extra
        baseHeaders = mutable
    }
    private val http = HttpClient(OkHttp) {
        install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true; encodeDefaults = true; isLenient = true }) }
        install(ContentEncoding) { gzip(); deflate() }
        defaultRequest { url("https://music.youtube.com/youtubei/v1/") }
    }

    companion object {
        private const val IOS_VERSION = "20.10.4"
        private const val API_KEY = "AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc"
        private const val IOS_UA = "com.google.ios.youtube/$IOS_VERSION (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)"
        private const val CLIENT_NAME_NUMERIC = "5"
        
        // Android client constants (siguiendo el ejemplo funcional de youtube-request.js)
        private const val ANDROID_VERSION = "19.49.37"
        private const val ANDROID_API_KEY = "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8"
        private const val ANDROID_UA = "com.google.android.youtube/$ANDROID_VERSION (Linux; U; Android 11) gzip"
        private const val ANDROID_CLIENT_NAME_NUMERIC = "3"
        private const val ANDROID_SDK_VERSION = 30
        
        private const val ORIGIN = "https://music.youtube.com"
        private const val WEB_REMIX_VERSION = "1.20250215.01.00"
        private const val WEB_REMIX_API_KEY = "AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30"
        private const val WEB_REMIX_UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
        private const val WEB_REMIX_CLIENT_NAME_NUMERIC = "67" // Innertube client para YouTube Music web
    }

    var locale = YTMusicLocale(gl = Locale.getDefault().country.ifBlank { "US" }, hl = Locale.getDefault().toLanguageTag())
    var cookie: String? = null
    var visitorData: String? = null

    private fun genCpn(): String {
        // Generación CPN como en el ejemplo funcional youtube-request.js
        val chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
        return (1..16).map { chars[Random.nextInt(chars.length)] }.joinToString("")
    }

    private suspend fun ensureVisitor() {
        if (visitorData != null) return
        runCatching {
            val raw = http.get("https://www.youtube.com/sw.js_data").bodyAsText()
            val cleaned = if (raw.startsWith(")]}'")) raw.substring(4) else raw
            val el = Json.parseToJsonElement(cleaned)
            visitorData = el.jsonArray.getOrNull(0)
                ?.jsonArray?.getOrNull(2)
                ?.jsonArray?.getOrNull(0)
                ?.jsonArray?.getOrNull(0)
                ?.jsonArray?.getOrNull(13)
                ?.toString()?.trim('"')
        }
    }

    // Exponer inicialización de visitorData para que la app pueda primarlo al arranque
    suspend fun ensureVisitorInitialized(): String? {
        ensureVisitor()
        return visitorData
    }

    private fun androidHeaders(builder: HttpRequestBuilder) = builder.apply {
        contentType(ContentType.Application.Json)
        userAgent(ANDROID_UA)
        // Baseline defaults first, then allow baseHeaders to override/add
        computedBaselineHeaders().forEach { (k, v) -> if (!baseHeaders.containsKey(k)) header(k, v) }
        baseHeaders.forEach { (k, v) -> header(k, v) }
        header("X-YouTube-Client-Name", ANDROID_CLIENT_NAME_NUMERIC)
        header("X-YouTube-Client-Version", ANDROID_VERSION)
    // Asegurar Visitor ID siempre que exista
    visitorData?.let { header("X-Goog-Visitor-Id", it) }
        cookie?.let { header("Cookie", it) }
        parameter("key", ANDROID_API_KEY)
        parameter("prettyPrint", false)
    }

    private fun iosHeaders(builder: HttpRequestBuilder) = builder.apply {
        contentType(ContentType.Application.Json)
        userAgent(IOS_UA)
        computedBaselineHeaders().forEach { (k, v) -> if (!baseHeaders.containsKey(k)) header(k, v) }
        baseHeaders.forEach { (k, v) -> header(k, v) }
        header("Origin", ORIGIN)
        header("x-origin", ORIGIN)
        header("X-Youtube-Client-Name", CLIENT_NAME_NUMERIC)
        header("X-Youtube-Client-Version", IOS_VERSION)
    // Asegurar Visitor ID siempre que exista
    visitorData?.let { header("X-Goog-Visitor-Id", it) }
        cookie?.let { header("Cookie", it) }
        parameter("key", API_KEY)
        parameter("prettyPrint", false)
    }
    private fun webRemixHeaders(builder: HttpRequestBuilder) = builder.apply {
        contentType(ContentType.Application.Json)
        userAgent(WEB_REMIX_UA)
        computedBaselineHeaders().forEach { (k, v) -> if (!baseHeaders.containsKey(k)) header(k, v) }
        baseHeaders.forEach { (k, v) -> header(k, v) }
        header("Origin", ORIGIN)
        header("Referer", "$ORIGIN/")
        header("x-origin", ORIGIN)
        header("X-Youtube-Client-Name", WEB_REMIX_CLIENT_NAME_NUMERIC)
        header("X-Youtube-Client-Version", WEB_REMIX_VERSION)
        cookie?.let { header("Cookie", it) }
        parameter("key", WEB_REMIX_API_KEY)
        parameter("prettyPrint", false)
    }

    private fun androidContext(): YTMusicContext = YTMusicContext(
        client = YTMusicContext.Client(
            clientName = "ANDROID",
            clientVersion = ANDROID_VERSION,
            androidSdkVersion = ANDROID_SDK_VERSION,
            gl = locale.gl.ifBlank { "US" },
            hl = locale.hl.ifBlank { "en" },
            visitorData = visitorData,
            userAgent = ANDROID_UA,
            deviceMake = null,
            deviceModel = null,
            osName = null,
            osVersion = null,
        )
    )

    private fun iosContext(): YTMusicContext = YTMusicContext(
        client = YTMusicContext.Client(
            clientName = "IOS",
            clientVersion = IOS_VERSION,
            gl = locale.gl.ifBlank { "US" },
            hl = locale.hl.ifBlank { "en-US" },
            visitorData = visitorData,
            userAgent = IOS_UA,
            deviceMake = null,
            deviceModel = null,
            osName = null,
            osVersion = null,
        )
    )

    // ========== FUNCIONES PRINCIPALES (SIN AUTENTICACIÓN) ==========
    
    // Player usando iOS por defecto (según requerimiento)
    suspend fun player(videoId: String): PlayerResponse = playeriOS(videoId)

    // Nueva función player usando Android client (siguiendo ejemplo youtube-request.js)
    suspend fun playerAndroid(videoId: String): PlayerResponse {
        ensureVisitor()
        val body = PlayerBody(
            context = androidContext(),
            videoId = videoId,
            cpn = genCpn(),
            contentCheckOk = true,
            racyCheckOk = true,
        )
        val resp = http.post("player") {
            androidHeaders(this)
            setBody(body)
        }
        return resp.body()
    }

    // Fallback iOS player (solo si Android falla)
    suspend fun playeriOS(videoId: String): PlayerResponse {
        // Alinear con index.js: usar endpoint de www.youtube.com con headers iOS y key Android
        ensureVisitor()
        val body = PlayerBody(
            context = iosContext(),
            videoId = videoId,
            cpn = genCpn(),
            contentCheckOk = true,
            racyCheckOk = true,
        )
        val resp = http.post("https://www.youtube.com/youtubei/v1/player") {
            contentType(ContentType.Application.Json)
            userAgent(IOS_UA)
            // Headers mínimos alineados a index.js
            computedBaselineHeaders().forEach { (k, v) -> if (!baseHeaders.containsKey(k)) header(k, v) }
            baseHeaders.forEach { (k, v) -> header(k, v) }
            header("Origin", "https://www.youtube.com")
            header("Referer", "https://www.youtube.com/")
            header("Sec-Fetch-Site", "same-site")
            header("Sec-Fetch-Mode", "cors")
            header("Sec-Fetch-Dest", "empty")
            header("X-YouTube-Client-Name", CLIENT_NAME_NUMERIC)
            header("X-YouTube-Client-Version", IOS_VERSION)
            visitorData?.let { header("X-Goog-Visitor-Id", it) }
            cookie?.let { header("Cookie", it) }
            parameter("key", ANDROID_API_KEY)
            parameter("prettyPrint", false)
            setBody(body)
        }
        return resp.body()
    }

    // ========== FUNCIONES DE NAVEGACIÓN (SIN AUTENTICACIÓN) ==========
    
    suspend fun browse(browseId: String? = null, params: String? = null, continuation: String? = null): HttpResponse = http.post("browse") {
        ensureVisitor()
        iosHeaders(this) // Usar iOS por defecto
        setBody(
            BrowseBody(
                context = iosContext(),
                browseId = browseId,
                params = params,
                continuation = continuation,
            )
        )
    }

    suspend fun search(query: String, params: String? = null): HttpResponse = http.post("search") {
        ensureVisitor()
        iosHeaders(this) // Usar iOS por defecto
        setBody(
            SearchBody(
                context = iosContext(),
                query = query,
                params = params,
            )
        )
    }

    suspend fun next(videoId: String? = null, playlistId: String? = null, playlistSetVideoId: String? = null, index: Int? = null, params: String? = null, continuation: String? = null): HttpResponse = http.post("next") {
        ensureVisitor()
        iosHeaders(this) // Usar iOS por defecto
        setBody(
            NextBody(
                context = iosContext(),
                videoId = videoId,
                playlistId = playlistId,
                playlistSetVideoId = playlistSetVideoId,
                index = index,
                params = params,
                continuation = continuation,
            )
        )
    }
    
    // ========== FUNCIONES DE CUENTA (REQUIEREN AUTENTICACIÓN) ==========
    
    suspend fun accountMenu(): HttpResponse = http.post("account/account_menu") {
        androidHeaders(this) // Android para funciones de cuenta (requerido)
        setBody(AccountMenuBody(context = androidContext()))
    }
    
    suspend fun accountMenuWebRemix(): HttpResponse = http.post("account/account_menu") {
        webRemixHeaders(this)
        val ctx = iosContext().copy(client = iosContext().client.copy(clientName = "WEB_REMIX", clientVersion = WEB_REMIX_VERSION))
        setBody(AccountMenuBody(context = ctx))
    }
    
    // Funciones específicas de playlists/cuenta (requieren auth)
    suspend fun getLibraryPlaylists() = browse(browseId = "FEmusic_liked_playlists")
    suspend fun getLikedSongs() = browse(browseId = "FEmusic_liked_videos")
    suspend fun getHistory() = browse(browseId = "FEmusic_history")

    suspend fun addToLiked(videoId: String): HttpResponse = http.post("like/like") {
        androidHeaders(this)
        setBody(LikeBody(context = androidContext(), target = LikeBody.Target(videoId)))
    }
    
    suspend fun removeFromLiked(videoId: String): HttpResponse = http.post("like/removelike") {
        androidHeaders(this)
        setBody(LikeBody(context = androidContext(), target = LikeBody.Target(videoId)))
    }

    suspend fun createPlaylist(title: String, description: String? = null, privacyStatus: String = "PRIVATE", videoIds: List<String>? = null): HttpResponse = http.post("playlist/create") {
        androidHeaders(this)
        setBody(
            CreatePlaylistBody(
                context = androidContext(),
                title = title,
                description = description,
                privacyStatus = privacyStatus,
                videoIds = videoIds,
            )
        )
    }
    suspend fun editPlaylist(playlistId: String, title: String? = null, description: String? = null, privacyStatus: String? = null): HttpResponse = http.post("browse/edit_playlist") {
        androidHeaders(this)
        setBody(
            EditPlaylistBody(
                context = androidContext(),
                playlistId = playlistId,
                title = title,
                description = description,
                privacyStatus = privacyStatus,
            )
        )
    }
    suspend fun addPlaylistItem(playlistId: String, videoId: String): HttpResponse = http.post("browse/edit_playlist") {
        androidHeaders(this)
        setBody(
            AddPlaylistItemBody(
                context = androidContext(),
                playlistId = playlistId,
                actions = listOf(AddPlaylistItemBody.Action(addedVideoId = videoId)),
            )
        )
    }
    suspend fun removePlaylistItem(playlistId: String, videoId: String, setVideoId: String? = null): HttpResponse = http.post("browse/edit_playlist") {
        androidHeaders(this)
        setBody(
            RemovePlaylistItemBody(
                context = androidContext(),
                playlistId = playlistId,
                actions = listOf(RemovePlaylistItemBody.Action(removedVideoId = videoId, setVideoId = setVideoId)),
            )
        )
    }

    
    // Shortcuts para navegación básica (sin auth)
    suspend fun playlist(playlistId: String) = browse(browseId = if (playlistId.startsWith("VL")) playlistId else "VL$playlistId")
    suspend fun album(browseId: String) = browse(browseId = browseId)
    suspend fun artist(browseId: String) = browse(browseId = browseId)

    // Estado de autenticación simplificado
    fun isAuthenticationValid(): Boolean = cookie != null
    fun getAuthStatus(): Map<String, Any> = mapOf(
        "hasCookie" to (cookie != null),
        "visitorData" to (visitorData != null),
        "authRequired" to false // ¡Las funciones básicas NO requieren auth!
    )

    fun close() { http.close() }
}
