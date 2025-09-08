package com.rmusic.android.ui.screens.player

import androidx.annotation.DrawableRes
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.animateDp
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.core.updateTransition
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.util.fastForEachIndexed
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.runtime.collectAsState
import androidx.media3.common.Player
import androidx.media3.common.C
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.input.pointer.util.VelocityTracker
import androidx.compose.ui.input.pointer.util.addPointerInputChange
import com.rmusic.android.Database
import com.rmusic.android.LocalPlayerServiceBinder
import com.rmusic.android.R
import com.rmusic.android.models.Info
import com.rmusic.android.models.ui.UiMedia
import com.rmusic.android.preferences.PlayerPreferences
import com.rmusic.android.service.PlayerService
import com.rmusic.android.service.MusicDownloadService
import com.rmusic.android.ui.components.FadingRow
import com.rmusic.android.ui.components.SeekBar
import com.rmusic.android.ui.components.themed.BigIconButton
import com.rmusic.android.ui.components.themed.IconButton
import com.rmusic.android.ui.screens.artistRoute
import com.rmusic.android.ui.modifiers.onSwipe
import com.rmusic.android.utils.bold
import com.rmusic.android.utils.forceSeekToNext
import com.rmusic.android.utils.forceSeekToPrevious
import com.rmusic.android.utils.shuffleQueue
import com.rmusic.android.utils.secondary
import com.rmusic.android.utils.semiBold
import com.rmusic.android.utils.isDownloaded
import com.rmusic.android.utils.toast
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.favoritesIcon
import com.rmusic.core.ui.utils.px
import com.rmusic.core.ui.utils.roundedShape
import com.rmusic.providers.innertube.Innertube
import com.rmusic.providers.innertube.models.bodies.PlayerBody
import com.rmusic.providers.innertube.requests.player
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.launch
import androidx.compose.runtime.rememberCoroutineScope
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope

private val DefaultOffset = 24.dp

// Nuevo botón de control sin bordes con overlay blanco al presionar
@Composable
private fun ControlIcon(
    @DrawableRes iconId: Int,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    iconSize: Dp = 28.dp,
    containerSize: Dp = 56.dp,
    tint: Color? = null
) {
    val (colorPalette) = LocalAppearance.current
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val tintColor = tint ?: colorPalette.text

    Box(
        modifier = modifier
            .size(containerSize)
            .clip(16.dp.roundedShape)
            .clickable(
                interactionSource = interaction,
                indication = null,
                enabled = enabled,
                onClick = onClick
            )
            .background(if (pressed) Color.White.copy(alpha = 0.12f) else Color.Transparent),
        contentAlignment = Alignment.Center
    ) {
        Image(
            painter = painterResource(iconId),
            contentDescription = null,
            colorFilter = ColorFilter.tint(tintColor),
            modifier = Modifier.size(iconSize)
        )
    }
}

@Composable
fun Controls(
    media: UiMedia?,
    binder: PlayerService.Binder?,
    likedAt: Long?,
    setLikedAt: (Long?) -> Unit,
    shouldBePlaying: Boolean,
    position: Long,
    modifier: Modifier = Modifier,
    layout: PlayerPreferences.PlayerLayout = PlayerPreferences.playerLayout,
    onOpenLyricsDialog: (() -> Unit)? = null,
    onOpenQueue: (() -> Unit)? = null,
    onQueueDragDelta: ((Float) -> Unit)? = null,
    onQueueDragEnd: ((Float) -> Unit)? = null
) {
    val shouldBePlayingTransition = updateTransition(
        targetState = shouldBePlaying,
        label = "shouldBePlaying"
    )

    val playButtonRadius by shouldBePlayingTransition.animateDp(
        transitionSpec = { tween(durationMillis = 100, easing = LinearEasing) },
        label = "playPauseRoundness",
        targetValueByState = { if (it) 16.dp else 32.dp }
    )

    if (media != null && binder != null) when (layout) {
        PlayerPreferences.PlayerLayout.Classic -> ClassicControls(
            media = media,
            binder = binder,
            shouldBePlaying = shouldBePlaying,
            position = position,
            likedAt = likedAt,
            setLikedAt = setLikedAt,
            playButtonRadius = playButtonRadius,
            modifier = modifier,
            onOpenLyricsDialog = onOpenLyricsDialog,
            onOpenQueue = onOpenQueue,
            onQueueDragDelta = onQueueDragDelta,
            onQueueDragEnd = onQueueDragEnd
        )

        // Unificamos el diseño para ambos layouts
        PlayerPreferences.PlayerLayout.New -> ClassicControls(
            media = media,
            binder = binder,
            shouldBePlaying = shouldBePlaying,
            position = position,
            likedAt = likedAt,
            setLikedAt = setLikedAt,
            playButtonRadius = playButtonRadius,
            modifier = modifier,
            onOpenLyricsDialog = onOpenLyricsDialog,
            onOpenQueue = onOpenQueue,
            onQueueDragDelta = onQueueDragDelta,
            onQueueDragEnd = onQueueDragEnd
        )
    }
}

