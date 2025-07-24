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
import com.rmusic.android.utils.bold
import com.rmusic.android.utils.forceSeekToNext
import com.rmusic.android.utils.forceSeekToPrevious
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

@Composable
fun Controls(
    media: UiMedia?,
    binder: PlayerService.Binder?,
    likedAt: Long?,
    setLikedAt: (Long?) -> Unit,
    shouldBePlaying: Boolean,
    position: Long,
    modifier: Modifier = Modifier,
    layout: PlayerPreferences.PlayerLayout = PlayerPreferences.playerLayout
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
            modifier = modifier
        )

        PlayerPreferences.PlayerLayout.New -> ModernControls(
            media = media,
            binder = binder,
            shouldBePlaying = shouldBePlaying,
            position = position,
            likedAt = likedAt,
            setLikedAt = setLikedAt,
            playButtonRadius = playButtonRadius,
            modifier = modifier
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
    modifier: Modifier = Modifier
) = with(PlayerPreferences) {
    val (colorPalette) = LocalAppearance.current

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 32.dp)
    ) {
        Spacer(modifier = Modifier.weight(1f))
        MediaInfo(media)
        Spacer(modifier = Modifier.weight(1f))
        SeekBar(
            binder = binder,
            position = position,
            media = media,
            alwaysShowDuration = true
        )
        Spacer(modifier = Modifier.weight(1f))

        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.fillMaxWidth()
        ) {
            IconButton(
                icon = if (likedAt == null) R.drawable.heart_outline else R.drawable.heart,
                color = colorPalette.favoritesIcon,
                onClick = {
                    setLikedAt(if (likedAt == null) System.currentTimeMillis() else null)
                },
                modifier = Modifier
                    .weight(1f)
                    .size(24.dp)
            )

            IconButton(
                icon = R.drawable.play_skip_back,
                color = colorPalette.text,
                onClick = binder.player::forceSeekToPrevious,
                modifier = Modifier
                    .weight(1f)
                    .size(24.dp)
            )

            Spacer(modifier = Modifier.width(8.dp))

            Box(
                modifier = Modifier
                    .clip(playButtonRadius.roundedShape)
                    .clickable {
                        if (shouldBePlaying) binder.player.pause()
                        else {
                            if (binder.player.playbackState == Player.STATE_IDLE) binder.player.prepare()
                            binder.player.play()
                        }
                    }
                    .background(colorPalette.background2)
                    .size(64.dp)
            ) {
                AnimatedPlayPauseButton(
                    playing = shouldBePlaying,
                    modifier = Modifier
                        .align(Alignment.Center)
                        .size(32.dp)
                )
            }

            Spacer(modifier = Modifier.width(8.dp))

            IconButton(
                icon = R.drawable.play_skip_forward,
                color = colorPalette.text,
                onClick = binder.player::forceSeekToNext,
                modifier = Modifier
                    .weight(1f)
                    .size(24.dp)
            )

            IconButton(
                icon = R.drawable.infinite,
                enabled = trackLoopEnabled,
                onClick = { trackLoopEnabled = !trackLoopEnabled },
                modifier = Modifier
                    .weight(1f)
                    .size(24.dp)
            )
        }

        Spacer(modifier = Modifier.weight(1f))
    }
}

@Composable
private fun ModernControls(
    media: UiMedia,
    binder: PlayerService.Binder,
    shouldBePlaying: Boolean,
    position: Long,
    likedAt: Long?,
    setLikedAt: (Long?) -> Unit,
    playButtonRadius: Dp,
    modifier: Modifier = Modifier,
    controlHeight: Dp = 64.dp
) {
    val previousButtonContent: @Composable RowScope.() -> Unit = {
        SkipButton(
            iconId = R.drawable.play_skip_back,
            onClick = binder.player::forceSeekToPrevious,
            modifier = Modifier.weight(1f),
            offsetOnPress = -DefaultOffset
        )
    }

    val likeButtonContent: @Composable RowScope.() -> Unit = {
        BigIconButton(
            iconId = if (likedAt == null) R.drawable.heart_outline else R.drawable.heart,
            onClick = {
                setLikedAt(if (likedAt == null) System.currentTimeMillis() else null)
            },
            modifier = Modifier.weight(1f)
        )
    }

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 32.dp)
    ) {
        Spacer(modifier = Modifier.weight(1f))
        MediaInfo(media)
        Spacer(modifier = Modifier.weight(1f))

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Always show like or skip-back at left
            if (PlayerPreferences.showLike) likeButtonContent() else previousButtonContent()

            PlayButton(
                radius = playButtonRadius,
                shouldBePlaying = shouldBePlaying,
                modifier = Modifier
                    .height(controlHeight)
                    .weight(4f)
            )
            SkipButton(
                iconId = R.drawable.play_skip_forward,
                onClick = binder.player::forceSeekToNext,
                modifier = Modifier.weight(1f)
            )
        }
        Spacer(modifier = Modifier.weight(1f))
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                SeekBar(
                    binder = binder,
                    position = position,
                    media = media
                )
            }
        }

        Spacer(modifier = Modifier.weight(1f))
    }
}

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

    // Check if song is downloaded
    val isDownloaded = isDownloaded(media.id)
    
    // Get like state from database
    val likedAt by Database.likedAt(media.id).collectAsState(initial = null)
    val isLiked = likedAt != null

    LaunchedEffect(media) {
        withContext(Dispatchers.IO) {
            artistInfo = Database
                .songArtistInfo(media.id)
                .takeIf { it.isNotEmpty() }
        }
    }

    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        // Título con botones de like y descarga
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            // Botón de descarga (muestra check si ya está descargado)
            IconButton(
                icon = if (isDownloaded) R.drawable.check else R.drawable.download,
                color = if (isDownloaded) Color(0xFF4CAF50) else colorPalette.text,
                onClick = {
                    if (!isDownloaded) {
                        // Iniciar descarga usando la lógica simplificada
                        val lifecycleOwner = context as? LifecycleOwner
                        lifecycleOwner?.lifecycleScope?.launch {
                            try {
                                // Resolver la URL de streaming
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
                                android.util.Log.e("MediaInfo", "Error starting download", e)
                                withContext(Dispatchers.Main) {
                                    context.toast("Download failed: ${e.message}")
                                }
                            }
                        }
                    }
                },
                modifier = Modifier.size(24.dp)
            )
            
            // Título centrado
            AnimatedContent(
                targetState = media.title,
                transitionSpec = { fadeIn() togetherWith fadeOut() },
                label = "",
                modifier = Modifier.weight(1f)
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
            
            // Botón de like
            IconButton(
                icon = if (isLiked) R.drawable.heart else R.drawable.heart_outline,
                color = if (isLiked) colorPalette.favoritesIcon else colorPalette.text,
                onClick = {
                    // Toggle like state
                    scope.launch {
                        Database.like(
                            songId = media.id,
                            likedAt = if (isLiked) null else System.currentTimeMillis()
                        )
                    }
                },
                modifier = Modifier.size(24.dp)
            )
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
