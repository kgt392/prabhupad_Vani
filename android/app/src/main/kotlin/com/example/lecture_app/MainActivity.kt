package com.example.lecture_app

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipFile

class MainActivity : FlutterActivity() {
    private val CHANNEL = "obb"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "resolve" -> {
                    val relPath = call.argument<String>("relativePath")
                    if (relPath.isNullOrBlank()) {
                        result.error("ARG", "relativePath required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val resolved = resolveFromObb(relPath)
                        if (resolved != null) {
                            result.success(resolved)
                        } else {
                            result.error("NF", "File not found in OBB: $relPath", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun resolveFromObb(relativePath: String): String? {
        val pm = applicationContext.packageManager
        val pkg = applicationContext.packageName
        val versionCode = try {
            if (Build.VERSION.SDK_INT >= 33) {
                pm.getPackageInfo(pkg, PackageManager.PackageInfoFlags.of(0)).longVersionCode
            } else {
                @Suppress("DEPRECATION")
                pm.getPackageInfo(pkg, 0).longVersionCode
            }
        } catch (e: Exception) {
            1L
        }

        val obbDir = File("/Android/obb/$pkg")
        val obbFile = File(obbDir, "main.$versionCode.$pkg.obb")
        if (!obbFile.exists()) return null

        ZipFile(obbFile).use { zip ->
            val entry = zip.getEntry(relativePath)
            if (entry == null || entry.isDirectory) return null
            val cacheOut = File(cacheDir, relativePath.replace('/', '_'))
            cacheOut.parentFile?.mkdirs()
            zip.getInputStream(entry).use { input ->
                FileOutputStream(cacheOut).use { out ->
                    input.copyTo(out)
                }
            }
            return cacheOut.absolutePath
        }
    }
}
