@file:OptIn(UnstableApi::class)

package com.rmusic.android.utils

import android.content.Context
import android.util.Log
import androidx.annotation.OptIn
import androidx.media3.common.C
import androidx.media3.common.PlaybackException
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DataSpec
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.datasource.HttpDataSource.InvalidResponseCodeException
import androidx.media3.datasource.ResolvingDataSource
import androidx.media3.datasource.cache.Cache
import androidx.media3.datasource.cache.CacheDataSource
import androidx.media3.common.util.Assertions
import androidx.media3.datasource.DataSourceException
import androidx.media3.datasource.HttpDataSource
import androidx.media3.datasource.TransferListener
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.URL
import java.io.EOFException
import java.io.IOException
import kotlin.math.pow

class RangeHandlerDataSourceFactory(private val parent: DataSource.Factory) : DataSource.Factory {
    class Source(private val parent: DataSource) : DataSource by parent {
        override fun open(dataSpec: DataSpec) = runCatching {
            parent.open(dataSpec)
        }.getOrElse { e ->
            if (
                e.findCause<EOFException>() != null ||
                e.findCause<InvalidResponseCodeException>()?.responseCode == 416
            ) parent.open(
                dataSpec
                    .buildUpon()
                    .setHttpRequestHeaders(
                        dataSpec.httpRequestHeaders.filterKeys { it.equals("range", ignoreCase = true) }
                    )
                    .setLength(C.LENGTH_UNSET.toLong())
                    .build()
            )
            else throw e
        }
    }

    override fun createDataSource() = Source(parent.createDataSource())
}

class CatchingDataSourceFactory(
    private val parent: DataSource.Factory,
    private val onError: ((Throwable) -> Unit)?
) : DataSource.Factory {
    inner class Source(private val parent: DataSource) : DataSource by parent {
        override fun open(dataSpec: DataSpec) = runCatching {
            parent.open(dataSpec)
        }.getOrElse { ex ->
            ex.printStackTrace()

            if (ex is PlaybackException) throw ex
            else throw PlaybackException(
                /* message = */ "${ex::class.simpleName}: ${ex.localizedMessage ?: ex}",
                /* cause = */ ex,
                /* errorCode = */ PlaybackException.ERROR_CODE_UNSPECIFIED
            ).also { onError?.invoke(it) }
        }
    }

    override fun createDataSource() = Source(parent.createDataSource())
}

fun DataSource.Factory.handleRangeErrors(): DataSource.Factory = RangeHandlerDataSourceFactory(this)
fun DataSource.Factory.handleUnknownErrors(
    onError: ((Throwable) -> Unit)? = null
): DataSource.Factory = CatchingDataSourceFactory(
    parent = this,
    onError = onError
)

class FallbackDataSourceFactory(
    private val upstream: DataSource.Factory,
    private val fallback: DataSource.Factory
) : DataSource.Factory {
    inner class Source(private val parent: DataSource) : DataSource by parent {
        override fun open(dataSpec: DataSpec) = runCatching {
            parent.open(dataSpec)
        }.getOrElse { ex ->
            ex.printStackTrace()

            runCatching {
                fallback.createDataSource().open(dataSpec)
            }.getOrElse { fallbackEx ->
                fallbackEx.printStackTrace()

                throw ex
            }
        }
    }

    override fun createDataSource() = Source(upstream.createDataSource())
}

fun DataSource.Factory.withFallback(
    fallbackFactory: DataSource.Factory
): DataSource.Factory = FallbackDataSourceFactory(this, fallbackFactory)

fun DataSource.Factory.withFallback(
    context: Context,
    resolver: ResolvingDataSource.Resolver
) = withFallback(ResolvingDataSource.Factory(DefaultDataSource.Factory(context), resolver))

