package com.llfbandit.app_links;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.UUID;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;

/**
 * AppLinksPlugin
 */
public class AppLinksPlugin implements
    FlutterPlugin,
    MethodCallHandler,
    EventChannel.StreamHandler,
    ActivityAware,
    ActivityPluginBinding.OnSaveInstanceStateListener,
    NewIntentListener {

  private static final String MESSAGES_CHANNEL = "com.llfbandit.app_links/messages";
  private static final String EVENTS_CHANNEL = "com.llfbandit.app_links/events";
  private static final String LAUNCH_HANDLED_KEY = "com.llfbandit.app_links/launchHandledBy";

  // The MethodChannel that will the communication between Flutter and native
  // Android
  //
  // This local reference serves to register the plugin with the Flutter Engine
  // and unregister it
  // when the Flutter Engine is detached from the Activity
  private MethodChannel methodChannel;
  // Channel for communicating with flutter using async stream
  private EventChannel eventChannel;
  // Event producer to handle new intents when app is opened
  private EventChannel.EventSink eventSink;

  ActivityPluginBinding binding;

  // Initial link
  private String initialLink;
  private boolean initialLinkSent = false;

  // Latest link
  private String latestLink;

  // Marks saved state. Changes with each process.
  private final String instanceId = UUID.randomUUID().toString();
  // Launch intent to handle after restore
  private Intent pendingLaunchIntent;
  private final Handler mainHandler = new Handler(Looper.getMainLooper());

  /////////////////////////////////////////////////////////////////////////////
  /// FlutterPlugin
  ///
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    methodChannel = new MethodChannel(binding.getBinaryMessenger(), MESSAGES_CHANNEL);
    methodChannel.setMethodCallHandler(this);

    eventChannel = new EventChannel(binding.getBinaryMessenger(), EVENTS_CHANNEL);
    eventChannel.setStreamHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    methodChannel.setMethodCallHandler(null);
    eventChannel.setStreamHandler(null);
  }
  ///
  /// END FlutterPlugin
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  /// MethodCallHandler
  ///
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    flushPendingLaunchIntent();

    if (call.method.equals("getLatestLink")) {
      result.success(latestLink);
    } else if (call.method.equals("getInitialLink")) {
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
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.binding = binding;
    binding.addOnNewIntentListener(this);
    binding.addOnSaveStateListener(this);

    // Handle the intent after restore. The post covers hosts that skip restore.
    pendingLaunchIntent = binding.getActivity().getIntent();
    mainHandler.post(this::flushPendingLaunchIntent);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    this.binding = binding;
    binding.addOnNewIntentListener(this);
    binding.addOnSaveStateListener(this);
  }

  @Override
  public void onDetachedFromActivity() {
    flushPendingLaunchIntent();

    if (binding != null) {
      binding.removeOnNewIntentListener(this);
      binding.removeOnSaveStateListener(this);
    }
    binding = null;
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }
  ///
  /// END ActivityAware
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  /// OnSaveInstanceStateListener
  ///
  @Override
  public void onSaveInstanceState(@NonNull Bundle bundle) {
    bundle.putString(LAUNCH_HANDLED_KEY, instanceId);
  }

  @Override
  public void onRestoreInstanceState(@Nullable Bundle bundle) {
    // Skip the link this engine already sent.
    if (bundle != null && instanceId.equals(bundle.getString(LAUNCH_HANDLED_KEY))) {
      pendingLaunchIntent = null;
    }

    flushPendingLaunchIntent();
  }
  ///
  /// END OnSaveInstanceStateListener
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  /// EventChannel.StreamHandler
  ///
  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    flushPendingLaunchIntent();
    this.eventSink = eventSink;

    if (!initialLinkSent && initialLink != null) {
      initialLinkSent = true;
      eventSink.success(initialLink);
    }
  }

  @Override
  public void onCancel(Object o) {
    eventSink = null;
  }
  ///
  /// END EventChannel.StreamHandler
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  /// NewIntentListener
  ///
  @Override
  public boolean onNewIntent(@NonNull Intent intent) {
    flushPendingLaunchIntent();
    return handleIntent(intent);
  }
  ///
  /// END NewIntentListener
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  /// AppLinksPlugin
  ///
  private void flushPendingLaunchIntent() {
    Intent intent = pendingLaunchIntent;
    pendingLaunchIntent = null;
    handleIntent(intent);
  }

  private boolean handleIntent(Intent intent) {
    if (intent == null) return false;

    final int flag = Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY;
    if ((intent.getFlags() & flag) == flag) {
      return false;
    }

    String dataString = AppLinksHelper.getUrl(intent);
    if (dataString == null) return false;

    if (initialLink == null) {
      initialLink = dataString;
    }

    latestLink = dataString;

    if (eventSink != null) {
      initialLinkSent = true;
      eventSink.success(dataString);
    }

    return true;
  }

  ///
  /// END AppLinksPlugin
  /////////////////////////////////////////////////////////////////////////////
}
