//
//  RNDamageCamera.m
//  deep.mobile
//
//  Created by Drake Svoboda on 9/28/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

// #import "DamageCameraViewBridge.h"

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(DamageCameraViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(onDamageDetected, RCTDirectEventBlock);

@end