class RetryingDataSourceFactory(
    private val parent: DataSource.Factory,
    private val maxRetries: Int,
    private val printStackTrace: Boolean,
    private val exponential: Boolean,
    private val predicate: (Throwable) -> Boolean
) : DataSource.Factory {
    inner class Source(private val parent: DataSource) : DataSource by parent {
        override fun open(dataSpec: DataSpec): Long {
            var lastException: Throwable? = null
            var retries = 0
            while (retries < maxRetries) {
                if (retries > 0) Log.d(TAG, "Retry $retries of $maxRetries fetching datasource")

                @Suppress("TooGenericExceptionCaught")
                return try {
                    parent.open(dataSpec)
                } catch (ex: Throwable) {
                    lastException = ex
                    if (printStackTrace) Log.e(
                        /* tag = */ TAG,
                        /* msg = */ "Exception caught by retry mechanism",
                        /* tr = */ ex
                    )
                    if (predicate(ex)) {
                        val time = if (exponential) 1000L * 2.0.pow(retries).toLong() else 2500L
                        Log.d(TAG, "Retry policy accepted retry, sleeping for $time milliseconds")
                        Thread.sleep(time)
                        retries++
                        continue
                    }
                    Log.e(
                        TAG,
                        "Retry policy declined retry, throwing the last exception..."
                    )
                    throw ex
                }
            }
            Log.e(
                TAG,
                "Max retries $maxRetries exceeded, throwing the last exception..."
            )
            throw lastException!!
        }
    }

    override fun createDataSource() = Source(parent.createDataSource())
}

inline fun <reified T : Throwable> DataSource.Factory.retryIf(
    maxRetries: Int = 5,
    printStackTrace: Boolean = false,
    exponential: Boolean = true
) = retryIf(maxRetries, printStackTrace, exponential) { ex -> ex.findCause<T>() != null }

private const val TAG = "DataSource.Factory"

fun DataSource.Factory.retryIf(
    maxRetries: Int = 5,
    printStackTrace: Boolean = false,
    exponential: Boolean = true,
    predicate: (Throwable) -> Boolean
): DataSource.Factory = RetryingDataSourceFactory(this, maxRetries, printStackTrace, exponential, predicate)

val Cache.asDataSource get() = CacheDataSource.Factory().setCache(this)

val Context.defaultDataSource
    get() = DefaultDataSource.Factory(
        this,
        DefaultHttpDataSource.Factory()
            .setConnectTimeoutMs(16000)
            .setReadTimeoutMs(8000)
            // Alinear con index.js: usar UA de YouTube iOS para las descargas de medios
            .setUserAgent("com.google.ios.youtube/19.45.4 (iPhone16,2; U; CPU iOS 18_1_0 like Mac OS X; US)")
            // Algunos endpoints de googlevideo redirigen entre hosts; habilitar por si acaso
            .setAllowCrossProtocolRedirects(true)
    )

