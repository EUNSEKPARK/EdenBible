package com.edenbible.app

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.edenbible.app/kakao_share")
            .setMethodCallHandler { call, result ->
                if (call.method != "shareImageToKakao") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val path = call.argument<String>("path")
                val text = call.argument<String>("text") ?: ""
                if (path == null) {
                    result.error("bad_args", "path required", null)
                    return@setMethodCallHandler
                }
                val file = File(path)
                if (!file.exists()) {
                    result.error("not_found", "file not found", null)
                    return@setMethodCallHandler
                }
                val authority = "${applicationContext.packageName}.flutter.share_provider"
                val uri: Uri = FileProvider.getUriForFile(applicationContext, authority, file)
                val intent = Intent(Intent.ACTION_SEND).apply {
                    type = "image/png"
                    putExtra(Intent.EXTRA_STREAM, uri)
                    if (text.isNotEmpty()) {
                        putExtra(Intent.EXTRA_TEXT, text)
                    }
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    setPackage("com.kakao.talk")
                }
                try {
                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                } catch (e: Exception) {
                    result.error("share_failed", e.message, null)
                }
            }
    }
}
