//
//  HookCoreManager.h
//  HookCore
//
//  Created by iwalben on 2020/4/24.
//  Copyright © 2020 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HookCoreManager : NSObject
+(void)hookAllMethodForClass:(id)hc_class;
@end

NS_ASSUME_NONNULL_END
