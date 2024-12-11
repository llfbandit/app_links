import {
  AbilityAware,
  AbilityPluginBinding,
  EventChannel,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  NewWantListener,
} from '@ohos/flutter_ohos';

import { EventSink, StreamHandler } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import { Want } from '@kit.AbilityKit';

const MESSAGES_CHANNEL = "com.llfbandit.app_links/messages";
const EVENTS_CHANNEL = "com.llfbandit.app_links/events";

/** AppLinksOhosPlugin **/
export default class AppLinksOhosPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware, StreamHandler, NewWantListener {
  private abilityPluginBinding: AbilityPluginBinding | null = null;
  private messageChannel: MethodChannel | null = null;
  private eventChannel?: EventChannel = undefined;
  // Initial link
  private initialLink?: string | null = null;
  private initialLinkSent: boolean = false;
  // Latest link
  private latestLink?: string | null = null;
  private eventSink: EventSink | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "AppLinksOhosPlugin"
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.abilityPluginBinding = binding
    binding.addOnNewWantListener(this)
    this.handleWantLink(binding.getAbility().launchWant);
  }

  onDetachedFromAbility(): void {
    if (this.abilityPluginBinding != null) {
      this.abilityPluginBinding.removeOnNewWantListener(this)
    }
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.messageChannel = new MethodChannel(binding.getBinaryMessenger(), MESSAGES_CHANNEL);
    this.messageChannel.setMethodCallHandler(this)

    this.eventChannel = new EventChannel(binding.getBinaryMessenger(), EVENTS_CHANNEL)
    this.eventChannel.setStreamHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.messageChannel != null) {
      this.messageChannel.setMethodCallHandler(null)
    }
    if (this.eventChannel != null) {
      this.eventChannel.setStreamHandler(null)
    }
  }

  onListen(args: ESObject, events: EventSink): void {
    this.eventSink = events;
    if (!this.initialLinkSent && this.initialLink != null) {
      this.initialLinkSent = true;
      events.success(this.initialLink);
    }
  }

  onCancel(args: ESObject): void {
    this.eventSink = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == 'getLatestLink') {
      result.success(this.latestLink);
    } else if (call.method == 'getInitialLink') {
      result.success(this.initialLink);
    } else {
      result.notImplemented();
    }
  }

  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void {
    this.handleWantLink(want);
  }

  private handleWantLink(want: Want): void {
    const dataString = want.uri;
    if (typeof dataString !== 'string') {
      return;
    }
    if (this.initialLink == null) {
      this.initialLink = dataString;
    }

    this.latestLink = dataString;

    if (this.eventSink != null) {
      this.initialLinkSent = true;
      this.eventSink.success(dataString);
    }
  }
}