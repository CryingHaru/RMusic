package com.rmusic.providers.ytmusic.auth

import com.rmusic.providers.ytmusic.YTMusicAPI
import com.rmusic.providers.ytmusic.models.account.AccountInfo
import com.rmusic.providers.ytmusic.models.account.AuthenticationState
import com.rmusic.providers.ytmusic.models.account.LibraryPlaylist
import com.rmusic.providers.ytmusic.models.account.LikedSongsInfo
import com.rmusic.providers.ytmusic.models.account.LoginCredentials
import com.rmusic.providers.ytmusic.models.account.LoginResult
import com.rmusic.providers.ytmusic.models.account.SessionData
import com.rmusic.providers.ytmusic.models.account.TokenRefreshResult
import com.rmusic.providers.ytmusic.models.response.AccountMenuResponse
import com.rmusic.providers.ytmusic.models.response.LibraryResponse
import com.rmusic.providers.ytmusic.parser.parseLibraryPlaylists
import com.rmusic.providers.ytmusic.utils.CookieManager
import com.rmusic.providers.ytmusic.utils.PoTokenManager
import com.rmusic.providers.ytmusic.utils.SapisidHashGenerator
import io.ktor.client.call.body
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

class YTMusicAuthService(
    private val api: YTMusicAPI = YTMusicAPI()
) {
    private val authMutex = Mutex()
    private val cookieManager = CookieManager()
    private val poTokenManager = PoTokenManager()
    private val sapisidHashGenerator = SapisidHashGenerator()

    // Solo necesitamos la cookie identificadora (SAPISID o __Secure-3PAPISID)
    private fun cookieDiagnostics(cookieMap: Map<String,String>): Pair<List<String>, List<String>> {
        val missingRequired = if (cookieMap.containsKey("SAPISID") || cookieMap.containsKey("__Secure-3PAPISID")) emptyList() else listOf("SAPISID|__Secure-3PAPISID")
        return missingRequired to emptyList()
    }
    
    private val _authState = MutableStateFlow(AuthenticationState())
    val authState: StateFlow<AuthenticationState> = _authState.asStateFlow()
    
    private var currentAccount: AccountInfo? = null

    suspend fun login(credentials: LoginCredentials): Result<LoginResult> = runCatching {
        authMutex.withLock {
            
            val cookieMap = cookieManager.parseCookies(credentials.cookie)
            val sapisid = cookieMap["SAPISID"] ?: cookieMap["__Secure-3PAPISID"]
                ?: throw Exception("Falta SAPISID o __Secure-3PAPISID")

            
            api.cookie = credentials.cookie

            
            if (credentials.visitorData != null) {
                api.visitorData = credentials.visitorData
            } else if (api.visitorData == null) {
                
                
            }

            
            val sapisidHash = credentials.sapisidHash ?: sapisidHashGenerator.generate(sapisid)
            val authorization = credentials.authorization ?: buildAuthorizationHeader(sapisidHash)
            val xGoogAuthUser = credentials.xGoogAuthUser ?: "0"
            
            
            val poToken = credentials.poToken 
                ?: initializePoToken(credentials.visitorData ?: api.visitorData)

            
            
            
            _authState.value = AuthenticationState(
                isLoggedIn = false,
                credentials = credentials.copy(
                    poToken = poToken,
                    sapisidHash = sapisidHash,
                    authorization = authorization,
                    xGoogAuthUser = xGoogAuthUser,
                ),
                sessionData = SessionData(
                    visitorData = api.visitorData ?: "",
                    dataSyncId = credentials.dataSyncId,
                    poToken = poToken,
                    poTokenExpiry = System.currentTimeMillis() + (3600 * 1000),
                    sapisidHash = sapisidHash,
                    sessionId = generateSessionId(),
                    authorization = authorization,
                    xGoogAuthUser = xGoogAuthUser,
                    xGoogVisitorId = credentials.xGoogVisitorId,
                    clientHints = credentials.clientHints,
                    extraHeaders = credentials.extraHeaders,
                ),
                lastRefresh = System.currentTimeMillis(),
                tokenExpiry = System.currentTimeMillis() + (3600 * 1000)
            )

            
            val accountResult = getAccountInfo()
            
            if (accountResult.isSuccess) {
                val accountInfo = accountResult.getOrNull()
                if (accountInfo != null) {
                    currentAccount = accountInfo
                    
                    
                    val sessionData = SessionData(
                        visitorData = api.visitorData ?: "",
                        dataSyncId = credentials.dataSyncId,
                        poToken = poToken,
                        poTokenExpiry = System.currentTimeMillis() + (3600 * 1000), 
                        sapisidHash = sapisidHash,
                        sessionId = generateSessionId(),
                        authorization = _authState.value.sessionData?.authorization ?: buildAuthorizationHeader(sapisidHash),
                        xGoogAuthUser = credentials.xGoogAuthUser ?: "0",
                        xGoogVisitorId = credentials.xGoogVisitorId,
                        clientHints = credentials.clientHints,
                        extraHeaders = credentials.extraHeaders,
                    )
                    
                    
                    _authState.value = AuthenticationState(
                        isLoggedIn = true,
                        credentials = credentials.copy(
                            poToken = poToken,
                            sapisidHash = sapisidHash,
                            authorization = _authState.value.credentials?.authorization ?: authorization,
                            xGoogAuthUser = xGoogAuthUser,
                        ),
                        sessionData = sessionData,
                        lastRefresh = System.currentTimeMillis(),
                        tokenExpiry = sessionData.poTokenExpiry ?: 0L
                    )
                    
                    LoginResult(
                        success = true,
                        accountInfo = accountInfo,
                        sessionData = sessionData
                    )
                } else {
                    LoginResult(success = false, error = "No se pudo obtener la cuenta")
                }
            } else {
                LoginResult(
                    success = false,
                    error = accountResult.exceptionOrNull()?.message ?: "Login failed"
                )
            }
        }
    }

    
    fun logout() {
        api.cookie = null
        api.visitorData = null
        currentAccount = null
    poTokenManager.clearTokens()
        cookieManager.clearCookies()
        
        _authState.value = AuthenticationState()
    }

    
    fun isLoggedIn(): Boolean {
        val authState = _authState.value
        return authState.isLoggedIn && 
               currentAccount != null && 
               !isSessionExpired(authState)
    }

    
    suspend fun refreshTokensIfNeeded(): Result<TokenRefreshResult> = runCatching {
        authMutex.withLock {
            val currentState = _authState.value
            
            if (!currentState.isLoggedIn || currentState.credentials == null) {
                throw Exception("Not logged in")
            }
            
            val now = System.currentTimeMillis()
            val shouldRefresh = now >= currentState.tokenExpiry - (10 * 60 * 1000) 
            
            if (!shouldRefresh) {
                return@runCatching TokenRefreshResult(success = true)
            }
            
            
            val newPoToken = poTokenManager.refreshPoToken(
                currentState.sessionData?.sessionId ?: generateSessionId(),
                currentState.sessionData?.visitorData ?: api.visitorData ?: ""
            )
            
            
            val cookieMap = cookieManager.parseCookies(currentState.credentials.cookie)
            val sapisid = cookieMap["SAPISID"] ?: cookieMap["__Secure-3PAPISID"]
                ?: throw Exception("Missing SAPISID for refresh")
            val newSapisidHash = sapisidHashGenerator.generate(sapisid)
            
            val newExpiryTime = now + (3600 * 1000) 
            
            
            val updatedSessionData = currentState.sessionData?.copy(
                poToken = newPoToken,
                poTokenExpiry = newExpiryTime,
                sapisidHash = newSapisidHash,
                authorization = currentState.sessionData.authorization ?: buildAuthorizationHeader(newSapisidHash),
            )
            
            
            _authState.value = currentState.copy(
                credentials = currentState.credentials.copy(
                    poToken = newPoToken,
                    sapisidHash = newSapisidHash,
                    authorization = currentState.credentials.authorization ?: buildAuthorizationHeader(newSapisidHash),
                ),
                sessionData = updatedSessionData,
                lastRefresh = now,
                tokenExpiry = newExpiryTime
            )
            
            TokenRefreshResult(
                success = true,
                newPoToken = newPoToken,
                newSapisidHash = newSapisidHash,
                expiryTime = newExpiryTime
            )
        }
    }

    
    private fun buildAuthorizationHeader(sapisidHash: String?): String? = sapisidHash?.let { "SAPISIDHASH $it" }

    
    // Eliminado: cabeceras compuestas no necesarias para el flujo minimal
    private fun buildCompositeAuthorization(sapisidHash: String): String = "SAPISIDHASH $sapisidHash"

    
    fun buildRequestHeaders(): Map<String,String> {
        val s = _authState.value
        val session = s.sessionData
        val creds = s.credentials
        val map = mutableMapOf<String,String>()
        creds?.cookie?.let { map["cookie"] = it }
        session?.authorization?.let { map["authorization"] = it }
        session?.xGoogAuthUser?.let { map["x-goog-authuser"] = it }
        session?.xGoogVisitorId?.let { map["x-goog-visitor-id"] = it }
        session?.clientHints?.let { map += it }
        session?.extraHeaders?.let { map += it }
        return map
    }

    
    suspend fun getAccountInfo(): Result<AccountInfo?> = runCatching {
        
        
        
        if (_authState.value.isLoggedIn) {
            refreshTokensIfNeeded()
        }
        
        val response = api.accountMenu().body<AccountMenuResponse>()
        var header = response.actions.firstOrNull()
            ?.openPopupAction?.popup?.multiPageMenuRenderer?.header
            ?.activeAccountHeaderRenderer

        
        if (header == null) {
            runCatching {
                val webResp = api.accountMenuWebRemix().body<AccountMenuResponse>()
                header = webResp.actions.firstOrNull()
                    ?.openPopupAction?.popup?.multiPageMenuRenderer?.header
                    ?.activeAccountHeaderRenderer
            }
        }

        if (header != null) {
            val thumbs = header.accountPhoto?.thumbnails
                ?.map { com.rmusic.providers.ytmusic.pages.Thumbnail(url = it.url, width = it.width, height = it.height) }
                ?: emptyList()

            AccountInfo(
                name = header.accountName?.runs?.firstOrNull()?.text ?: "",
                email = header.channelHandle?.runs?.firstOrNull()?.text ?: "",
                channelId = header.channelId ?: "",
                thumbnails = thumbs
            )
        } else {
            null
        }
    }

    
    suspend fun getLibraryPlaylists(): Result<List<LibraryPlaylist>> = runCatching {
        if (!isLoggedIn()) throw Exception("Not logged in or session expired")
        
        refreshTokensIfNeeded()
        val response = api.getLibraryPlaylists().body<LibraryResponse>()
        parseLibraryPlaylists(response)
    }

    
    suspend fun getLikedSongsInfo(): Result<LikedSongsInfo> = runCatching {
        if (!isLoggedIn()) throw Exception("Not logged in or session expired")
        
        refreshTokensIfNeeded()
        val response = api.getLikedSongs().body<LibraryResponse>()
        
        
        val trackCount = response.header?.musicHeaderRenderer?.subtitle?.runs
            ?.find { it.text.contains("song", ignoreCase = true) }
            ?.text?.filter { it.isDigit() }?.toIntOrNull() ?: 0
            
        LikedSongsInfo(trackCount = trackCount)
    }

    
    suspend fun addToLiked(videoId: String): Result<Boolean> = runCatching {
        if (!isLoggedIn()) throw Exception("Not logged in or session expired")
        
        refreshTokensIfNeeded()
        val response = api.addToLiked(videoId)
        response.status.value in 200..299
    }

    
    suspend fun removeFromLiked(videoId: String): Result<Boolean> = runCatching {
        if (!isLoggedIn()) throw Exception("Not logged in or session expired")
        
        refreshTokensIfNeeded()
        val response = api.removeFromLiked(videoId)
        response.status.value in 200..299
    }

    
    suspend fun createPlaylist(
        title: String,
        description: String? = null,
        isPrivate: Boolean = true,
        videoIds: List<String>? = null
    ): Result<String> = runCatching {
        if (!isLoggedIn()) throw Exception("Not logged in or session expired")
        
        refreshTokensIfNeeded()
        val privacyStatus = if (isPrivate) "PRIVATE" else "PUBLIC"
        val response = api.createPlaylist(
            title = title,
            description = description,
            privacyStatus = privacyStatus,
            videoIds = videoIds
        )
        
        
        
        "playlist_id_placeholder"
    }

    
    suspend fun addToPlaylist(playlistId: String, videoId: String): Result<Boolean> = runCatching {
        if (!isLoggedIn()) throw Exception("Not logged in or session expired")
        
        refreshTokensIfNeeded()
        val response = api.addPlaylistItem(playlistId, videoId)
        response.status.value in 200..299
    }

    
    suspend fun removeFromPlaylist(
        playlistId: String, 
        videoId: String, 
        setVideoId: String? = null
    ): Result<Boolean> = runCatching {
        if (!isLoggedIn()) throw Exception("Not logged in or session expired")
        
        refreshTokensIfNeeded()
        val response = api.removePlaylistItem(playlistId, videoId, setVideoId)
        response.status.value in 200..299
    }

    
    suspend fun getWatchHistory(): Result<List<LibraryPlaylist>> = runCatching {
        if (!isLoggedIn()) throw Exception("Not logged in or session expired")
        
        refreshTokensIfNeeded()
        val response = api.getHistory().body<LibraryResponse>()
        parseLibraryPlaylists(response)
    }

    
    suspend fun validateSession(): Result<Boolean> = runCatching {
        val accountInfo = getAccountInfo().getOrNull()
        accountInfo != null
    }

    
    fun getLibraryPlaylistsFlow(): Flow<List<LibraryPlaylist>> = flow {
        getLibraryPlaylists().onSuccess { emit(it) }
    }

    
    fun getCurrentAccountFlow(): Flow<AccountInfo?> = flow {
        if (isLoggedIn()) {
            emit(currentAccount)
        } else {
            emit(null)
        }
    }

    
    fun getAuthStateFlow(): Flow<AuthenticationState> = authState

    
    private suspend fun initializePoToken(visitorData: String?): String? {
        return try {
            poTokenManager.generatePoToken(
                sessionId = generateSessionId(),
                visitorData = visitorData ?: ""
            )
        } catch (e: Exception) {
            null
        }
    }

    
    private fun generateSessionId(): String {
        return "session_${System.currentTimeMillis()}_${(1000..9999).random()}"
    }

    
    private fun isSessionExpired(authState: AuthenticationState): Boolean {
        val now = System.currentTimeMillis()
        return now >= authState.tokenExpiry
    }

    
    fun getAdvancedLoginInstructions(): String {
        return """
            Enhanced YTMusic Authentication Instructions:
            
            1. Open YouTube Music in your web browser (Chrome/Firefox recommended)
            2. Login to your account and ensure you're fully authenticated
            3. Open Developer Tools (F12)
            4. Go to Application/Storage tab → Cookies → https://music.youtube.com
            5. Copy only one account identifier cookie as: SAPISID=... OR __Secure-3PAPISID=...
            
            Required (choose one):
            - SAPISID (preferred) OR __Secure-3PAPISID
            
            Notes:
            - Other cookies (VISITOR_INFO1_LIVE, YSC, SESSION_TOKEN) are optional.
            - We'll derive headers (SAPISIDHASH) from the provided cookie.
            
            Security Notes:
            - Cookies are sensitive data - keep them secure
            - Tokens automatically refresh every hour
            - Session validation prevents unauthorized access
            - Full MScrapper-level authentication compatibility
        """.trimIndent()
    }

    fun exportSessionData(): Result<AuthenticationState> = runCatching {
        val currentState = _authState.value
        if (!currentState.isLoggedIn) {
            throw Exception("No active session to export")
        }
        currentState
    }

    suspend fun importSessionData(sessionState: AuthenticationState): Result<Boolean> = runCatching {
        authMutex.withLock {
            if (sessionState.credentials == null) {
                throw Exception("Invalid session data")
            }
            
            
            api.cookie = sessionState.credentials.cookie
            sessionState.sessionData?.visitorData?.let { api.visitorData = it }
            
            
            val accountResult = getAccountInfo()
            if (accountResult.isSuccess && accountResult.getOrNull() != null) {
                currentAccount = accountResult.getOrNull()
                _authState.value = sessionState
                true
            } else {
                throw Exception("Invalid or expired session data")
            }
        }
    }

    fun close() {
        api.close()
    // nothing to close in PoTokenManager
    }
}
