package com.rmusic.android.ui.screens.settings

import android.content.Context
import android.webkit.CookieManager
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.rmusic.android.R
import com.rmusic.android.utils.toast
import com.rmusic.providers.intermusic.IntermusicProvider
import com.rmusic.providers.intermusic.models.account.AuthenticationState
import com.rmusic.providers.intermusic.models.account.LoginCredentials
import com.rmusic.android.ui.screens.settings.SettingsCategoryScreen
import com.rmusic.android.ui.screens.Route
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json

private const val PREFS_INTERMUSIC_AUTH = "intermusic_auth"
private const val LEGACY_PREFS_YTMUSIC_AUTH = "ytmusic_auth"
private const val KEY_SESSION_STATE = "session_state"

private fun migrateLegacyAuthState(context: Context) {
    val legacyPrefs = context.getSharedPreferences(LEGACY_PREFS_YTMUSIC_AUTH, Context.MODE_PRIVATE)
    val legacyState = legacyPrefs.getString(KEY_SESSION_STATE, null) ?: return
    val newPrefs = context.getSharedPreferences(PREFS_INTERMUSIC_AUTH, Context.MODE_PRIVATE)
    if (newPrefs.contains(KEY_SESSION_STATE)) return
    newPrefs.edit().putString(KEY_SESSION_STATE, legacyState).apply()
    legacyPrefs.edit().remove(KEY_SESSION_STATE).apply()
}

private fun clearLegacyAuthState(context: Context) {
    context.getSharedPreferences(LEGACY_PREFS_YTMUSIC_AUTH, Context.MODE_PRIVATE)
        .edit()
        .remove(KEY_SESSION_STATE)
        .apply()
}

