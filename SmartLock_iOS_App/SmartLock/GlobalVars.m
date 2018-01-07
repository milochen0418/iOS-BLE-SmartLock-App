//
//  GlobalVars.m
//  SmartLock
//
//  Created by Milo Chen on 2/24/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import "GlobalVars.h"

@implementation GlobalVars


@synthesize mBLECentralRole;


static GlobalVars* staticGlobalVars = nil;
+ (GlobalVars*) sharedInstance {
    if(staticGlobalVars == nil) {
        staticGlobalVars = [[GlobalVars alloc]init];
    }
    return staticGlobalVars;
}



@end
