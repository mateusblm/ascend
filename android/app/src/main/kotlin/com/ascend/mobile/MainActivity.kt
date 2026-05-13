package com.ascend.mobile

import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.DistanceRecord
import androidx.health.connect.client.records.ExerciseSessionRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.time.Duration
import java.time.Instant
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterFragmentActivity() {
    private val permissions = setOf(
        HealthPermission.getReadPermission(ExerciseSessionRecord::class),
        HealthPermission.getReadPermission(DistanceRecord::class),
    )
    private val permissionLauncher = registerForActivityResult(
        PermissionController.createRequestPermissionResultContract(),
    ) { granted ->
        val request = pendingRequest
        val result = pendingResult
        pendingRequest = null
        pendingResult = null

        if (request == null || result == null) {
            return@registerForActivityResult
        }
        if (!granted.containsAll(permissions)) {
            result.success(null)
            return@registerForActivityResult
        }
        readSessionEvidence(request, result)
    }
    private var pendingRequest: HealthConnectReadRequest? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ascend/health_connect",
        ).setMethodCallHandler { call, result ->
            if (call.method != "readSessionEvidence") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val args = call.arguments as? Map<*, *>
            val evidenceType = args?.get("evidenceType") as? String
            val startedAt = (args?.get("startedAt") as? String)?.let(Instant::parse)
            val completedAt = (args?.get("completedAt") as? String)?.let(Instant::parse)
            if (evidenceType == null || startedAt == null || completedAt == null) {
                result.error("invalid_argument", "Invalid Health Connect evidence request.", null)
                return@setMethodCallHandler
            }

            checkPermissionsAndRead(
                HealthConnectReadRequest(
                    evidenceType = evidenceType,
                    startedAt = startedAt,
                    completedAt = completedAt,
                ),
                result,
            )
        }
    }

    private fun checkPermissionsAndRead(
        request: HealthConnectReadRequest,
        result: MethodChannel.Result,
    ) {
        val sdkStatus = HealthConnectClient.getSdkStatus(this)
        if (sdkStatus != HealthConnectClient.SDK_AVAILABLE) {
            result.success(null)
            return
        }

        CoroutineScope(Dispatchers.Main).launch {
            try {
                val client = HealthConnectClient.getOrCreate(this@MainActivity)
                val granted = client.permissionController.getGrantedPermissions()
                if (granted.containsAll(permissions)) {
                    readSessionEvidence(request, result)
                } else {
                    pendingRequest = request
                    pendingResult = result
                    permissionLauncher.launch(permissions)
                }
            } catch (error: Throwable) {
                result.error("health_connect_unavailable", error.message, null)
            }
        }
    }

    private fun readSessionEvidence(
        request: HealthConnectReadRequest,
        result: MethodChannel.Result,
    ) {
        CoroutineScope(Dispatchers.Main).launch {
            try {
                val client = HealthConnectClient.getOrCreate(this@MainActivity)
                val session = client.readRecords(
                    ReadRecordsRequest(
                        recordType = ExerciseSessionRecord::class,
                        timeRangeFilter = TimeRangeFilter.between(
                            request.startedAt,
                            request.completedAt,
                        ),
                    ),
                ).records
                    .filter { it.isCompatibleWith(request.evidenceType) }
                    .maxByOrNull { Duration.between(it.startTime, it.endTime).toMillis() }

                if (session == null) {
                    result.success(null)
                    return@launch
                }

                val distanceMeters = client.readRecords(
                    ReadRecordsRequest(
                        recordType = DistanceRecord::class,
                        timeRangeFilter = TimeRangeFilter.between(
                            session.startTime,
                            session.endTime,
                        ),
                    ),
                ).records.sumOf { it.distance.inMeters }.toInt()

                result.success(
                    mapOf(
                        "startedAt" to session.startTime.toString(),
                        "completedAt" to session.endTime.toString(),
                        "durationMinutes" to Duration.between(
                            session.startTime,
                            session.endTime,
                        ).toMinutes().toInt(),
                        "distanceMeters" to distanceMeters.takeIf { it > 0 },
                        "sourceActivityId" to session.metadata.id,
                    ),
                )
            } catch (error: Throwable) {
                result.error("health_connect_read_failed", error.message, null)
            }
        }
    }

    private fun ExerciseSessionRecord.isCompatibleWith(evidenceType: String): Boolean {
        return when (evidenceType) {
            "runningDistance" -> exerciseType == ExerciseSessionRecord.EXERCISE_TYPE_RUNNING ||
                exerciseType == ExerciseSessionRecord.EXERCISE_TYPE_RUNNING_TREADMILL
            "workoutSession" -> true
            else -> false
        }
    }
}

private data class HealthConnectReadRequest(
    val evidenceType: String,
    val startedAt: Instant,
    val completedAt: Instant,
)
