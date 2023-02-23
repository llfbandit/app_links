#import "AppLinksPlugin.h"
#if __has_include(<app_links/app_links-Swift.h>)
#import <app_links/app_links-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "app_links-Swift.h"
#endif

@implementation AppLinksPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppLinksPlugin registerWithRegistrar:registrar];
}
@end
