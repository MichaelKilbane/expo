// Copyright 2018-present 650 Industries. All rights reserved.

#import <ABI45_0_0React/ABI45_0_0RCTBridgeModule.h>

#import <ABI45_0_0ExpoModulesCore/ABI45_0_0EXInternalModule.h>
#import <ABI45_0_0ExpoModulesCore/ABI45_0_0EXModuleRegistry.h>

// ABI45_0_0RCTBridgeModule capable of receiving method calls from JS and forwarding them
// to proper exported universal modules. Also, it exports important constants to JS, like
// properties of exported methods and modules' constants.

// Swift compatibility headers (e.g. `ExpoModulesCore-Swift.h`) are not available in headers,
// so we use class forward declaration here. Swift header must be imported in the `.m` file.
@class SwiftInteropBridge;
@class ModulesProvider;

NS_SWIFT_NAME(NativeModulesProxy)
@interface ABI45_0_0EXNativeModulesProxy : NSObject <ABI45_0_0RCTBridgeModule>

@property (nonatomic, strong) SwiftInteropBridge *swiftInteropBridge;

- (nonnull instancetype)init;
- (nonnull instancetype)initWithModuleRegistry:(nullable ABI45_0_0EXModuleRegistry *)moduleRegistry;

- (void)callMethod:(NSString *)moduleName methodNameOrKey:(id)methodNameOrKey arguments:(NSArray *)arguments resolver:(ABI45_0_0RCTPromiseResolveBlock)resolve rejecter:(ABI45_0_0RCTPromiseRejectBlock)reject;
- (id)callMethodSync:(NSString *)moduleName methodName:(NSString *)methodName arguments:(NSArray *)arguments;

+ (ModulesProvider *)getExpoModulesProvider;

@end
