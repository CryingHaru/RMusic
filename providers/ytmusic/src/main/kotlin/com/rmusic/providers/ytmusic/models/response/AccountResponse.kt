package com.rmusic.providers.ytmusic.models.response
import kotlinx.serialization.Serializable


typealias TextRuns = BrowseResponse.TextRuns
typealias NavigationEndpoint = BrowseResponse.NavigationEndpoint  
typealias MusicShelfRenderer = BrowseResponse.MusicShelfRenderer
typealias Continuation = BrowseResponse.Continuation
typealias MusicTwoRowItemRenderer = BrowseResponse.MusicTwoRowItemRenderer

@Serializable
data class AccountMenuResponse(
    val actions: List<Action> = emptyList(),
) {
    @Serializable
    data class Action(
        val openPopupAction: OpenPopupAction? = null,
    )

    @Serializable
    data class OpenPopupAction(
        val popup: Popup? = null,
    )

    @Serializable
    data class Popup(
        val multiPageMenuRenderer: MultiPageMenuRenderer? = null,
    )

    @Serializable
    data class MultiPageMenuRenderer(
        val header: Header? = null,
        val sections: List<Section>? = null,
    )

    @Serializable
    data class Header(
        val activeAccountHeaderRenderer: ActiveAccountHeaderRenderer? = null,
    )

    @Serializable
    data class ActiveAccountHeaderRenderer(
        val accountName: TextRuns? = null,
    val accountPhoto: BrowseResponse.Thumbnail? = null,
        val channelHandle: TextRuns? = null,
        val channelId: String? = null,
    )

    @Serializable
    data class Section(
        val accountSectionListRenderer: AccountSectionListRenderer? = null,
    )

    @Serializable
    data class AccountSectionListRenderer(
        val contents: List<SectionContent>? = null,
    )

    @Serializable
    data class SectionContent(
        val compactLinkRenderer: CompactLinkRenderer? = null,
    )

    @Serializable
    data class CompactLinkRenderer(
        val text: TextRuns? = null,
        val icon: Icon? = null,
        val navigationEndpoint: NavigationEndpoint? = null,
    )

    @Serializable
    data class Icon(
        val iconType: String? = null,
    )
}
