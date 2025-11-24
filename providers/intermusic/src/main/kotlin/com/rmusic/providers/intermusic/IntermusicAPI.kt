package com.rmusic.providers.intermusic

import com.rmusic.providers.intermusic.auth.IntermusicAuth
import com.rmusic.providers.intermusic.debug.IntermusicDebugTracer
import com.rmusic.providers.intermusic.models.IntermusicContext
import com.rmusic.providers.intermusic.models.IntermusicLocale
import com.rmusic.providers.intermusic.models.body.AccountMenuBody
import com.rmusic.providers.intermusic.models.body.AddPlaylistItemBody
import com.rmusic.providers.intermusic.models.body.BrowseBody
import com.rmusic.providers.intermusic.models.body.CreatePlaylistBody
import com.rmusic.providers.intermusic.models.body.EditPlaylistBody
import com.rmusic.providers.intermusic.models.body.LikeBody
import com.rmusic.providers.intermusic.models.body.NextBody
import com.rmusic.providers.intermusic.models.body.PlayerBody
import com.rmusic.providers.intermusic.models.body.RemovePlaylistItemBody
import com.rmusic.providers.intermusic.models.body.SearchBody
import com.rmusic.providers.intermusic.models.body.SearchSuggestionsBody
import com.rmusic.providers.intermusic.models.response.PlayerResponse
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.engine.okhttp.OkHttp
import io.ktor.client.plugins.compression.ContentEncoding
import io.ktor.client.plugins.compression.brotli
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.defaultRequest
import io.ktor.client.request.*
import io.ktor.client.statement.HttpResponse
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.Headers
import io.ktor.http.contentType
import io.ktor.http.userAgent
import kotlinx.serialization.encodeToString
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonArray
import java.time.OffsetDateTime
import java.time.ZoneId
import java.util.Locale
import kotlin.random.Random

