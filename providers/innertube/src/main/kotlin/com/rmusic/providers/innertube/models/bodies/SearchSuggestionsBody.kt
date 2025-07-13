package com.rmusic.providers.innertube.models.bodies

import com.rmusic.providers.innertube.models.Context
import kotlinx.serialization.Serializable

@Serializable
data class SearchSuggestionsBody(
    val context: Context = Context.DefaultWeb,
    val input: String
)
