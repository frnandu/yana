package yana.nostr
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
//class MainActivity : FlutterFragmentActivity() {
//    private val CHANNEL = "flutter.native/helper"
//
//    private val secp256k1 = Secp256k1.get()
//
//    @ExperimentalStdlibApi
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine);
//        MethodChannel(
//            flutterEngine.dartExecutor.binaryMessenger,
//            CHANNEL
//        ).setMethodCallHandler { call, result ->
//            when {
//                call.method.equals("verifySignature") -> {
//                    verifySignature(call, result)
//                }
//            }
//        }
//    }
//    fun verifySignature(
//        call: MethodCall, result: MethodChannel.Result
//    ) {
//        var sig = call.argument<ByteArray>("signature");
//        var hash = call.argument<ByteArray>("hash");
//        var pubKey = call.argument<ByteArray>("pubKey");
//
//        result.success(secp256k1.verifySchnorr(sig!!, hash!!, pubKey!!));
//    }
//
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//        if (requestCode == REQUEST_CODE) {
//            if (resultCode == Activity.RESULT_OK) {
//                // Handle the result from the other app here
//                val resultData = data?.getStringExtra("signature")
//                // Send the result back to Flutter
//                myResult.success(resultData)
//            } else {
//                myResult.success(null)
//            }
//        }
//    }
}