// Implementación mínima de HTTP DataSource que solo envía Range (y UA) para reducir 403
class MinimalHttpDataSource(
    private val userAgent: String,
    private val connectTimeoutMs: Int = 16000,
    private val readTimeoutMs: Int = 8000,
    private val allowCrossProtocolRedirects: Boolean = true
) : DataSource {
    private var listener: TransferListener? = null
    private var connection: HttpURLConnection? = null
    private var inputStream: InputStream? = null
    private var opened = false
    private var bytesToRead: Long = C.LENGTH_UNSET.toLong()
    private var bytesRead: Long = 0
    private var uri: android.net.Uri? = null
    // Record last DataSpec to satisfy TransferListener advanced methods
    private var lastDataSpec: DataSpec? = null

    override fun addTransferListener(transferListener: TransferListener) {
        this.listener = transferListener
    }

    override fun open(dataSpec: DataSpec): Long {
        try {
            bytesRead = 0
            bytesToRead = if (dataSpec.length != C.LENGTH_UNSET.toLong()) dataSpec.length else C.LENGTH_UNSET.toLong()
            uri = dataSpec.uri
            lastDataSpec = dataSpec

            val url = URL(dataSpec.uri.toString())
            var conn = (url.openConnection() as HttpURLConnection).apply {
                instanceFollowRedirects = allowCrossProtocolRedirects
                connectTimeout = connectTimeoutMs
                readTimeout = readTimeoutMs
                requestMethod = "GET"
                setRequestProperty("User-Agent", userAgent)
                setRequestProperty("Accept-Encoding", "identity")
                setRequestProperty("Connection", "keep-alive")
                // Respetar headers Range del DataSpec, o construirlos si no están
                val start = dataSpec.position
                if (bytesToRead != C.LENGTH_UNSET.toLong()) {
                    val end = start + bytesToRead - 1
                    setRequestProperty("Range", "bytes=$start-$end")
                } else if (start > 0) {
                    setRequestProperty("Range", "bytes=$start-")
                }
                // No añadir más headers (evitar Referer/Origin/etc.)
            }

            // Manejar redirecciones manuales si es necesario (para hosts googlevideo)
            var responseCode = conn.responseCode
            var redirectCount = 0
        while (responseCode in 300..399 && allowCrossProtocolRedirects && redirectCount < 5) {
                val location = conn.getHeaderField("Location") ?: break
                conn.disconnect()
                conn = (URL(location).openConnection() as HttpURLConnection).apply {
                    instanceFollowRedirects = allowCrossProtocolRedirects
                    connectTimeout = connectTimeoutMs
                    readTimeout = readTimeoutMs
                    requestMethod = "GET"
                    setRequestProperty("User-Agent", userAgent)
                    setRequestProperty("Accept-Encoding", "identity")
            setRequestProperty("Connection", "keep-alive")
                    val start = dataSpec.position
                    if (bytesToRead != C.LENGTH_UNSET.toLong()) {
                        val end = start + bytesToRead - 1
                        setRequestProperty("Range", "bytes=$start-$end")
                    } else if (start > 0) {
                        setRequestProperty("Range", "bytes=$start-")
                    }
                }
                responseCode = conn.responseCode
                redirectCount++
            }

            if (!(responseCode == 200 || responseCode == 206)) {
                // Build proper typed headers and non-null body as required by media3
                val headers: Map<String, List<String>> = conn.headerFields
                    ?.filterKeys { it != null }
                    ?.mapKeys { it.key!! }
                    ?: emptyMap()
                val body: ByteArray = try {
                    conn.errorStream?.readBytes() ?: ByteArray(0)
                } catch (_: Exception) { ByteArray(0) }

                // Extra debug info about the failing response
                Log.e(
                    TAG,
                    "HTTP open failed: code=${responseCode}, message='${conn.responseMessage}', url='${dataSpec.uri}', headers=${headers}, bodyPreview='${
                        body.decodeToString().take(512)
                    }'"
                )

                // Media3 1.6.1 signature: (responseCode, responseMessage, cause, headers, dataSpec, responseBody)
                throw HttpDataSource.InvalidResponseCodeException(
                    /* responseCode     = */ responseCode,
                    /* responseMessage  = */ conn.responseMessage,
                    /* cause            = */ null,
                    /* headerFields     = */ headers,
                    /* dataSpec         = */ dataSpec,
                    /* responseBody     = */ body
                )
            }

            // Determinar longitud
            if (bytesToRead == C.LENGTH_UNSET.toLong()) {
                val contentRange = conn.getHeaderField("Content-Range")
                val contentLenHeader = conn.getHeaderField("Content-Length")
                bytesToRead = when {
                    contentRange != null && contentRange.startsWith("bytes") -> {
                        // bytes start-end/total
                        val parts = contentRange.removePrefix("bytes ").split("/", limit = 2)
                        val range = parts.firstOrNull()?.split("-")
                        val start = range?.getOrNull(0)?.toLongOrNull() ?: 0L
                        val end = range?.getOrNull(1)?.toLongOrNull() ?: -1L
                        if (end >= start) (end - start + 1) else contentLenHeader?.toLongOrNull() ?: C.LENGTH_UNSET.toLong()
                    }
                    else -> contentLenHeader?.toLongOrNull() ?: C.LENGTH_UNSET.toLong()
                }
            }

            connection = conn
            inputStream = conn.inputStream
            opened = true
            // set lastDataSpec before notifying listener
            lastDataSpec = dataSpec
            listener?.onTransferStart(this, dataSpec, /* isNetwork= */ true)
            return bytesToRead
        } catch (e: Exception) {
            // Propagar como HttpDataSourceException para que ExoPlayer clasifique correctamente
            throw HttpDataSource.HttpDataSourceException(
                /* cause    = */ (e as? IOException) ?: IOException(e),
                /* dataSpec = */ dataSpec,
                /* type     = */ HttpDataSource.HttpDataSourceException.TYPE_OPEN
            )
        }
    }

    override fun read(buffer: ByteArray, offset: Int, readLength: Int): Int {
        try {
            val remaining = if (bytesToRead == C.LENGTH_UNSET.toLong()) readLength else (bytesToRead - bytesRead).toInt().coerceAtMost(readLength)
            if (remaining == 0) return C.RESULT_END_OF_INPUT
            val read = inputStream?.read(buffer, offset, remaining) ?: return C.RESULT_END_OF_INPUT
            if (read == -1) {
                // Si sabemos cuánto debíamos leer y no hemos llegado, indicar EOF anómalo
                return if (bytesToRead != C.LENGTH_UNSET.toLong() && bytesRead < bytesToRead) {
                    throw EOFException("Unexpected EOF: $bytesRead of $bytesToRead")
                } else C.RESULT_END_OF_INPUT
            }
            bytesRead += read
            lastDataSpec?.let { ds ->
                listener?.onBytesTransferred(this, ds, /* isNetwork = */ true, read)
            }
            return read
        } catch (e: Exception) {
            // Propagar como HttpDataSourceException para permitir políticas de reintento
            val spec = lastDataSpec ?: DataSpec.Builder().setUri(android.net.Uri.EMPTY).build()
            throw HttpDataSource.HttpDataSourceException(
                /* cause    = */ (e as? IOException) ?: IOException(e),
                /* dataSpec = */ spec,
                /* type     = */ HttpDataSource.HttpDataSourceException.TYPE_READ
            )
        }
    }

    override fun getUri(): android.net.Uri? = uri

    override fun close() {
        try {
            inputStream?.close()
        } catch (_: Exception) {}
        try {
            connection?.disconnect()
        } catch (_: Exception) {}
        if (opened) {
            opened = false
            lastDataSpec?.let { ds -> listener?.onTransferEnd(this, ds, /* isNetwork = */ true) }
        }
        inputStream = null
        connection = null
        lastDataSpec = null
    }
}

class MinimalHttpDataSourceFactory(
    private val userAgent: String,
    private val connectTimeoutMs: Int = 16000,
    private val readTimeoutMs: Int = 8000,
    private val allowCrossProtocolRedirects: Boolean = true
) : DataSource.Factory {
    private var listener: TransferListener? = null
    override fun createDataSource(): DataSource {
        return MinimalHttpDataSource(userAgent, connectTimeoutMs, readTimeoutMs, allowCrossProtocolRedirects).also {
            listener?.let { l -> it.addTransferListener(l) }
        }
    }
    fun setTransferListener(l: TransferListener?) = apply { listener = l }
}

// DataSource especializado para streams de YouTube/Googlevideo con headers mínimos
val Context.youtubeDataSource
    get() = DefaultDataSource.Factory(
        this,
        MinimalHttpDataSourceFactory(
            userAgent = "com.google.ios.youtube/19.45.4 (iPhone16,2; U; CPU iOS 18_1_0 like Mac OS X; US)",
            connectTimeoutMs = 16000,
            readTimeoutMs = 8000,
            allowCrossProtocolRedirects = true
        )
    )
