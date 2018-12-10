
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TokenSource, NSObject)

RCT_EXTERN_METHOD(get)

RCT_EXTERN_METHOD(get: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)


RCT_EXTERN_METHOD(set:(NSString *)token)

RCT_EXTERN_METHOD(remove)

@end
