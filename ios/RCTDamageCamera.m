//
//  RNDamageCamera.m
//  deep.mobile
//
//  Created by Drake Svoboda on 9/28/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

// Makes RCTDamageCameraManager visible to react native
@interface RCT_EXTERN_MODULE(RCTDamageCameraManager, RCTViewManager)

RCT_EXTERN_METHOD(capture :(RCTPromiseResolveBlock)resolve
                        rejecter:(RCTPromiseRejectBlock)reject)

@end