@Composable
private fun ClassicControls(
    media: UiMedia,
    binder: PlayerService.Binder,
    shouldBePlaying: Boolean,
    position: Long,
    likedAt: Long?,
    setLikedAt: (Long?) -> Unit,
    playButtonRadius: Dp,
    modifier: Modifier = Modifier,
    onOpenLyricsDialog: (() -> Unit)? = null,
    onOpenQueue: (() -> Unit)? = null,
    onQueueDragDelta: ((Float) -> Unit)? = null,
    onQueueDragEnd: ((Float) -> Unit)? = null
) = with(PlayerPreferences) {
    val (colorPalette) = LocalAppearance.current

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 32.dp)
    ) {
        // Título + artista
        Spacer(modifier = Modifier.height(8.dp))
        MediaInfo(media)

    // Separación adicional debajo del nombre del artista para alejar la línea de tiempo
    Spacer(modifier = Modifier.height(24.dp))
    Spacer(modifier = Modifier.weight(1f))

        // Barra de progreso
        SeekBar(
            binder = binder,
            position = position,
            media = media,
            alwaysShowDuration = true
        )

    // Aumentar aún más el espacio entre la barra de progreso y los controles
    Spacer(modifier = Modifier.height(24.dp))

        // Área desde botones de play hacia abajo: deslizar hacia arriba abre la cola
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .pointerInput(Unit) {
                    val velocityTracker = VelocityTracker()
                    detectVerticalDragGestures(
                        onVerticalDrag = { change, dragAmount ->
                            velocityTracker.addPointerInputChange(change)
                            // Pasar el delta al BottomSheet para que siga el dedo
                            onQueueDragDelta?.invoke(dragAmount)
                        },
                        onDragEnd = {
                            // Fling con la misma convención de signos que usa BottomSheet
                            val vy = -velocityTracker.calculateVelocity().y
                            onQueueDragEnd?.invoke(vy)
                            velocityTracker.resetTracking()
                        },
                        onDragCancel = {
                            velocityTracker.resetTracking()
                        }
                    )
                }
        ) {
            // Fila de controles de reproducción (mantener estilo actual del botón play)
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center,
                modifier = Modifier.fillMaxWidth()
            ) {
                ControlIcon(
                    iconId = R.drawable.play_skip_back,
                    onClick = binder.player::forceSeekToPrevious
                )

                Spacer(modifier = Modifier.width(8.dp))

                PlayButton(
                    radius = playButtonRadius,
                    shouldBePlaying = shouldBePlaying,
                    modifier = Modifier.size(64.dp)
                )

                Spacer(modifier = Modifier.width(8.dp))

                ControlIcon(
                    iconId = R.drawable.play_skip_forward,
                    onClick = binder.player::forceSeekToNext
                )
            }

            // Bajar los 4 controles inferiores para que no queden pegados al botón de play
            Spacer(modifier = Modifier.height(30.dp))

            // Fila inferior: 4 botones centrados, sin fondo, con opacidad blanca al presionar
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceEvenly,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp)
            ) {
                // 1) Repetir pista (loop)
                ControlIcon(
                    iconId = R.drawable.infinite,
                    onClick = { trackLoopEnabled = !trackLoopEnabled },
                    tint = if (trackLoopEnabled) colorPalette.accent else colorPalette.text
                )

                // 2) Descargar
                DownloadControl(media = media)

                // 3) Aleatorio (mezclar cola)
                ControlIcon(
                    iconId = R.drawable.shuffle,
                    onClick = { binder.player.shuffleQueue() }
                )

                // 4) Abrir lista de reproducción (cola)
                ControlIcon(
                    iconId = R.drawable.ellipsis_horizontal,
                    onClick = { onOpenQueue?.invoke() }
                )
            }

            Spacer(modifier = Modifier.weight(1f))
        }
    }
}

// ModernControls se unifica con ClassicControls para este rediseño
@Composable
private fun SkipButton(
    @DrawableRes iconId: Int,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    offsetOnPress: Dp = DefaultOffset
) {
    val interactionSource = remember { MutableInteractionSource() }
    val pressed by interactionSource.collectIsPressedAsState()
    val offset by animateDpAsState(
        targetValue = if (pressed) offsetOnPress else 0.dp,
        label = ""
    )

    BigIconButton(
        iconId = iconId,
        modifier = modifier
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            )
            .offset {
                IntOffset(x = offset.roundToPx(), y = 0)
            }
    )
}

@Composable
private fun PlayButton(
    radius: Dp,
    shouldBePlaying: Boolean,
    modifier: Modifier = Modifier
) {
    val (colorPalette) = LocalAppearance.current
    val binder = LocalPlayerServiceBinder.current

    Box(
        modifier = modifier
            .clip(radius.roundedShape)
            .clickable {
                if (shouldBePlaying) binder?.player?.pause() else {
                    if (binder?.player?.playbackState == Player.STATE_IDLE) binder.player.prepare()
                    binder?.player?.play()
                }
            }
            .background(colorPalette.accent)
    ) {
        AnimatedPlayPauseButton(
            playing = shouldBePlaying,
            modifier = Modifier
                .align(Alignment.Center)
                .size(32.dp)
        )
    }
}

