package com.rmusic.core.data.enums

enum class SortOrder {
    Ascending,
    Descending;

    operator fun not() = when (this) {
        Ascending -> Descending
        Descending -> Ascending
    }
}
