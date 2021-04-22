#import "BatchFlutterPluginTrampoline.h"
#if __has_include(<batch_flutter/batch_flutter-Swift.h>)
#import <batch_flutter/batch_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "batch_flutter-Swift.h"
#endif

@implementation BatchFlutterPluginTrampoline
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [BatchFlutterPlugin registerWithRegistrar:registrar];
}
@end