class IntermusicAPI(
    var baseHeaders: Map<String, String> = emptyMap(),
    private var debugTracer: IntermusicDebugTracer = IntermusicDebugTracer.NO_OP,
) {
    private val identityTokenRegex = Regex("[\"']ID_TOKEN[\"']\\s*:\\s*[\"']([^\"']+)[\"']")
    private val debugJson = Json { encodeDefaults = true; ignoreUnknownKeys = true }

    private fun acceptLanguageHeader(): String {
        val deviceLocale = runCatching { Locale.getDefault() }.getOrNull()
        val candidates = buildList {
            locale.hl.takeIf { it.isNotBlank() }?.let { add(it) }
            locale.hl.substringBefore('-', missingDelimiterValue = "")
                .takeIf { it.isNotBlank() }?.let { add(it) }
            deviceLocale?.toLanguageTag()?.takeIf { it.isNotBlank() }?.let { add(it) }
            deviceLocale?.language?.takeIf { it.isNotBlank() }?.let { add(it) }
            add("en-US")
            add("en")
        }
        val deduped = candidates.filter { it.isNotBlank() }.distinct()
        if (deduped.isEmpty()) return WEB_REMIX_ACCEPT_LANGUAGE
        return deduped.mapIndexed { index, code ->
            when (index) {
                0 -> code
                1 -> "$code;q=0.9"
                2 -> "$code;q=0.8"
                3 -> "$code;q=0.7"
                else -> "$code;q=0.5"
            }
        }.joinToString(",")
    }

    private fun computedBaselineHeaders(): Map<String,String> = mapOf(
        "accept" to "application/json",
        "accept-language" to acceptLanguageHeader(),
        "accept-encoding" to "gzip, deflate, br, zstd",
        "cache-control" to "no-cache",
        "connection" to "keep-alive",
        "priority" to "u=0, i",
    )

    fun setOriginalHeaders(headers: Map<String,String>) {
        baseHeaders = headers
    }
    fun installDebugTracer(tracer: IntermusicDebugTracer) { debugTracer = tracer }
    private val http = HttpClient(OkHttp) {
    install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true; encodeDefaults = true; isLenient = true }) }
    install(ContentEncoding) { gzip(); deflate(); brotli() }
    defaultRequest { url("https://music.youtube.com/youtubei/v1/") }
    }

    companion object {
        const val DEFAULT_VISITOR_ID = "Cgs1VUdycTl5Ylh3VSiZybTIBjIKCgJTVhIEGgAgEQ%3D%3D"

        private const val CHROME_SEC_CH_UA = "\"Not)A;Brand\";v=\"8\", \"Chromium\";v=\"138\""
        private const val CHROME_SEC_CH_UA_ARCH = "\"x86\""
        private const val CHROME_SEC_CH_UA_BITNESS = "\"64\""
        private const val CHROME_SEC_CH_UA_FORM_FACTORS = "\"Desktop\""
        private const val CHROME_SEC_CH_UA_FULL_VERSION = "\"138.0.7204.184\""
        private const val CHROME_SEC_CH_UA_FULL_VERSION_LIST = "\"Not)A;Brand\";v=\"8.0.0.0\", \"Chromium\";v=\"138.0.7204.184\""
        private const val CHROME_SEC_CH_UA_MOBILE = "?0"
        private const val CHROME_SEC_CH_UA_MODEL = "\"\""
        private const val CHROME_SEC_CH_UA_PLATFORM = "\"Windows\""
        private const val CHROME_SEC_CH_UA_PLATFORM_VERSION = "\"10.0.0\""
        private const val CHROME_SEC_CH_UA_WOW64 = "?0"

        private const val OCULUS_VERSION = "1.61.48"
        private const val OCULUS_CLIENT_NAME_NUMERIC = "28"
        private const val OCULUS_UA = "com.google.android.apps.youtube.vr.oculus/$OCULUS_VERSION (Linux; U; Android 12; es-US; Quest 3; Build/SQ3A.220605.009.A1; Cronet/132.0.6808.3)"
        
        private const val ORIGIN = "https://music.youtube.com"
    private const val WEB_REMIX_VERSION = "1.20251117.03.00"
    private const val WEB_REMIX_API_KEY = "AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30"
    private const val WEB_REMIX_UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36"
    // Mirror the real Web Remix client (67) so cookie-authenticated sessions behave consistently.
    private const val WEB_REMIX_CLIENT_NAME_NUMERIC = "67"
    private const val WEB_REMIX_DEVICE = "cbr=Chrome&cbrver=138.0.0.0&ceng=WebKit&cengver=537.36&cos=Windows&cosver=10.0&cplatform=DESKTOP"
    private const val WEB_REMIX_CLIENT_DATA = "CM3xygE="
    private const val WEB_REMIX_PAGE_CL = "833248169"
    private const val WEB_REMIX_PAGE_LABEL = "youtube.music.web.client_20251117_03_RC00"
    private const val WEB_REMIX_PAGE_ID = "113685719924268177190"
    private const val WEB_REMIX_TIME_ZONE = "America/Mexico_City"
    private const val WEB_REMIX_UTC_OFFSET = -360
    private const val WEB_REMIX_ACCEPT_LANGUAGE = "es-419,es;q=0.9,en-US;q=0.8,en;q=0.7"
    private const val WEB_REMIX_GL = "SV"
    private const val WEB_REMIX_HL = "es-419"
    private const val WEB_REMIX_BROWSER_ACCEPT = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
    private const val WEB_REMIX_BROWSER_ACCEPT_LANGUAGE = "en-US,en;q=0.9,ja;q=0.8,es-419;q=0.7,es;q=0.6,ar;q=0.5"
    }

    var locale = IntermusicLocale(gl = WEB_REMIX_GL, hl = WEB_REMIX_HL)
    var auth: IntermusicAuth? = null
        set(value) {
            field = value
            value?.visitorId?.let { visitorData = it }
        }

    private fun getSapisidHash(sapisid: String): String {
        val time = System.currentTimeMillis() / 1000
        val sha1 = java.security.MessageDigest.getInstance("SHA-1")
        val input = "$time $sapisid $ORIGIN"
        val hash = sha1.digest(input.toByteArray()).joinToString("") { "%02x".format(it) }
        return "SAPISIDHASH ${time}_$hash"
    }
    
    private fun currentSapisidHash(): String? = auth?.sapisid?.let { getSapisidHash(it) }

    var visitorData: String? = null
    var authUser: String? = null
    var pageId: String? = null
    var idToken: String? = null
    var forcedTimeZoneId: String? = WEB_REMIX_TIME_ZONE
    var forcedUtcOffsetMinutes: Int? = WEB_REMIX_UTC_OFFSET
    
    var userAgent: String = WEB_REMIX_UA
    var clientVersion: String = WEB_REMIX_VERSION

    suspend fun ensureVisitorInitialized(): String? {
        if (visitorData.isNullOrBlank()) visitorData = DEFAULT_VISITOR_ID
        return visitorData
    }

    private fun currentTimeZoneInfo(): Pair<String, Int> {
        forcedTimeZoneId?.let { id ->
            return id to (forcedUtcOffsetMinutes ?: WEB_REMIX_UTC_OFFSET)
        }
        val zoneId = runCatching { ZoneId.systemDefault() }.getOrDefault(ZoneId.of(WEB_REMIX_TIME_ZONE))
        val offsetMinutes = runCatching { OffsetDateTime.now(zoneId).offset.totalSeconds / 60 }
            .getOrDefault(WEB_REMIX_UTC_OFFSET)
        return zoneId.id to offsetMinutes
    }

    private fun HttpRequestBuilder.applyChromeClientHints() {
        header("Sec-Ch-Ua", CHROME_SEC_CH_UA)
        header("Sec-Ch-Ua-Arch", CHROME_SEC_CH_UA_ARCH)
        header("Sec-Ch-Ua-Bitness", CHROME_SEC_CH_UA_BITNESS)
        header("Sec-Ch-Ua-Form-Factors", CHROME_SEC_CH_UA_FORM_FACTORS)
        header("Sec-Ch-Ua-Full-Version", CHROME_SEC_CH_UA_FULL_VERSION)
        header("Sec-Ch-Ua-Full-Version-List", CHROME_SEC_CH_UA_FULL_VERSION_LIST)
        header("Sec-Ch-Ua-Mobile", CHROME_SEC_CH_UA_MOBILE)
        header("Sec-Ch-Ua-Model", CHROME_SEC_CH_UA_MODEL)
        header("Sec-Ch-Ua-Platform", CHROME_SEC_CH_UA_PLATFORM)
        header("Sec-Ch-Ua-Platform-Version", CHROME_SEC_CH_UA_PLATFORM_VERSION)
        header("Sec-Ch-Ua-Wow64", CHROME_SEC_CH_UA_WOW64)
    }

    private fun HttpRequestBuilder.applyFetchMetadata(
        dest: String,
        mode: String,
        site: String,
        user: String? = null
    ) {
        header("Sec-Fetch-Dest", dest)
        header("Sec-Fetch-Mode", mode)
        header("Sec-Fetch-Site", site)
        user?.let { header("Sec-Fetch-User", it) }
    }

    private fun webRemixHeaders(builder: HttpRequestBuilder) = builder.apply {
        val (timeZoneId, utcOffsetRaw) = currentTimeZoneInfo()
        val resolvedTimeZone = timeZoneId.takeUnless { it.isBlank() } ?: WEB_REMIX_TIME_ZONE
        val resolvedUtcOffset = utcOffsetRaw.takeIf { it in -720..840 } ?: WEB_REMIX_UTC_OFFSET
        
        contentType(ContentType.Application.Json)
        userAgent(userAgent)
        // Only apply hardcoded hints if we are using the default UA. If UA is custom, hints might be wrong.
        if (userAgent == WEB_REMIX_UA) {
            applyChromeClientHints()
        }
        applyFetchMetadata(dest = "empty", mode = "cors", site = "same-origin")
        
        computedBaselineHeaders().forEach { (k, v) -> 
            if (!baseHeaders.keys.any { it.equals(k, ignoreCase = true) }) header(k, v) 
        }

        auth?.cookies?.let { header("Cookie", it) }

        baseHeaders.forEach { (k, v) -> header(k, v) }

        val missing = { k: String, v: String -> 
            if (!baseHeaders.keys.any { it.equals(k, ignoreCase = true) }) header(k, v) 
        }

        missing("Origin", ORIGIN)
        missing("Referer", "$ORIGIN/")
        missing("X-Origin", ORIGIN)
        val resolvedClientName = WEB_REMIX_CLIENT_NAME_NUMERIC
        val resolvedClientVersion = clientVersion
        val resolvedBootstrap = "false"
        missing("X-YouTube-Client-Name", resolvedClientName)
        missing("X-Youtube-Client-Name", resolvedClientName)
        missing("X-YouTube-Client-Version", resolvedClientVersion)
        missing("X-Youtube-Client-Version", resolvedClientVersion)
        missing("X-Goog-Api-Format-Version", "2")
        missing("X-YouTube-Time-Zone", resolvedTimeZone)
        missing("X-Youtube-Time-Zone", resolvedTimeZone)
        missing("X-YouTube-Utc-Offset", resolvedUtcOffset.toString())
        missing("X-Youtube-Utc-Offset", resolvedUtcOffset.toString())
        missing("X-YouTube-Device", WEB_REMIX_DEVICE)
        missing("X-Youtube-Device", WEB_REMIX_DEVICE)
        missing("X-YouTube-Bootstrap-Logged-In", resolvedBootstrap)
        missing("X-Youtube-Bootstrap-Logged-In", resolvedBootstrap)
        missing("X-Client-Data", WEB_REMIX_CLIENT_DATA)
        missing("X-Goog-PageCl", WEB_REMIX_PAGE_CL)
        missing("X-Youtube-Page-Cl", WEB_REMIX_PAGE_CL)
        missing("X-Goog-PageLabel", WEB_REMIX_PAGE_LABEL)
        missing("X-Youtube-Page-Label", WEB_REMIX_PAGE_LABEL)
        
        // Auth specific headers
        authUser?.let { missing("X-Goog-AuthUser", it) }
        pageId?.let { 
            missing("X-Goog-PageId", it)
            missing("X-Youtube-Page-Id", it)
        }
        idToken?.let { missing("X-YouTube-Identity-Token", it) }
        currentSapisidHash()?.let { header("Authorization", it) }
        
        missing("X-YouTube-Ad-Signals", buildAdSignals(resolvedUtcOffset))
        
        parameter("key", WEB_REMIX_API_KEY)
        parameter("prettyPrint", false)
    }

    private fun webRemixContext(): IntermusicContext {
        val (timeZoneId, utcOffsetRaw) = currentTimeZoneInfo()
        val resolvedTimeZone = timeZoneId.takeUnless { it.isBlank() } ?: WEB_REMIX_TIME_ZONE
        val resolvedOffset = utcOffsetRaw.takeIf { it in -720..840 } ?: WEB_REMIX_UTC_OFFSET
        return IntermusicContext(
            client = IntermusicContext.Client(
                clientName = "WEB_REMIX",
                clientVersion = clientVersion,
                gl = locale.gl.ifBlank { WEB_REMIX_GL },
                hl = locale.hl.ifBlank { WEB_REMIX_HL },
                visitorData = visitorData,
                userAgent = "$userAgent,gzip(gfe)",
                osName = "Windows",
                osVersion = "10.0",
                platform = "DESKTOP",
                clientFormFactor = "UNKNOWN_FORM_FACTOR",
                originalUrl = "$ORIGIN/",
                timeZone = resolvedTimeZone,
                utcOffsetMinutes = resolvedOffset,
                acceptLanguage = acceptLanguageHeader(),
                userInterfaceTheme = "USER_INTERFACE_THEME_LIGHT",
            )
        )
    }

    private suspend fun webPost(endpoint: String, bodyBuilder: () -> Any): HttpResponse {
        ensureVisitorInitialized()
        val payload = bodyBuilder()
        val response = http.post(endpoint) {
            webRemixHeaders(this)
            setBody(payload)
        }
        logHttpRequest(endpoint, payload, response)
        return response
    }
    private fun buildAdSignals(utcOffsetMinutes: Int): String {
        val dt = System.currentTimeMillis()
        val base = "dt=$dt&flash=0&frm&u_tz=$utcOffsetMinutes&u_h=768&u_w=1366&u_ah=728&u_aw=1366&u_cd=24&bc=31&bih=641&biw=1351&brdim=0%2C0%2C0%2C0%2C1366%2C0%2C1366%2C728%2C1366%2C641&vis=2&wgl=true&ca_type=image"
        return "$base&bid=ANyPxKq78mWn_leavSAftaAJhG8bm6Gk_Jyo90ykjYqU5vKJGWyUf0q-0bOqa6IuQqjEcOTg_ZxC"
    }

    private fun oculusContext(): IntermusicContext = IntermusicContext(
        client = IntermusicContext.Client(
            clientName = "Android_VR",
            clientVersion = OCULUS_VERSION,
            androidSdkVersion = 32,
            gl = locale.gl.ifBlank { "US" },
            hl = locale.hl.ifBlank { "es" },
            visitorData = visitorData,
            userAgent = OCULUS_UA,
            deviceMake = "Oculus",
            deviceModel = "Quest 3",
            osName = "Android",
            osVersion = "12",
        )
    )

    suspend fun player(videoId: String): PlayerResponse = playerOculus(videoId)
    suspend fun playerOculus(videoId: String): PlayerResponse {
        ensureVisitorInitialized()
        val body = PlayerBody(
            context = oculusContext(),
            videoId = videoId,
            cpn = genCpn(),
            contentCheckOk = true,
            racyCheckOk = true,
        )
        val resp = http.post("https://youtubei.googleapis.com/youtubei/v1/player") {
            contentType(ContentType.Application.Json)
            userAgent(OCULUS_UA)
            computedBaselineHeaders().forEach { (k, v) -> header(k, v) }
            header("X-YouTube-Client-Name", OCULUS_CLIENT_NAME_NUMERIC)
            header("X-YouTube-Client-Version", OCULUS_VERSION)
            header("X-GOOG-API-FORMAT-VERSION", "2")
            visitorData?.let { header("X-Goog-Visitor-Id", it) }
            parameter("prettyPrint", false)
            setBody(body)
        }
        return resp.body()
    }
    
    suspend fun browse(browseId: String? = null, params: String? = null, continuation: String? = null): HttpResponse =
        webPost("browse") {
            BrowseBody(
                context = webRemixContext(),
                browseId = browseId,
                params = params,
                continuation = continuation,
            )
        }

    suspend fun search(query: String, params: String? = null): HttpResponse = webPost("search") {
        SearchBody(
            context = webRemixContext(),
            query = query,
            params = params,
        )
    }

    suspend fun searchSuggestions(input: String): HttpResponse = webPost("music/get_search_suggestions") {
        SearchSuggestionsBody(
            context = webRemixContext(),
            input = input,
        )
    }

    suspend fun next(
        videoId: String? = null,
        playlistId: String? = null,
        playlistSetVideoId: String? = null,
        index: Int? = null,
        params: String? = null,
        continuation: String? = null,
    ): HttpResponse = webPost("next") {
        NextBody(
            context = webRemixContext(),
            videoId = videoId,
            playlistId = playlistId,
            playlistSetVideoId = playlistSetVideoId,
            index = index,
            params = params,
            continuation = continuation,
        )
    }

    suspend fun accountMenu(): HttpResponse = webPost("account/account_menu") {
        AccountMenuBody(context = webRemixContext())
    }

    suspend fun getLibraryPlaylists() = browse(browseId = "FEmusic_liked_playlists")
    suspend fun getLikedSongs() = browse(browseId = "FEmusic_liked_videos")
    suspend fun getHistory() = browse(browseId = "FEmusic_history")

    suspend fun addToLiked(videoId: String): HttpResponse = webPost("like/like") {
        LikeBody(context = webRemixContext(), target = LikeBody.Target(videoId))
    }

    suspend fun removeFromLiked(videoId: String): HttpResponse = webPost("like/removelike") {
        LikeBody(context = webRemixContext(), target = LikeBody.Target(videoId))
    }

    suspend fun createPlaylist(
        title: String,
        description: String? = null,
        privacyStatus: String = "PRIVATE",
        videoIds: List<String>? = null,
    ): HttpResponse = webPost("playlist/create") {
        CreatePlaylistBody(
            context = webRemixContext(),
            title = title,
            description = description,
            privacyStatus = privacyStatus,
            videoIds = videoIds,
        )
    }

    suspend fun editPlaylist(
        playlistId: String,
        title: String? = null,
        description: String? = null,
        privacyStatus: String? = null,
    ): HttpResponse = webPost("browse/edit_playlist") {
        EditPlaylistBody(
            context = webRemixContext(),
            playlistId = playlistId,
            title = title,
            description = description,
            privacyStatus = privacyStatus,
        )
    }

    suspend fun addPlaylistItem(playlistId: String, videoId: String): HttpResponse = webPost("browse/edit_playlist") {
        AddPlaylistItemBody(
            context = webRemixContext(),
            playlistId = playlistId,
            actions = listOf(AddPlaylistItemBody.Action(addedVideoId = videoId)),
        )
    }

    suspend fun removePlaylistItem(playlistId: String, videoId: String, setVideoId: String? = null): HttpResponse =
        webPost("browse/edit_playlist") {
            RemovePlaylistItemBody(
                context = webRemixContext(),
                playlistId = playlistId,
                actions = listOf(RemovePlaylistItemBody.Action(removedVideoId = videoId, setVideoId = setVideoId)),
            )
        }

    fun isAuthenticationValid(): Boolean = false
    fun getAuthStatus(): Map<String, Any> = mapOf(
        "hasCookie" to false,
        "visitorData" to (visitorData != null),
        "authRequired" to false
    )

    private fun genCpn(): String {
        val chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
        return (1..16).map { chars.random() }.joinToString("")
    }

    fun close() { http.close() }

    private fun snapshotHeaders(headers: Headers): Map<String, String> = headers.entries().associate { (key, values) ->
        key to values.joinToString(separator = "; ")
    }

    private fun encodePayload(payload: Any): String = when (payload) {
        is AccountMenuBody -> debugJson.encodeToString(AccountMenuBody.serializer(), payload)
        is BrowseBody -> debugJson.encodeToString(BrowseBody.serializer(), payload)
        is SearchBody -> debugJson.encodeToString(SearchBody.serializer(), payload)
        is SearchSuggestionsBody -> debugJson.encodeToString(SearchSuggestionsBody.serializer(), payload)
        is NextBody -> debugJson.encodeToString(NextBody.serializer(), payload)
        is LikeBody -> debugJson.encodeToString(LikeBody.serializer(), payload)
        is CreatePlaylistBody -> debugJson.encodeToString(CreatePlaylistBody.serializer(), payload)
        is EditPlaylistBody -> debugJson.encodeToString(EditPlaylistBody.serializer(), payload)
        is AddPlaylistItemBody -> debugJson.encodeToString(AddPlaylistItemBody.serializer(), payload)
        is RemovePlaylistItemBody -> debugJson.encodeToString(RemovePlaylistItemBody.serializer(), payload)
        else -> payload.toString()
    }

    private fun logHttpRequest(endpoint: String, payload: Any, response: HttpResponse) {
        val request = response.call.request
        val data = linkedMapOf<String, Any?>(
            "method" to request.method.value,
            "url" to request.url.toString(),
            "endpoint" to endpoint,
            "status" to response.status.value,
            "headers" to snapshotHeaders(request.headers),
            "body" to encodePayload(payload)
        )
        debugTracer.log("IntermusicAPI", "HTTP Request Sent", data)
    }
}
