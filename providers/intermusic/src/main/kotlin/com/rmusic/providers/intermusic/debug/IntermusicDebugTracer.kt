package com.rmusic.providers.intermusic.debug

/**
 * Lightweight tracer interface that allows the app module to observe sensitive authentication
 * plumbing only when the debug build installs a concrete implementation.
 */
interface IntermusicDebugTracer {
    fun log(scope: String, message: String, data: Map<String, Any?> = emptyMap(), error: Throwable? = null)

    companion object {
        val NO_OP: IntermusicDebugTracer = object : IntermusicDebugTracer {
            override fun log(scope: String, message: String, data: Map<String, Any?>, error: Throwable?) = Unit
        }
    }
}
