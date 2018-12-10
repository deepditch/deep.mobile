//
//  Created by Drake Svoboda on 9/28/18.
//  Copyright © 2018 Drake Svoboda. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(DamageCameraViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(onDamageDetected, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onDamageReported, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onDownloadProgress, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onDownloadComplete, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(previousReports, NSDictionary);

@end
