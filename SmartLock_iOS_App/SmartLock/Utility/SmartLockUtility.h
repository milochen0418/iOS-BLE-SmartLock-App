//
//  SmartLockUtility.h
//  SmartLock
//
//  Created by Milo Chen on 3/3/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SmartLockUtility : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>
+ (SmartLockUtility*) sharedInstance;

-(void) requestOwnerDoLockWithComplete: (void(^)(BOOL isConnectFailed))complete;
-(void) requestOwnerDoUnlockWithComplete: (void(^)(BOOL isConnectFailed))complete;
-(void) requestGuestDoLockWithComplete: (void(^)(BOOL isConnectFailed))complete;
-(void) requestGuestDoUnlockWithComplete: (void(^)(BOOL isConnectFailed))complete;
-(void) requestGiveKeyWithComplete: (void(^)(BOOL isConnectFailed))complete;
-(void) requestReturnKeyWithComplete: (void(^)(BOOL isConnectFailed))complete;
-(void) requestInReceivingWithComplete: (void(^)(BOOL isConnectFailed))complete;
-(void) requestNotInReceivingWithComplete: (void(^)(BOOL isConnectFailed))complete;


-(void) requestGetLockStatusWithComplete: (void(^)(uint8_t ch, BOOL isConnectFailed))complete; //ch == 'L' -> Lock, ch=='U' -> Unlock
-(void) requestGetKeyStatusWithComplete: (void(^)(uint8_t ch, BOOL isConnectFailed))complete; //ch == 'K' -> key has give, ch=='k' -> key has not give
-(void) requestIsInReceivingWithComplete: (void(^)(uint8_t ch, BOOL isConnectFailed))complete;//ch == 'I' -> guest is waiting to receiving key, ch=='i' -> guest is not waiting to receiving key

@end