@Composable
private fun MediaInfo(media: UiMedia) {
    val (colorPalette, typography) = LocalAppearance.current
    val context = LocalContext.current
    val binder = LocalPlayerServiceBinder.current
    val scope = rememberCoroutineScope()

    var artistInfo: List<Info>? by remember { mutableStateOf(null) }
    var maxHeight by rememberSaveable { mutableIntStateOf(0) }

    LaunchedEffect(media) {
        withContext(Dispatchers.IO) {
            artistInfo = Database
                .songArtistInfo(media.id)
                .takeIf { it.isNotEmpty() }
        }
    }

    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        // Título centrado sin botones laterales
        AnimatedContent(
            targetState = media.title,
            transitionSpec = { fadeIn() togetherWith fadeOut() },
            label = "",
            modifier = Modifier.fillMaxWidth()
        ) { title ->
            FadingRow(modifier = Modifier.fillMaxWidth()) {
                BasicText(
                    text = title,
                    style = typography.l.bold.copy(textAlign = androidx.compose.ui.text.style.TextAlign.Center),
                    maxLines = 1,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }

        AnimatedContent(
            targetState = media to artistInfo,
            transitionSpec = { fadeIn() togetherWith fadeOut() },
            label = ""
        ) { (media, state) ->
            state?.let { artists ->
                FadingRow(
                    modifier = Modifier
                        .fillMaxWidth(0.75f)
                        .heightIn(maxHeight.px.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    artists.fastForEachIndexed { i, artist ->
                        if (i == artists.lastIndex && artists.size > 1) BasicText(
                            text = " & ",
                            style = typography.s.semiBold.secondary
                        )
                        BasicText(
                            text = artist.name.orEmpty(),
                            style = typography.s.bold.secondary,
                            modifier = Modifier.clickable { artistRoute.global(artist.id) }
                        )
                        if (i != artists.lastIndex && i + 1 != artists.lastIndex) BasicText(
                            text = ", ",
                            style = typography.s.semiBold.secondary
                        )
                    }
                    if (media.explicit) {
                        Spacer(Modifier.width(4.dp))

                        Image(
                            painter = painterResource(R.drawable.explicit),
                            contentDescription = null,
                            colorFilter = ColorFilter.tint(colorPalette.text),
                            modifier = Modifier.size(15.dp)
                        )
                    }
                }
            } ?: FadingRow(
                modifier = Modifier.fillMaxWidth(0.75f),
                verticalAlignment = Alignment.CenterVertically
            ) {
                BasicText(
                    text = media.artist,
                    style = typography.s.semiBold.secondary,
                    maxLines = 1,
                    modifier = Modifier.onGloballyPositioned { maxHeight = it.size.height }
                )
                if (media.explicit) {
                    Spacer(Modifier.width(4.dp))

                    Image(
                        painter = painterResource(R.drawable.explicit),
                        contentDescription = null,
                        colorFilter = ColorFilter.tint(colorPalette.text),
                        modifier = Modifier.size(15.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun DownloadControl(media: UiMedia) {
    val (colorPalette) = LocalAppearance.current
    val context = LocalContext.current
    val isDownloaded = isDownloaded(media.id)

    ControlIcon(
        iconId = if (isDownloaded) R.drawable.check else R.drawable.download,
        tint = if (isDownloaded) Color(0xFF4CAF50) else colorPalette.text,
        onClick = {
            if (!isDownloaded) {
                val lifecycleOwner = context as? LifecycleOwner
                lifecycleOwner?.lifecycleScope?.launch {
                    try {
                        val videoId = media.id.removePrefix("https://youtube.com/watch?v=")
                        val playerResponse = Innertube.player(
                            PlayerBody(videoId = videoId)
                        )?.getOrNull()

                        val streamingUrl = playerResponse?.streamingData?.adaptiveFormats
                            ?.filter { it.mimeType?.startsWith("audio/") == true }
                            ?.maxByOrNull { it.bitrate ?: 0 }
                            ?.url

                        if (streamingUrl != null) {
                            MusicDownloadService.download(
                                context = context.applicationContext,
                                trackId = media.id,
                                title = media.title,
                                artist = media.artist,
                                album = null,
                                thumbnailUrl = null,
                                duration = null,
                                url = streamingUrl
                            )

                            withContext(Dispatchers.Main) {
                                context.toast(context.getString(R.string.auto_download_started, media.title))
                            }
                        } else {
                            withContext(Dispatchers.Main) {
                                context.toast("Unable to get download URL")
                            }
                        }
                    } catch (e: Exception) {
                        android.util.Log.e("DownloadControl", "Error starting download", e)
                        withContext(Dispatchers.Main) {
                            context.toast("Download failed: ${e.message}")
                        }
                    }
                }
            }
        }
    )
}
