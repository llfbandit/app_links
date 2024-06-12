import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'app_links_method_channel.dart';

/// Callback when your app is woke up by an incoming link
/// [uri] and [stringUri] are same value.
/// [stringUri] is available for custom handling like uppercased uri.
///
typedef OnAppLinkFunction = void Function(Uri uri, String stringUri);

/// The interface that implementations of app_links must implement.
///
/// Platform implementations should extend this class rather than implement it
/// as app_links does not consider newly added methods to be breaking changes.
/// Extending this class ensures that the subclass will get the default
/// implementation, while platform implementations that merely implement the
/// interface will be broken by newly added [AppLinksPlatform] functions.
abstract class AppLinksPlatform extends PlatformInterface {
  /// A token used for verification of subclasses to ensure they extend this
  /// class instead of implementing it.
  static const _token = Object();

  /// Constructs a [AppLinksPlatform].
  AppLinksPlatform() : super(token: _token);

  static AppLinksPlatform _instance = AppLinksMethodChannel();

  /// The default instance of [AppLinksPlatform] to use.
  ///
  /// Defaults to [AppLinksMethodChannel].
  static AppLinksPlatform get instance => _instance;

  /// Platform-specific plugins should set this to an instance of their own
  /// platform-specific class that extends [AppLinksPlatform] when they register
  /// themselves.
  static set instance(AppLinksPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Gets the initial / first link
  ///
  /// returns [Uri] or [null]
  Future<Uri?> getInitialLink() => throw UnimplementedError(
        'getInitialLink() not implemented on the current platform.',
      );

  /// Gets the initial / first link
  ///
  /// returns [Uri] as String or [null]
  Future<String?> getInitialLinkString() => throw UnimplementedError(
        'getInitialLinkString not implemented on the current platform.',
      );

  /// Gets the latest link
  ///
  /// returns [Uri] or [null]
  Future<Uri?> getLatestLink() => throw UnimplementedError(
        'getLatestLink not implemented on the current platform.',
      );

  /// Gets the latest link
  ///
  /// returns [Uri] as String or [null]
  Future<String?> getLatestLinkString() {
    throw UnimplementedError(
      'getLatestLinkString not implemented on the current platform.',
    );
  }

  /// Stream for receiving all incoming URI events as [String].
  ///
  /// The [Stream] emits opened URI as [String]s.
  Stream<String> get stringLinkStream => throw UnimplementedError(
      'stringUriStream not implemented on the current platform.');

  /// Stream for receiving all incoming URI events as [Uri].
  ///
  /// The [Stream] emits opened URI as [Uri]s.
  Stream<Uri> get uriLinkStream => throw UnimplementedError(
      'uriStream not implemented on the current platform.');
}
