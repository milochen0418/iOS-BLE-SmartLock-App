//
//  BLECentralRole.h
//  SmartLock
//
//  Created by Milo Chen on 2/24/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface BLECentralRole : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

-(void) startCentralRole ;


- (IBAction)ericBLESendLedOn:(id)sender;
- (IBAction)ericBLESendLedOff:(id)sender;
- (IBAction)ericBLEConnectHMSoft:(id)sender ;
-(void) setOnBleRecvStringListener: (void(^)(NSData*,int))listener ;
-(void) requestBLEIntoConnectStatus;
-(void) requestBLEIntoDisconnectStatus;


@end
