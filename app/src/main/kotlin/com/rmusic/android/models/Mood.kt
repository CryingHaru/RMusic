package com.rmusic.android.models

import android.os.Parcelable
import androidx.compose.ui.graphics.Color
import com.rmusic.core.ui.ColorParceler
import com.rmusic.providers.intermusic.IntermusicProvider
import kotlinx.parcelize.Parcelize
import kotlinx.parcelize.WriteWith

@Parcelize
data class Mood(
    val name: String,
    val color: @WriteWith<ColorParceler> Color,
    val browseId: String?,
    val params: String?
) : Parcelable

fun IntermusicProvider.MoodItem.toUiMood() = Mood(
    name = title,
    color = Color(stripeColor),
    browseId = browseId,
    params = params
)