@Route
@Composable
fun IntermusicAuthScreen() {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    
    var isLoading by remember { mutableStateOf(false) }
    var showWebView by remember { mutableStateOf(false) }
    var authStatus by remember { mutableStateOf(context.getString(R.string.not_authenticated)) }
    var isAuthenticated by remember { mutableStateOf(false) }

    // Shared provider (keeps auth in memory across screens)
    val intermusicProvider = remember { IntermusicProvider.shared() }
    // Simple persistence using SharedPreferences
    val prefs = remember { context.getSharedPreferences(PREFS_INTERMUSIC_AUTH, Context.MODE_PRIVATE) }
    val json = remember { Json { ignoreUnknownKeys = true } }

    // Check authentication status on first load
    LaunchedEffect(Unit) {
        try {
            isLoading = true
            migrateLegacyAuthState(context)

            // Restore session if not already logged in
            if (!intermusicProvider.isLoggedIn()) {
                prefs.getString(KEY_SESSION_STATE, null)?.let { raw ->
                    runCatching { json.decodeFromString(AuthenticationState.serializer(), raw) }
                        .getOrNull()?.let { saved ->
                            intermusicProvider.importSessionData(saved)
                        }
                }
            }
            val isLoggedIn = intermusicProvider.isLoggedIn()
            if (isLoggedIn) {
                val accountInfo = intermusicProvider.getAccountInfo().getOrNull()
                if (accountInfo != null) {
                    isAuthenticated = true
                    authStatus = context.getString(R.string.authenticated_as, accountInfo.name)
                } else {
                    authStatus = context.getString(R.string.not_authenticated)
                }
            } else {
                authStatus = context.getString(R.string.not_authenticated)
            }
        } catch (e: Exception) {
            authStatus = context.getString(R.string.not_authenticated)
        } finally {
            isLoading = false
        }
    }

    Box(Modifier.fillMaxSize()) {
    SettingsCategoryScreen(title = stringResource(R.string.intermusic_authentication)) {

            // Status Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = if (isAuthenticated) 
                        MaterialTheme.colorScheme.primaryContainer 
                    else 
                        MaterialTheme.colorScheme.errorContainer
                )
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                ) {
                    Text(
                        text = stringResource(R.string.authentication_status),
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Medium
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = authStatus,
                        style = MaterialTheme.typography.bodyMedium,
                        color = if (isAuthenticated) 
                            MaterialTheme.colorScheme.onPrimaryContainer 
                        else 
                            MaterialTheme.colorScheme.onErrorContainer
                    )
                }
            }

            // Instructions Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                ) {
                    Text(
                        text = stringResource(R.string.auth_instructions),
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Medium
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = stringResource(R.string.auth_instructions_text),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            // Action Buttons
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Button(
                    onClick = {
                        showWebView = true
                        isLoading = true
                    },
                    enabled = !isLoading && !showWebView,
                    modifier = Modifier.weight(1f)
                ) {
                    if (isLoading) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(16.dp),
                            strokeWidth = 2.dp,
                            color = MaterialTheme.colorScheme.onPrimary
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                    }
                    Text(if (isAuthenticated) stringResource(R.string.re_authenticate) else stringResource(R.string.start_authentication))
                }
                
                if (isAuthenticated) {
                    OutlinedButton(
                        onClick = {
                            scope.launch {
                                intermusicProvider.logout()
                                prefs.edit().remove(KEY_SESSION_STATE).apply()
                                clearLegacyAuthState(context)
                                isAuthenticated = false
                                authStatus = context.getString(R.string.session_closed)
                                context.toast(context.getString(R.string.session_closed_successfully))
                            }
                        },
                        enabled = !isLoading
                    ) { Text(stringResource(R.string.logout)) }
                }
            }

        }
        // Full-screen overlay WebView (ensures visible height)
        if (showWebView) {
            Surface(
                modifier = Modifier.fillMaxSize(),
                color = MaterialTheme.colorScheme.background.copy(alpha = 0.98f)
            ) {
                Column(Modifier.fillMaxSize().padding(8.dp)) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = stringResource(R.string.intermusic_auth),
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Medium
                        )
                        OutlinedButton(onClick = {
                            showWebView = false
                            isLoading = false
                        }) { Text(stringResource(id = android.R.string.cancel)) }
                    }
                    Card(
                        modifier = Modifier
                            .fillMaxSize(),
                        elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
                    ) {
                        IntermusicWebView(
                            onCookiesObtained = { cookies ->
                                scope.launch {
                                    try {
                                        // Filtrar solo la cookie mínima necesaria
                                        val minimalCookie = extractMinimalCookie(cookies)
                                        val credentials = LoginCredentials(cookie = minimalCookie)
                                        val loginResult = intermusicProvider.login(credentials)
                                        loginResult.onSuccess { result ->
                                            if (result.success) {
                                                isAuthenticated = true
                                                authStatus = context.getString(R.string.authenticated_as, result.accountInfo?.name ?: "User")
                                                context.toast(context.getString(R.string.authentication_successful))
                                                // Persist session
                                                intermusicProvider.exportSessionData().onSuccess { state ->
                                                    prefs.edit().putString(KEY_SESSION_STATE, json.encodeToString(AuthenticationState.serializer(), state)).apply()
                                                    clearLegacyAuthState(context)
                                                }
                                            } else {
                                                authStatus = context.getString(R.string.authentication_error, result.error ?: "Unknown")
                                                context.toast(context.getString(R.string.authentication_error, result.error ?: "Unknown"))
                                            }
                                        }.onFailure { exception ->
                                            authStatus = context.getString(R.string.authentication_error, exception.message ?: "Unknown")
                                            context.toast(context.getString(R.string.unexpected_error, exception.message ?: "Unknown"))
                                        }
                                    } catch (e: Exception) {
                                        authStatus = context.getString(R.string.unexpected_error, e.message ?: "Unknown")
                                        context.toast(context.getString(R.string.unexpected_error, e.message ?: "Unknown"))
                                    } finally {
                                        showWebView = false
                                        isLoading = false
                                    }
                                }
                            },
                            onError = { error ->
                                authStatus = context.getString(R.string.webview_error, error)
                                context.toast(context.getString(R.string.webview_error, error))
                                showWebView = false
                                isLoading = false
                            }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun IntermusicWebView(
    onCookiesObtained: (String) -> Unit,
    onError: (String) -> Unit
) {
    AndroidView(
        factory = { context ->
            WebView(context).apply {
                settings.javaScriptEnabled = true
                settings.domStorageEnabled = true
                settings.databaseEnabled = true
                settings.setSupportZoom(true)
                settings.builtInZoomControls = true
                settings.displayZoomControls = false
                settings.useWideViewPort = true
                settings.loadWithOverviewMode = true
                
                // Clear any existing cookies
                CookieManager.getInstance().removeAllCookies(null)
                CookieManager.getInstance().flush()
                
                webViewClient = object : WebViewClient() {
                    override fun onPageFinished(view: WebView?, url: String?) {
                        super.onPageFinished(view, url)
                        
                        // Check if we're on YouTube Music and user is logged in
                        if (url?.contains("music.youtube.com") == true) {
                            // Wait a bit for cookies to be set, then check multiple times
                            view?.postDelayed({
                                checkAndExtractCookies(view, onCookiesObtained, attempt = 1, maxAttempts = 5)
                            }, 1000) // Start checking after 1 second
                        }
                    }
                    
                    override fun onReceivedError(
                        view: WebView?,
                        errorCode: Int,
                        description: String?,
                        failingUrl: String?
                    ) {
                        super.onReceivedError(view, errorCode, description, failingUrl)
                        onError(description ?: "Error al cargar la página")
                    }
                }
                
                // Load YouTube Music
                loadUrl("https://music.youtube.com")
            }
        },
        modifier = Modifier.fillMaxSize()
    )
}

/**
 * Helper function to check and extract cookies with multiple attempts
 */
private fun checkAndExtractCookies(
    webView: WebView,
    onCookiesObtained: (String) -> Unit,
    attempt: Int,
    maxAttempts: Int
) {
    val cookieManager = CookieManager.getInstance()
    val cookies = cookieManager.getCookie("https://music.youtube.com")
    
    if (cookies != null && cookies.isNotEmpty()) {
        val minimal = extractMinimalCookie(cookies)
        if (minimal.isNotEmpty()) {
            onCookiesObtained(minimal)
            return
        }
    }
    
    // If we haven't found the cookies yet and haven't reached max attempts, try again
    if (attempt < maxAttempts) {
        webView.postDelayed({
            checkAndExtractCookies(webView, onCookiesObtained, attempt + 1, maxAttempts)
        }, 2000) // Wait 2 seconds between attempts
    }
}

// Extrae solo SAPISID o __Secure-3PAPISID del string de cookies
private fun extractMinimalCookie(cookieHeader: String): String {
    val parts = cookieHeader.split(';')
    val wanted = listOf("SAPISID", "__Secure-3PAPISID")
    val kv = parts.mapNotNull { p ->
        val idx = p.indexOf('=')
        if (idx <= 0) null else p.substring(0, idx).trim() to p.substring(idx + 1).trim()
    }.toMap()
    val map = mutableMapOf<String, String>()
    for (k in wanted) {
        kv[k]?.let { map[k] = it }
    }
    return map.entries.joinToString("; ") { (k, v) -> "$k=$v" }
}
