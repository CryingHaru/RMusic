package com.rmusic.providers.intermusic.models.response

import kotlinx.serialization.Serializable

@Serializable
data class SearchSuggestionsResponse(
     val contents: List<Content>? = null,
 ) {
     @Serializable
     data class Content(
         val searchSuggestionsSectionRenderer: SearchSuggestionsSectionRenderer? = null,
     ) {
         @Serializable
         data class SearchSuggestionsSectionRenderer(
             val contents: List<Item>? = null,
         ) {
             @Serializable
             data class Item(
                 val searchSuggestionRenderer: SearchSuggestionRenderer? = null,
             ) {
                 @Serializable
                 data class SearchSuggestionRenderer(
                     val navigationEndpoint: NavigationEndpoint? = null,
                 ) {
                     @Serializable
                     data class NavigationEndpoint(
                         val searchEndpoint: SearchEndpoint? = null,
                     ) {
                         @Serializable
                         data class SearchEndpoint(
                             val query: String? = null,
                         )
                     }
                 }
             }
         }
     }
 }
