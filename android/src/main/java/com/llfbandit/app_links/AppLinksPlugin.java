package com.llfbandit.app_links;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;

/**
 * AppLinksPlugin
 */
public class AppLinksPlugin
        extends BroadcastReceiver
        implements FlutterPlugin, MethodCallHandler, ActivityAware, NewIntentListener {

  private static final String MESSAGES_CHANNEL = "com.llfbandit.app_links/messages";
  private static final String TAG = "com.llfbandit.app_links";

  // The MethodChannel that will the communication between Flutter and native
  // Android
  //
  // This local reference serves to register the plugin with the Flutter Engine
  // and unregister it
  // when the Flutter Engine is detached from the Activity
  private MethodChannel methodChannel;

  private Activity mainActivity;

  // Initial link
  private String initialLink;

  // Latest link
  private String latestLink;

  /////////////////////////////////////////////////////////////////////////////
  /// FlutterPlugin
  ///
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    methodChannel = new MethodChannel(binding.getBinaryMessenger(), MESSAGES_CHANNEL);
    methodChannel.setMethodCallHandler(this);

    IntentFilter intentFilter = new IntentFilter();
    intentFilter.addAction(Intent.ACTION_VIEW);

    LocalBroadcastManager manager = LocalBroadcastManager.getInstance(binding.getApplicationContext());
    manager.registerReceiver(this, intentFilter);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    methodChannel.setMethodCallHandler(null);
    LocalBroadcastManager.getInstance(binding.getApplicationContext()).unregisterReceiver(this);
    initialLink = null;
    latestLink = null;
  }
  ///
  /// END FlutterPlugin
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  /// MethodCallHandler
  ///
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getLatestAppLink")) {
      result.success(latestLink);
    } else if (call.method.equals("getInitialAppLink")) {
      result.success(initialLink);
    } else {
      result.notImplemented();
    }
  }
  ///
  /// END MethodCallHandler
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  /// ActivityAware
  ///
  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    binding.addOnNewIntentListener(this);
    this.mainActivity = binding.getActivity();

    if (mainActivity.getIntent() == null) {
      return;
    }

    final int flag = Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY;
    if ((mainActivity.getIntent().getFlags() & flag) != flag) {
      onNewIntent(mainActivity.getIntent());
    }
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    binding.addOnNewIntentListener(this);
    this.mainActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    this.mainActivity = null;
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    this.mainActivity = null;
  }
  ///
  /// END ActivityAware
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  /// BroadcastReceiver
  ///
  @Override
  public void onReceive(Context context, Intent intent) {
    handleIntent(intent);
  }
  ///
  /// END BroadcastReceiver
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  /// NewIntentListener
  ///
  @Override
  public boolean onNewIntent(Intent intent) {
    if (handleIntent(intent)) {
      mainActivity.setIntent(intent);
      return true;
    }

    return false;
  }
  ///
  /// END NewIntentListener
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  /// AppLinksPlugin
  ///
  private boolean handleIntent(Intent intent) {
    if (intent == null) {
      return false;
    }

    Log.d(TAG, "handleIntent: (Action) " + intent.getAction());
    Log.d(TAG, "handleIntent: (Data) " + intent.getDataString());

    String appLinkData = intent.getDataString();
    if (appLinkData != null) {
      if (initialLink == null) {
        initialLink = appLinkData;
      }

      latestLink = appLinkData;
      methodChannel.invokeMethod("onAppLink", latestLink);
      return true;
    }

    return false;
  }
  ///
  /// END AppLinksPlugin
  /////////////////////////////////////////////////////////////////////////////
}
