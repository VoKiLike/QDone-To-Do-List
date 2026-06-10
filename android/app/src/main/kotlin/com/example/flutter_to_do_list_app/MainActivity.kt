package com.volkoweb.qdone

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingFileResult: MethodChannel.Result? = null
    private var pendingExportContent: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            HAPTICS_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "taskTap") {
                vibrateTaskTap()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            FILES_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "importBackup" -> startBackupImport(result)
                "exportBackup" -> {
                    val fileName = call.argument<String>("fileName") ?: DEFAULT_BACKUP_FILE
                    val content = call.argument<String>("content")
                    if (content == null) {
                        result.error("empty_export", "Backup content is empty.", null)
                    } else {
                        startBackupExport(fileName, content, result)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            FILE_IMPORT_REQUEST -> completeBackupImport(resultCode, data)
            FILE_EXPORT_REQUEST -> completeBackupExport(resultCode, data)
        }
    }

    private fun startBackupImport(result: MethodChannel.Result) {
        if (pendingFileResult != null) {
            result.error("busy", "A file operation is already running.", null)
            return
        }
        pendingFileResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            putExtra(
                Intent.EXTRA_MIME_TYPES,
                arrayOf("application/json", "text/json", "text/plain", "application/octet-stream")
            )
        }
        runCatching {
            startActivityForResult(Intent.createChooser(intent, "Import QDone JSON"), FILE_IMPORT_REQUEST)
        }.onFailure {
            pendingFileResult = null
            result.error("open_failed", it.localizedMessage, null)
        }
    }

    private fun startBackupExport(
        fileName: String,
        content: String,
        result: MethodChannel.Result
    ) {
        if (pendingFileResult != null) {
            result.error("busy", "A file operation is already running.", null)
            return
        }
        pendingFileResult = result
        pendingExportContent = content
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "text/plain"
            putExtra(Intent.EXTRA_TITLE, fileName)
        }
        runCatching {
            startActivityForResult(Intent.createChooser(intent, "Export QDone JSON"), FILE_EXPORT_REQUEST)
        }.onFailure {
            pendingFileResult = null
            pendingExportContent = null
            result.error("save_failed", it.localizedMessage, null)
        }
    }

    private fun completeBackupImport(resultCode: Int, data: Intent?) {
        val result = pendingFileResult ?: return
        pendingFileResult = null
        if (resultCode != Activity.RESULT_OK) {
            result.success(null)
            return
        }
        val uri = data?.data
        if (uri == null) {
            result.success(null)
            return
        }
        runCatching {
            contentResolver.openInputStream(uri)?.bufferedReader(Charsets.UTF_8).use { reader ->
                reader?.readText()
            }
        }.onSuccess { content ->
            if (content == null) {
                result.error("read_failed", "Unable to read selected file.", null)
            } else {
                result.success(content)
            }
        }.onFailure {
            result.error("read_failed", it.localizedMessage, null)
        }
    }

    private fun completeBackupExport(resultCode: Int, data: Intent?) {
        val result = pendingFileResult ?: return
        val content = pendingExportContent
        pendingFileResult = null
        pendingExportContent = null
        if (resultCode != Activity.RESULT_OK) {
            result.success(false)
            return
        }
        val uri = data?.data
        if (uri == null || content == null) {
            result.success(false)
            return
        }
        runCatching {
            contentResolver.openOutputStream(uri)?.use { stream ->
                stream.write(content.toByteArray(Charsets.UTF_8))
            } ?: error("Unable to open selected file.")
        }.onSuccess {
            result.success(true)
        }.onFailure {
            result.error("save_failed", it.localizedMessage, null)
        }
    }

    private fun vibrateTaskTap() {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val manager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            manager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        if (!vibrator.hasVibrator()) return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(
                VibrationEffect.createOneShot(
                    TASK_TAP_VIBRATION_MS,
                    VibrationEffect.DEFAULT_AMPLITUDE
                )
            )
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(TASK_TAP_VIBRATION_MS)
        }
    }

    private companion object {
        const val HAPTICS_CHANNEL = "qdone/haptics"
        const val FILES_CHANNEL = "qdone/files"
        const val TASK_TAP_VIBRATION_MS = 18L
        const val FILE_IMPORT_REQUEST = 3401
        const val FILE_EXPORT_REQUEST = 3402
        const val DEFAULT_BACKUP_FILE = "qdone-backup.json"
    }
}
