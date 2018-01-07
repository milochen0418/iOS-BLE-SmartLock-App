//
//  GlobalVars.h
//  SmartLock
//
//  Created by Milo Chen on 2/24/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLECentralRole.h"

@interface GlobalVars : NSObject

@property (nonatomic,strong) BLECentralRole* mBLECentralRole;

+ (GlobalVars*) sharedInstance;


@end
