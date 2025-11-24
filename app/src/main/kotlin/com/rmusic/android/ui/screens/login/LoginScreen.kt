package com.rmusic.android.ui.screens.login

import android.annotation.SuppressLint
import android.net.Uri
import android.webkit.CookieManager
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.viewinterop.AndroidView
import com.rmusic.android.R
import com.rmusic.android.ui.screens.Route
import com.rmusic.providers.intermusic.IntermusicProvider

@OptIn(ExperimentalMaterial3Api::class)
@Composable
@Route
fun LoginScreen(
    onLoginSuccess: (String, String, String?, String?) -> Unit
) {
    var currentUrl by remember { mutableStateOf("https://music.youtube.com") }
    var webView: WebView? by remember { mutableStateOf(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Login to YouTube Music") }
            )
        },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                onClick = {
                    webView?.evaluateJavascript(
                        """
                        (function() {
                            try {
                                var idx = ytcfg.get('SESSION_INDEX');
                                var pid = ytcfg.get('DELEGATED_SESSION_ID');
                                var idt = ytcfg.get('ID_TOKEN');
                                return JSON.stringify({
                                    idx: (idx !== undefined && idx !== null) ? idx : "0",
                                    pid: (pid !== undefined && pid !== null) ? pid : null,
                                    idt: (idt !== undefined && idt !== null) ? idt : null
                                });
                            } catch (e) {
                                return JSON.stringify({ idx: "0", pid: null, idt: null });
                            }
                        })();
                        """.trimIndent()
                    ) { result ->
                        try {
                            val jsonStr = result.removePrefix("\"").removeSuffix("\"").replace("\\\"", "\"")
                            val json = org.json.JSONObject(jsonStr)
                            val authUser = json.optString("idx", "0")
                            val pageId = if (json.isNull("pid")) null else json.optString("pid")
                            val idToken = if (json.isNull("idt")) null else json.optString("idt")
                            
                            val url = webView?.url ?: currentUrl
                            val cookies = CookieManager.getInstance().getCookie(url)
                            if (cookies != null && cookies.contains("SAPISID")) {
                                onLoginSuccess(cookies, authUser, pageId, idToken)
                            }
                        } catch (e: Exception) {
                            e.printStackTrace()
                            val url = webView?.url ?: currentUrl
                            val cookies = CookieManager.getInstance().getCookie(url)
                            if (cookies != null && cookies.contains("SAPISID")) {
                                onLoginSuccess(cookies, "0", null, null)
                            }
                        }
                    }
                },
                icon = { Icon(painterResource(R.drawable.check), contentDescription = null) },
                text = { Text("Done") }
            )
        }
    ) { paddingValues ->
        LoginWebView(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            onUrlChange = { currentUrl = it },
            onWebViewCreated = { webView = it }
        )
    }
}

@SuppressLint("SetJavaScriptEnabled")
@Composable
fun LoginWebView(
    modifier: Modifier = Modifier,
    onUrlChange: (String) -> Unit,
    onWebViewCreated: (WebView) -> Unit
) {
    AndroidView(
        modifier = modifier,
        factory = { context ->
            WebView(context).apply {
                onWebViewCreated(this)
                settings.javaScriptEnabled = true
                settings.domStorageEnabled = true
                webViewClient = object : WebViewClient() {
                    override fun onPageFinished(view: WebView?, url: String?) {
                        super.onPageFinished(view, url)
                        url?.let { onUrlChange(it) }
                    }
                }
                loadUrl("https://music.youtube.com")
            }
        }
    )
}
