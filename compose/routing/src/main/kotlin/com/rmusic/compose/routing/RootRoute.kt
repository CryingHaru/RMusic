package com.rmusic.compose.routing

// Ruta global que representa la pantalla raíz (sin child activo).
// Se usa solo para emitir eventos de retorno (back) y que los observadores
// puedan revertir estados derivados de rutas modales (p. ej., ocultar/mostrar UI).
val rootRoute = Route0("rootRoute")
