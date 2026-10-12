package com.example.douyin.nativehost

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.FragmentActivity
import com.example.douyin.nativehost.databinding.ActivityMainBinding
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.android.RenderMode

/** A native Activity with a native header and an embedded Flutter page. */
class MainActivity : FragmentActivity() {
    private var flutterFragment: FlutterFragment? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)

        val binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        WindowCompat.getInsetsController(window, binding.root)
            .isAppearanceLightNavigationBars = true

        // The native layout handles system bars once for both UI toolkits.
        // Preserve remaining insets, including the keyboard, for Flutter.
        ViewCompat.setOnApplyWindowInsetsListener(binding.root) { view, insets ->
            val bars = insets.getInsets(
                WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout()
            )
            view.setPadding(bars.left, bars.top, bars.right, bars.bottom)
            insets.inset(bars.left, bars.top, bars.right, bars.bottom)
        }
        ViewCompat.requestApplyInsets(binding.root)

        binding.nativeButton.setOnClickListener {
            Toast.makeText(this, R.string.native_toast, Toast.LENGTH_SHORT).show()
        }

        // Reuse the fragment restored by FragmentManager during Activity recreation.
        flutterFragment = supportFragmentManager.findFragmentByTag(FLUTTER_TAG) as? FlutterFragment
        if (flutterFragment == null) {
            val fragment = FlutterFragment.withNewEngine()
                .renderMode(RenderMode.texture)
                .shouldAutomaticallyHandleOnBackPressed(true)
                .build<FlutterFragment>()
            flutterFragment = fragment
            supportFragmentManager.beginTransaction()
                .add(R.id.flutter_container, fragment, FLUTTER_TAG)
                .commitNow()
        }
    }

    // FragmentActivity handles the normal Fragment lifecycle. These additional
    // Activity callbacks must reach Flutter for plugins and OS integration.
    override fun onPostResume() {
        super.onPostResume()
        flutterFragment?.onPostResume()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        flutterFragment?.onNewIntent(intent)
    }

    @Deprecated("Forward legacy results for Flutter plugins")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        flutterFragment?.onActivityResult(requestCode, resultCode, data)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        flutterFragment?.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        flutterFragment?.onUserLeaveHint()
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        flutterFragment?.onTrimMemory(level)
    }

    companion object {
        private const val FLUTTER_TAG = "embedded_flutter_page"
    }
}
