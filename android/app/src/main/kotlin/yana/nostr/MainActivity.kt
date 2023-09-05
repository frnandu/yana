package yana.nostr

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import fr.acinq.secp256k1.Secp256k1
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// class MainActivity: FlutterActivity() {
class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "flutter.native/helper"

    private val secp256k1 = Secp256k1.get()

    @ExperimentalStdlibApi
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when {
                call.method.equals("verifySignature") -> {
                    verifySignature(call, result)
                }
            }
        }
    }
    fun verifySignature(
        call: MethodCall, result: MethodChannel.Result
    ) {
        var sig = call.argument<ByteArray>("signature");
        var hash = call.argument<ByteArray>("hash");
        var pubKey = call.argument<ByteArray>("pubKey");

        result.success(secp256k1.verifySchnorr(sig!!, hash!!, pubKey!!));
    }
}
