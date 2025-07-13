package com.rmusic.android.ui.screens.download

import android.content.Context
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.lifecycle.viewmodel.compose.viewModel
import com.rmusic.download.data.DownloadEntity
import com.rmusic.download.DownloadState
import com.rmusic.android.ui.screens.download.DownloadViewModelFactory
import com.rmusic.download.ui.DownloadViewModel

@Composable
fun DownloadScreen() {
    val context = LocalContext.current
    val factory = DownloadViewModelFactory(context)
    val vm: DownloadViewModel = viewModel(
        factory = factory
    )
    var trackId by remember { mutableStateOf("") }

    Column(modifier = Modifier
        .fillMaxSize()
        .padding(16.dp)
    ) {
        OutlinedTextField(
            value = trackId,
            onValueChange = { trackId = it },
            label = { Text("Track ID") },
            modifier = Modifier.fillMaxWidth(),
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
            keyboardActions = KeyboardActions(onDone = {
                vm.startDownload(trackId)
                trackId = ""
            })
        )
        Spacer(modifier = Modifier.height(8.dp))
        Button(onClick = {
            if (trackId.isNotBlank()) {
                vm.startDownload(trackId)
                trackId = ""
            }
        }) {
            Text("Start Download")
        }
        Spacer(modifier = Modifier.height(16.dp))
        Text("Descargas", style = MaterialTheme.typography.titleMedium)
        Spacer(modifier = Modifier.height(8.dp))
        val downloads by vm.downloads.collectAsState()
        LazyColumn(modifier = Modifier.fillMaxWidth()) {
            items(downloads, key = { it.id }) { item: DownloadEntity ->
                DownloadItem(item = item, onPause = { vm.pauseDownload(it) }, onResume = { vm.resumeDownload(it) }, onCancel = { vm.cancelDownload(it) })
                Divider()
            }
        }
    }
}

@Composable
fun DownloadItem(
    item: DownloadEntity,
    onPause: (String) -> Unit,
    onResume: (String) -> Unit,
    onCancel: (String) -> Unit
) {
    Column(modifier = Modifier.padding(vertical = 8.dp)) {
        Text("ID: ${item.trackId}", style = MaterialTheme.typography.bodyLarge)
        LinearProgressIndicator(
            progress = item.progress / 100f,
            modifier = Modifier
                .fillMaxWidth()
                .height(4.dp)
        )
        Text(item.state.name, style = MaterialTheme.typography.bodySmall)
        Row(modifier = Modifier.padding(top = 4.dp)) {
            if (item.state == DownloadState.RUNNING) {
                TextButton(onClick = { onPause(item.id) }) { Text("Pause") }
            } else if (item.state == DownloadState.PAUSED) {
                TextButton(onClick = { onResume(item.id) }) { Text("Resume") }
            }
            Spacer(modifier = Modifier.width(8.dp))
            TextButton(onClick = { onCancel(item.id) }) { Text("Cancel") }
        }
    }
}
