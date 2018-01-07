//
//  SmartLockUtility.m
//  SmartLock
//
//  Created by Milo Chen on 3/3/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import "SmartLockUtility.h"
#import "iToast.h"
#define IS_TEST_SMART_LOCK YES


@interface SmartLockUtility()

//START original BLE process
@property (nonatomic,strong) CBCentralManager * mCM;
@property (nonatomic,strong) CBPeripheral * mHMSoftPeripheral;
@property (nonatomic,copy) void (^mDataRecvListener)(NSData* data, int length);
@property (nonatomic,strong) NSMutableArray* mDevices;
@property (nonatomic,strong) NSMutableArray * mSensors;
@property (nonatomic,strong) NSTimer * mScanTimeoutTimer;
//END original BLE process



@property (nonatomic,copy) void (^mGetKeyStatusCompleteListener)(uint8_t ch, BOOL isConnectFailed);
@property (nonatomic,copy) void (^mIsInReceivingCompleteListener)(uint8_t ch, BOOL isConnectFailed);
@property (nonatomic,copy) void (^mGetLockStatusCompleteListener)(uint8_t ch, BOOL isConnectFailed);


@property (nonatomic,copy) void (^mOwnerDoLockCompleteListener)(BOOL isConnectFailed);
@property (nonatomic,copy) void (^mOwnerDoUnlockCompleteListener)(BOOL isConnectFailed);
@property (nonatomic,copy) void (^mGuestDoLockCompleteListener)(BOOL isConnectFailed);
@property (nonatomic,copy) void (^mGuestDoUnlockCompleteListener)(BOOL isConnectFailed);
@property (nonatomic,copy) void (^mGiveKeyCompleteListener)(BOOL isConnectFailed);
@property (nonatomic,copy) void (^mReturnKeyCompleteListener)(BOOL isConnectFailed);
@property (nonatomic,copy) void (^mInReceivingCompleteListener)(BOOL isConnectFailed);
@property (nonatomic,copy) void (^mNotInReceivingCompleteListener)(BOOL isConnectFailed);


@property (nonatomic,copy) void (^mSendByteBlock)(void);
@property (nonatomic,copy) void (^mRecvByteBlock)(uint8_t ch);
@property (nonatomic,copy) void (^mConnFailedBlock)(void);
@property (nonatomic,copy) void (^mOperationCompleteBlock)(void);


@property (nonatomic) BOOL mIsOperationInBLE;



//each operation in SmartLockUtility is to scan->connect->send request-> (wait response) -> disconnect
//if BLE is start to scan, mIsOperationInBLE will high. And mIsOperationInBLE will low when BLE is disconnect



@end

@implementation SmartLockUtility

@synthesize mHMSoftPeripheral,mCM,mDataRecvListener, mDevices, mScanTimeoutTimer;



@synthesize mGetKeyStatusCompleteListener,mGetLockStatusCompleteListener,mGiveKeyCompleteListener,mGuestDoLockCompleteListener,mGuestDoUnlockCompleteListener,mInReceivingCompleteListener,mIsInReceivingCompleteListener,mNotInReceivingCompleteListener,mOwnerDoLockCompleteListener,mOwnerDoUnlockCompleteListener,mReturnKeyCompleteListener;


-(void) makeAllListenerNil {
    mGetKeyStatusCompleteListener = nil;
    mGetLockStatusCompleteListener = nil;
    mGiveKeyCompleteListener = nil;
    mGuestDoLockCompleteListener = nil;
    mGuestDoUnlockCompleteListener = nil;
    mInReceivingCompleteListener = nil;
    mIsInReceivingCompleteListener = nil;
    mNotInReceivingCompleteListener = nil;
    mOwnerDoLockCompleteListener = nil;
    mOwnerDoUnlockCompleteListener = nil;
    mReturnKeyCompleteListener = nil;
}


@synthesize mIsOperationInBLE;
@synthesize mSendByteBlock;
@synthesize mRecvByteBlock;
@synthesize mConnFailedBlock;
@synthesize mOperationCompleteBlock;



static SmartLockUtility* sUtility = nil;
+ (SmartLockUtility*) sharedInstance {
    if(sUtility == nil) {
        sUtility = [[SmartLockUtility alloc]init];
        [sUtility doBLEScan];
    }
    return sUtility;
}

-(void)doBLEScan {
    self.mDevices = [[NSMutableArray alloc] init];
    self.mSensors = [[NSMutableArray alloc] init];
    //self.title = @"BLE Device Scan";
    //[self.tableView reloadData];
    
    [self setOnBleRecvStringListener:^(NSData * data, int length) {
        dispatch_async(dispatch_get_main_queue(),^{
            NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"callback from RootTableViewController to ViewController %@ ", newStr);
            NSString * str = [NSString stringWithFormat:@"recv: %@",newStr];
            [[[[iToast makeText:NSLocalizedString(str, @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationShort ] show];
            
            if(length >= 1 ) {
                if (mRecvByteBlock != nil) {
                    uint8_t * bytePtr = (uint8_t  * )[data bytes];
                    uint8_t ch = bytePtr[0];
                    mRecvByteBlock(ch);
                }
            }
        });
    }];
    
    [self ericBLEInit];
}



-(void) turnOnOperationInBLEWithSendByteBlock:(void(^)(void)) sendByteBlock andRecvByteBlock: (void(^)(uint8_t ch)) recvByteBlock andConnFailedBlock:(void(^)(void))connFailedBlock andOperationCompleteBlock:(void(^)(void))operationCompleteBlock {
    if(mIsOperationInBLE == YES) return;
    mIsOperationInBLE = YES;

    mSendByteBlock = sendByteBlock;
    mRecvByteBlock = recvByteBlock;
    mConnFailedBlock = connFailedBlock;
    mOperationCompleteBlock = operationCompleteBlock;
    
    
    [self doBLEScan];
}



-(void) turnOffOperationInBLEWithComplete:(void(^)(void)) complete{
    if(mIsOperationInBLE == NO) return;
    mIsOperationInBLE = NO;


    //some process
    

    if(complete != nil) {
        complete();
    }
    //mSendByteBlock = nil;
    //mRecvByteBlock = nil;
    //mConnFailedBlock = nil;
    //mOperationCompleteBlock = nil;
}




-(void) requestOwnerDoLockWithComplete: (void(^)(BOOL isConnectFailed))complete {
    if(mIsOperationInBLE) return;
    [self makeAllListenerNil];
    mOwnerDoLockCompleteListener = complete;
    [self turnOnOperationInBLEWithSendByteBlock:^{
        [self SmartLock_OwnerDoLock];
    }
    andRecvByteBlock:^(uint8_t ch){
        NSLog(@"RecvByteBlock %c", ch);
    }
    andConnFailedBlock:^{
        if(mOwnerDoLockCompleteListener!=nil) mOwnerDoLockCompleteListener(YES);
    }
    andOperationCompleteBlock:^{
        if(mOwnerDoLockCompleteListener!=nil) mOwnerDoLockCompleteListener(NO);
    }];
}



-(void) requestOwnerDoUnlockWithComplete: (void(^)(BOOL isConnectFailed))complete {
    if(mIsOperationInBLE) return;
    [self makeAllListenerNil];
    mOwnerDoUnlockCompleteListener = complete;
    [self turnOnOperationInBLEWithSendByteBlock:^{
        [self SmartLock_OwnerDoUnlock];
    }
    andRecvByteBlock:^(uint8_t ch){
        NSLog(@"RecvByteBlock %c", ch);
    }
    andConnFailedBlock:^{
        if(mOwnerDoUnlockCompleteListener!=nil) mOwnerDoUnlockCompleteListener(YES);
    }
    andOperationCompleteBlock:^{
        if(mOwnerDoUnlockCompleteListener!=nil) mOwnerDoUnlockCompleteListener(NO);
    }];
}

-(void) requestGuestDoLockWithComplete: (void(^)(BOOL isConnectFailed))complete {
    if(mIsOperationInBLE) return;
    [self makeAllListenerNil];
    mGuestDoLockCompleteListener = complete;
    [self turnOnOperationInBLEWithSendByteBlock:^{
        [self SmartLock_GuestDoLock];
    }
    andRecvByteBlock:^(uint8_t ch){
        NSLog(@"RecvByteBlock %c", ch);
    }
    andConnFailedBlock:^{
        if(mGuestDoLockCompleteListener!=nil) mGuestDoLockCompleteListener(YES);
    }
    andOperationCompleteBlock:^{
        if(mGuestDoLockCompleteListener!=nil) mGuestDoLockCompleteListener(NO);
    }];
}

-(void) requestGuestDoUnlockWithComplete: (void(^)(BOOL isConnectFailed))complete {
    if(mIsOperationInBLE) return;
    [self makeAllListenerNil];
    mGuestDoUnlockCompleteListener = complete;
    [self turnOnOperationInBLEWithSendByteBlock:^{
        [self SmartLock_GuestDoUnlock];
    }
    andRecvByteBlock:^(uint8_t ch){
        NSLog(@"RecvByteBlock %c", ch);
    }
    andConnFailedBlock:^{
        if(mGuestDoUnlockCompleteListener!=nil) mGuestDoUnlockCompleteListener(YES);
    }
    andOperationCompleteBlock:^{
        if(mGuestDoUnlockCompleteListener!=nil) mGuestDoUnlockCompleteListener(NO);
    }];
}

-(void) requestGiveKeyWithComplete: (void(^)(BOOL isConnectFailed))complete {
    if(mIsOperationInBLE) return;
    [self makeAllListenerNil];
    mGiveKeyCompleteListener = complete;
    [self turnOnOperationInBLEWithSendByteBlock:^{
        [self SmartLock_GiveKey];
    }
    andRecvByteBlock:^(uint8_t ch){
        NSLog(@"RecvByteBlock %c", ch);
    }
    andConnFailedBlock:^{
        if(mGiveKeyCompleteListener!=nil) mGiveKeyCompleteListener(YES);
    }
    andOperationCompleteBlock:^{
        if(mGiveKeyCompleteListener!=nil) mGiveKeyCompleteListener(NO);
    }];
}

-(void) requestReturnKeyWithComplete: (void(^)(BOOL isConnectFailed))complete {
    if(mIsOperationInBLE) return;
    [self makeAllListenerNil];
    mReturnKeyCompleteListener = complete;
    [self turnOnOperationInBLEWithSendByteBlock:^{
        [self SmartLock_ReturnKey];
    }
    andRecvByteBlock:^(uint8_t ch){
        NSLog(@"RecvByteBlock %c", ch);
    }
    andConnFailedBlock:^{
        if(mReturnKeyCompleteListener!=nil) mReturnKeyCompleteListener(YES);
    }
    andOperationCompleteBlock:^{
        if(mReturnKeyCompleteListener!=nil) mReturnKeyCompleteListener(NO);
    }];
}
-(void) requestInReceivingWithComplete: (void(^)(BOOL isConnectFailed))complete {
    if(mIsOperationInBLE) return;
    [self makeAllListenerNil];
    mInReceivingCompleteListener = complete;
    [self turnOnOperationInBLEWithSendByteBlock:^{
        [self SmartLock_InReceiving];
    }
    andRecvByteBlock:^(uint8_t ch){
        NSLog(@"RecvByteBlock %c", ch);
    }
    andConnFailedBlock:^{
        if(mInReceivingCompleteListener!=nil) mInReceivingCompleteListener(YES);
    }
    andOperationCompleteBlock:^{
        if(mInReceivingCompleteListener!=nil) mInReceivingCompleteListener(NO);
    }];
    
    
}
-(void) requestNotInReceivingWithComplete: (void(^)(BOOL isConnectFailed))complete {
    if(mIsOperationInBLE) return;
    [self makeAllListenerNil];
    mNotInReceivingCompleteListener = complete;
    [self turnOnOperationInBLEWithSendByteBlock:^{
        [self SmartLock_NotInReceiving];
    }
    andRecvByteBlock:^(uint8_t ch){
        NSLog(@"RecvByteBlock %c", ch);
    }
    andConnFailedBlock:^{
        if(mNotInReceivingCompleteListener!=nil) mNotInReceivingCompleteListener(YES);
    }
    andOperationCompleteBlock:^{
        if(mNotInReceivingCompleteListener!=nil) mNotInReceivingCompleteListener(NO);
    }];

}


-(void) requestGetLockStatusWithComplete: (void(^)(uint8_t ch, BOOL isConnectFailed))complete //ch == 'L' -> Lock, ch=='U' -> Unlock
{
    if(mIsOperationInBLE) return;
    static BOOL sIsRecvByte = YES;
    static uint8_t sRecvCh = 0x00;
    sIsRecvByte = NO;
    sRecvCh = 0x00;
    

    [self makeAllListenerNil];
    mGetLockStatusCompleteListener = complete;
    [self turnOnOperationInBLEWithSendByteBlock:^{
        [self SmartLock_GetLockStatus];
    }
    andRecvByteBlock:^(uint8_t ch){
        NSLog(@"RecvByteBlock %c", ch);
        sRecvCh = ch;
        sIsRecvByte = YES;
        //[mCM cancelPeripheralConnection:mHMSoftPeripheral];
        [self SmartLock_TerminateConnection];
    }
    andConnFailedBlock:^{
        //if(mOwnerDoUnlockCompleteListener!=nil) mOwnerDoUnlockCompleteListener(YES);
        if(mGetLockStatusCompleteListener!=nil) {
            mGetLockStatusCompleteListener(0x00, YES);
        }
    }
    andOperationCompleteBlock:^{
        if(mGetLockStatusCompleteListener!=nil) {
            if(sIsRecvByte == NO) {
                mGetLockStatusCompleteListener(0x00, YES);
            }
            else {
                mGetLockStatusCompleteListener(sRecvCh, NO);
            }
        }
    }];    
}
-(void) requestGetKeyStatusWithComplete: (void(^)(uint8_t ch, BOOL isConnectFailed))complete //ch == 'K' -> key has give, ch=='k' -> key has not give
{
    if(mIsOperationInBLE) return;
    static BOOL sIsRecvByte = YES;
    static uint8_t sRecvCh = 0x00;
    sIsRecvByte = NO;
    sRecvCh = 0x00;
    

    [self makeAllListenerNil];
    mGetKeyStatusCompleteListener = complete;
    [self turnOnOperationInBLEWithSendByteBlock:^{
        [self SmartLock_GetKeyStatus];
    }
    andRecvByteBlock:^(uint8_t ch){
        NSLog(@"RecvByteBlock %c", ch);
        sRecvCh = ch;
        sIsRecvByte = YES;
        //[mCM cancelPeripheralConnection:mHMSoftPeripheral];
        [self SmartLock_TerminateConnection];
    }
    andConnFailedBlock:^{
        //if(mOwnerDoUnlockCompleteListener!=nil) mOwnerDoUnlockCompleteListener(YES);
        if(mGetKeyStatusCompleteListener!=nil) {
            mGetKeyStatusCompleteListener(0x00, YES);
        }
    }
    andOperationCompleteBlock:^{
        if(mGetKeyStatusCompleteListener!=nil) {
            if(sIsRecvByte == NO) {
                mGetKeyStatusCompleteListener(0x00, YES);
            }
            else {
                mGetKeyStatusCompleteListener(sRecvCh, NO);
            }
        }
    }];
}


-(void) requestIsInReceivingWithComplete: (void(^)(uint8_t ch, BOOL isConnectFailed))complete //ch == 'I' -> guest is waiting to receiving key, ch=='i' -> guest is not
{
    if(mIsOperationInBLE) return;
    static BOOL sIsRecvByte = YES;
    static uint8_t sRecvCh = 0x00;
    sIsRecvByte = NO;
    sRecvCh = 0x00;
    

    [self makeAllListenerNil];
    mIsInReceivingCompleteListener = complete;
    [self turnOnOperationInBLEWithSendByteBlock:^{
        [self SmartLock_IsInReceiving];
    }
    andRecvByteBlock:^(uint8_t ch){
        NSLog(@"RecvByteBlock %c", ch);
        sRecvCh = ch;
        sIsRecvByte = YES;
        //[mCM cancelPeripheralConnection:mHMSoftPeripheral];
        [self SmartLock_TerminateConnection];
    }
    andConnFailedBlock:^{
        //if(mOwnerDoUnlockCompleteListener!=nil) mOwnerDoUnlockCompleteListener(YES);
        if(mIsInReceivingCompleteListener!=nil) {
            mIsInReceivingCompleteListener(0x00, YES);
        }
    }
    andOperationCompleteBlock:^{
        if(mIsInReceivingCompleteListener!=nil) {
            if(sIsRecvByte == NO) {
                mIsInReceivingCompleteListener(0x00, YES);
            }
            else {
                mIsInReceivingCompleteListener(sRecvCh, NO);
            }
        }
    }];
}








#pragma mark - CoreBluetooth CentralManager functions


-(void)centralManagerDidUpdateState:(CBCentralManager*)cManager
{
    NSMutableString* nsmstring=[NSMutableString stringWithString:@"UpdateState:"];
    BOOL isWork=FALSE;
    switch (cManager.state) {
        case CBCentralManagerStateUnknown:
            [nsmstring appendString:@"Unknown\n"];
            break;
        case CBCentralManagerStateUnsupported:
            [nsmstring appendString:@"Unsupported\n"];
            break;
        case CBCentralManagerStateUnauthorized:
            [nsmstring appendString:@"Unauthorized\n"];
            break;
        case CBCentralManagerStateResetting:
            [nsmstring appendString:@"Resetting\n"];
            break;
        case CBCentralManagerStatePoweredOff:
            [nsmstring appendString:@"PoweredOff\n"];
            //change by milochen
            /*
             if (connectedPeripheral!=NULL){
             [CM cancelPeripheralConnection:connectedPeripheral];
             }
             */
            
            break;
        case CBCentralManagerStatePoweredOn:
            [nsmstring appendString:@"PoweredOn\n"];
            isWork=TRUE;
            //add by milochen for scan int default
            //[cManager scanForPeripheralsWithServices:nil options:nil];
            
            
            [[[[iToast makeText:NSLocalizedString(@"scan start 5 sec.", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationShort ] show];
            if(mScanTimeoutTimer != nil ) {
                [mScanTimeoutTimer invalidate];
                mScanTimeoutTimer = nil;
            }
            
            mScanTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(scanTimeout:) userInfo:nil repeats:NO];
            
            
            [cManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFAB"]] options:nil];
            
            //[self ericBLEInit];
            
            break;
        default:
            [nsmstring appendString:@"none\n"];
            break;
    }
    NSLog(@"%@",nsmstring);
    //[delegate didUpdateState:isWork message:nsmstring getStatus:cManager.state];
}








- (void) scanTimeout:(NSTimer*)timer
{
    if (mCM!=NULL){
        [mCM stopScan];
        if(mScanTimeoutTimer != nil) {
            [mScanTimeoutTimer invalidate];
            mScanTimeoutTimer = nil;
        }
        [[[[iToast makeText:NSLocalizedString(@"timeout to stop scan", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationShort ] show];
    }else{
        NSLog(@"CM is Null!");
    }
    NSLog(@"scanTimeout function is done");
}


-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    /*
     NSMutableString* nsmstring=[NSMutableString stringWithString:@"\n"];
     [nsmstring appendString:@"Peripheral Info:"];
     [nsmstring appendFormat:@"NAME: %@\n",peripheral.name];
     [nsmstring appendFormat:@"RSSI: %@\n",RSSI];
     
     
     if(![peripheral.name isEqual:@"HMSoft"]) {
     NSLog(@"%@ is discover", peripheral.name);
     return;
     }
     
     if(peripheral.state != CBPeripheralStateConnected) {
     NSLog(@"peripheral.state != CBPeripheralStateConnected");
     [nsmstring appendString:@"isConnected: connected"];
     mHMSoftPeripheral = peripheral;
     UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"HMSoft" message:@"Please Connect to HMSoft" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
     //[alertView show];
     NSLog(@"Please Connect to HMSoft");
     }
     else {
     NSLog(@"peripheral.state == CBPeripheralStateConnected");
     [nsmstring appendString:@"isConnected: connected"];
     }
     NSLog(@"adverisement:%@",advertisementData);
     [nsmstring appendFormat:@"adverisement:%@",advertisementData];
     [nsmstring appendString:@"didDiscoverPeripheral\n"];
     NSLog(@"%@",nsmstring);
     */
    
    
    
    BOOL replace = NO;
    BOOL found = NO;
    NSLog(@"Services scanned !");
    //[self.mCM cancelPeripheralConnection:peripheral];
    
    /*
     for (CBService *s in peripheral.services) {
     NSLog(@"Service found : %@",s.UUID);
     if ([s.UUID isEqual:[CBUUID UUIDWithString:@"F000AA00-0451-4000-B000-000000000000"]])  {
     NSLog(@"This is a SensorTag !");
     found = YES;
     }
     //add by milochen so non-SensorTag will be found
     else {
     NSLog(@"This is not sensor tag");
     found = YES;
     }
     }
     */
    found = YES;
    if (found) {
        // Match if we have this device from before
        for (int ii=0; ii < self.mSensors.count; ii++) {
            CBPeripheral *p = [self.mSensors objectAtIndex:ii];
            if ([p isEqual:peripheral]) {
                [self.mSensors replaceObjectAtIndex:ii withObject:peripheral];
                replace = YES;
            }
        }
        if (!replace) {
            [self.mSensors addObject:peripheral];
            NSLog(@"mSensor addObject : %@", peripheral.name);
            //[self.tableView reloadData];
        }
    }
    
    //[self.tableView reloadData];
    
    if(IS_TEST_SMART_LOCK) {
        if([peripheral.name isEqual:@"JT SmartLock DemoV1"]) {
            //if([peripheral.name isEqual:@"WEN HUI's iPad"]) {
            [self stopScanProcess];
            mHMSoftPeripheral = peripheral;
            
            //[self.mCM connectPeripheral:mHMSoftPeripheral options:nil];
            
            [self requestBLEIntoConnectStatus];
            
        }
    }
    
}





static BOOL sIsDiscoverServicesOnCalling = NO;
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didConnectPeripheral is calling");
    NSLog(@"Connect To Peripheral with name: %@\nwith UUID:%@\n",peripheral.name,CFUUIDCreateString(NULL, peripheral.UUID));
    
    
    peripheral.delegate=self;
    
    //[peripheral discoverServices:nil];//一定要執行"discoverService"功能去尋找可用的Service
    //[self stopScanProcess];
    
    
    
    //try this function for don't do discoverServices
    
    sIsDiscoverServicesOnCalling = YES;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:@"FFAB"]]];
    
    
    
    //NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"FFF0"];
    //NSArray * serviceUUIDs = [NSArray arrayWithObjects:uuid, nil];
    
    //NSArray * serviceUUIDs = [NSArray arrayWithObjects:@"FFF0", nil];
    //[peripheral discoverServices:serviceUUIDs];
    
    
    [[[[iToast makeText:NSLocalizedString(@"did connect", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationShort ] show];
    
    
    
    
    
    
    //[peripheral discoverService:@"FFE0"];
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral is calling");
    
    
    
    /*
    if(sIsDiscoverServicesOnCalling == YES) {
        NSLog(@"sIsDiscoverServicesOnCalling is YES");
        sIsDiscoverServicesOnCalling = NO;
        
        dispatch_async(dispatch_get_main_queue(),^{
            [self requestBLEIntoConnectStatus];
        });
    }
    else {
        NSLog(@"sIsDiscoverServicesOnCalling is NO");
    }
    */
    
    NSLog(@"%@",[NSString stringWithFormat:@"Disconnected from peripheral: %@ with UUID: %@",peripheral,peripheral.UUID]);
    NSLog(@"%@",[NSString stringWithFormat:@"%@: Has Disconnected",peripheral.name]);
    
    if(sIsDiscoverServicesOnCalling == YES) {
        NSLog(@"sIsDiscoverServicesOnCalling is YES");
        sIsDiscoverServicesOnCalling = NO;
        [[[[iToast makeText:NSLocalizedString(@"try reconnect", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationShort] show];
        dispatch_async(dispatch_get_main_queue(),^{
            [self requestBLEIntoConnectStatus];
        });
        
        
    }
    else {
        NSLog(@"sIsDiscoverServicesOnCalling is NO");
        [[[[iToast makeText:NSLocalizedString(@"did disconnect", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationShort] show];
        
        //milochen
        BOOL isOperationFailedByConnFailed = NO; //TODO: milochen have no way to define operation failed By Conn Failed Now
        
        [self turnOffOperationInBLEWithComplete:^{
            NSLog(@"turnOffOperationInBLEWithComplete is called");
            if(isOperationFailedByConnFailed == YES) {
                if(mConnFailedBlock!=nil) {
                    mConnFailedBlock();
                }
            }
            if(mOperationCompleteBlock != nil) {
                mOperationCompleteBlock();
            }
        }];
        
        
    }
    
    //[[[[iToast makeText:NSLocalizedString(@"did disconnect", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationShort] show];
    
    
    //[self ericBLEInit];
    
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    NSLog(@"didDiscoverServices is calling");
    sIsDiscoverServicesOnCalling  = NO;
    /*
     NSLog(@"didDiscoverServices:\n");
     if( peripheral.UUID == NULL  ) return; // zach ios6 added
     if (!error) {
     NSLog(@"====%@\n",peripheral.name);
     
     //change by milochen
     //NSLog(@"=========== %d of service for UUID %@ ===========\n",peripheral.services.count,CFUUIDCreateString(NULL,peripheral.UUID));
     int cnt = [[peripheral services] count];
     NSLog(@"=========== %d of service for UUID %@ ===========\n",cnt ,CFUUIDCreateString(NULL,peripheral.UUID));
     
     
     for (CBService *p in peripheral.services){
     NSLog(@"Service found with UUID: %@\n", p.UUID);
     [peripheral discoverCharacteristics:nil forService:p];
     }
     
     }
     else {
     NSLog(@"Service discovery was unsuccessfull !\n");
     }
     */
    NSLog(@"Found Services.");
    
    int i=0;
    for (CBService *s in peripheral.services) {
        //[self.nServices addObject:s];
    }
    for (CBService *s in peripheral.services) {
        //[self updateLog:[NSString stringWithFormat:@"%d :Service UUID: %@(%@)",i,s.UUID.data,s.UUID]];
        NSLog(@"%@", [NSString stringWithFormat:@"%d :Service UUID: %@(%@)",i,s.UUID.data,s.UUID]);
        i++;
        //[peripheral discoverCharacteristics:nil forService:s];
        
        
        if([s.UUID isEqual:[CBUUID UUIDWithString:@"FFAB"]]) {
            [peripheral discoverCharacteristics:@[
                                                  [CBUUID UUIDWithString:@"FFF1"],
                                                  [CBUUID UUIDWithString:@"FFE1"],
                                                  [CBUUID UUIDWithString:@"FFE2"],
                                                  [CBUUID UUIDWithString:@"FFE3"],
                                                  [CBUUID UUIDWithString:@"FFE4"],
                                                  [CBUUID UUIDWithString:@"FFE5"],
                                                  [CBUUID UUIDWithString:@"FFE6"],
                                                  ] forService:s];
            
        }
        
        
    }
    
    
    
}




//-----------start-----------
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"%@", [NSString stringWithFormat:@"Found Characteristics in Service:%@ (%@)",service.UUID.data ,service.UUID]  );
    
    for (CBCharacteristic *c in service.characteristics) {
        //[self updateLog:[NSString stringWithFormat:@"Characteristic UUID: %@ (%@)",c.UUID.data,c.UUID]];
        NSLog(@"%@",[NSString stringWithFormat:@"Characteristic UUID: %@ (%@)",c.UUID.data,c.UUID]);
        
        //add by milochen
        //[BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        //[self setNotificationForCharacteristic:cbPeripheral sUUID:@"FFE0" cUUID:@"FFE1" enable:YES];
        
        
        if(IS_TEST_SMART_LOCK) {
            //[self setNotificationForCharacteristic:peripheral sUUID:@"FFF0" cUUID:@"FFF1" enable:YES];
        }
        else {
            [self setNotificationForCharacteristic:peripheral sUUID:@"FFE0" cUUID:@"FFE1" enable:YES];
        }
        //[nCharacteristics addObject:c];
        
        
    }
    if(IS_TEST_SMART_LOCK) {
        
        //        CBUUID * cbuuid =service.UUID;
        
        //CFStringRef ref = CFUUIDCreateString(nil, service.UUID);
        //NSString * uuidStr = (__bridge NSString*)
        
        //if([service.UUID isEqual:[CBUUID UUIDWithString:@"FFF0"]]) {
        static BOOL sIsLock = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //adapted by milochen
            if(mSendByteBlock != nil ) {
                mSendByteBlock();
            }
            
            
            if(sIsLock) {
                //[self SmartLock_OwnerDoUnlock];
                //[self SmartLock_InReceiving];
                
                dispatch_async(dispatch_get_main_queue(),^{
                    //[self requestBLEIntoDisconnectStatus];
                });
                sIsLock = NO ;
            }
            else {
                //                    [self SmartLock_OwnerDoLock];
                //[self SmartLock_NotInReceiving];
                dispatch_async(dispatch_get_main_queue(),^{
                    //[self requestBLEIntoDisconnectStatus];
                });
                
                sIsLock = YES;
            }
            
            
        });
        //}
        
    }
    
}





-(void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data {
    NSLog(@"writeCharacteristic");
    // Sends data to BLE peripheral to process HID and send EHIF command to PC
    for ( CBService *service in peripheral.services ) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            NSLog(@"This is services !");
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    NSLog(@"writeCharacteristic func is start to write ");
                    
                    //change the code from type:CBCharacteristicWriteWithResponse to CBCharacteristicWriteWithoutResponse
                    //and the code is working for Eric
                    
                    
                    if(IS_TEST_SMART_LOCK) {
                        //[peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    }
                    else {
                        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                        //The code is for Eric
                        //WithResponse will not work for his device
                    }
                    
                }
                else {
                    NSLog(@"characteristic.UUID is not equal because it is %@ " , characteristic.UUID);
                    //B40C1F55-3134-A349-44DE-854C58BC245F
                }
            }
        }
        else {
            NSLog(@"another services !");
        }
    }
}

-(void)readCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID {
    for ( CBService *service in peripheral.services ) {
        if([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    /* Everything is found, read characteristic ! */
                    NSLog(@"readValueForCharacteristic (sUUID=%@, cUUID=%@) is called for peripheral", sUUID, cUUID);
                    NSLog(@"so predict didUpdateValueForCharacteristic will be called");
                    [peripheral readValueForCharacteristic:characteristic];
                    return;
                }
            }
        }
    }
    NSLog(@"readValueForCharacteristic (sUUID=%@, cUUID=%@) is not work", sUUID, cUUID);
}



-(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID enable:(BOOL)enable {
    for ( CBService *service in peripheral.services ) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]])
                {
                    /* Everything is found, set notification ! */
                    [peripheral setNotifyValue:enable forCharacteristic:characteristic];
                }
                
            }
        }
    }
}

//已读到char
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"didUpdateValueForCharacteristic is invoked");
    if (error) {
        NSLog(@"didUpdateValueForCharacteristic error");
        return;
    }
    else {
        NSLog(@"call mDataRecvListener by didUpdateValueForCharacteristic");
        mDataRecvListener(characteristic.value, (int)characteristic.value.length);
    }
    
    //NSString* newStr = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    //NSString* newStr = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    //NSLog(@"return str = %@ with length = %d", newStr, (int)characteristic.value.length);
    
    
}


- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic is invoked");
}



- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didWriteValueForCharacteristic is called");
    NSLog(@"Did write characteristic value : %@ with ID %@", characteristic.value, characteristic.UUID);
    if(error != nil) {
        NSLog(@"With error: %@", [error localizedDescription]);
    }
}


-(void) setOnBleRecvStringListener: (void(^)(NSData*,int))listener {
    mDataRecvListener = listener;
}




-(void)requestBLEIntoDisconnectStatus {
    
    NSLog(@"requestBLEIntoDisconnectStatus");
    CBPeripheral *p = mHMSoftPeripheral;
    if (p.isConnected) {
        
        //self.d.manager.delegate = self;
        mCM.delegate = self;
        
        [mCM cancelPeripheralConnection:p];
        //[self.d.manager connectPeripheral:self.d.p options:nil];
        
    }
    else {
        //mCM.delegate = self;
        mCM.delegate = self;
        //self.d.p.delegate = self;
        //[self configureSensorTag];
        //self.title = @"TI BLE Sensor Tag application";
    }
    
}

-(void)requestBLEIntoConnectStatus {
    CBPeripheral *p = mHMSoftPeripheral;
    if (!p.isConnected) {
        
        //self.d.manager.delegate = self;
        mCM.delegate = self;
        //[self.d.manager connectPeripheral:self.d.p options:nil];
        
        NSLog(@"will call mCM connectPeripheral with peripheral.name = %@", p.name);
        [mCM connectPeripheral:p options:nil];
        
    }
    else {
        mCM.delegate = self;
        //self.d.p.delegate = self;
        //[self configureSensorTag];
        //self.title = @"TI BLE Sensor Tag application";
    }
    
}









-(void) stopScanProcess {
    if(mScanTimeoutTimer != nil) {
        [mScanTimeoutTimer invalidate];
        mScanTimeoutTimer = nil;
    }
    [mCM stopScan];
}

- (void)ericBLEInit {
    NSLog(@"ericBLEInit is calling");
    
    mCM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    
    /*
     [mCM scanForPeripheralsWithServices:@[
     [CBUUID UUIDWithString:@"FFAB"]
     ] options:nil];
     */
    
    
    
    [[[[iToast makeText:NSLocalizedString(@"scan start 5 sec.", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationShort ] show];
    //[NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(scanTimeout:) userInfo:nil repeats:NO];
    //mScanTimeoutTimer != nil;
    
    /*
     [[[[iToast makeText:NSLocalizedString(@"scan start 5 sec.", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationShort ] show];
     if(mScanTimeoutTimer != nil ) {
     [mScanTimeoutTimer invalidate];
     mScanTimeoutTimer = nil;
     }
     
     mScanTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(scanTimeout:) userInfo:nil repeats:NO];
     */
    
    //add by milochen for tableview
}



-(void) ericBLEDeinit {
    NSLog(@"ericBLEDeinit is calling");
}


- (IBAction)ericBLEScan:(id)sender {
    NSLog(@"ericBLEScan is calling");
    
    //[mCM scanForPeripheralsWithServices:nil options:nil];
    
    //add by milochen
    if(IS_TEST_SMART_LOCK) {
        NSArray *uuidArray= [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"FFAB"], nil];
    }
    else {
        //NSArray *uuidArray= [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"FFE0"],[CBUUID UUIDWithString:@"FFF0"], nil];
        NSArray *uuidArray= [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"FFE0"],[CBUUID UUIDWithString:@"FFF0"], nil];
    }
    
    
    //[mCM scanForPeripheralsWithServices:uuidArray options:nil];
    //[mCM scanForPeripheralsWithServices:nil options:nil];
    if(IS_TEST_SMART_LOCK) {
        [mCM scanForPeripheralsWithServices:@[
                                              [CBUUID UUIDWithString:@"FFA0"]
                                              ] options:nil];
    }
    else {
        [mCM scanForPeripheralsWithServices:nil options:nil];
    }
    
}


- (IBAction)ericBLEStopScan:(id)sender {
    NSLog(@"ericBLEStopScan is calling");
}

- (IBAction)ericBLESendLedOn:(id)sender {
    NSLog(@"ericBLESendLedOn is calling");
    static NSString * writeStr = @"s_on";
    //NSData* cData = [writeStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData* cData = [writeStr dataUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"cData.length = %d",(int)cData.length);
    //[self writeCharacteristic:mHMSoftPeripheral sUUID:sUUID cUUID:cUUID data:cData];
    
    
    
    if(IS_TEST_SMART_LOCK) {
        NSLog(@"IS_TEST_SMART_LOCK");
        unsigned c = 1;
        uint8_t* bytes = malloc(sizeof(*bytes)*c);
        unsigned i;
        for ( i = 0; i < c ; i++) {
            int byte = 0x01; //0x01 is unlock
            bytes[i] = byte;
        }
        cData = [NSData dataWithBytes:bytes length:c];
    }
    
    
    if(IS_TEST_SMART_LOCK ) {
        [self writeCharacteristic:mHMSoftPeripheral sUUID:@"FFAB" cUUID:@"FFF1" data:cData];
    }
    else {
        [self writeCharacteristic:mHMSoftPeripheral sUUID:@"FFE0" cUUID:@"FFE1" data:cData];
    }
    
}





- (IBAction)ericBLESendLedOff:(id)sender {
    NSLog(@"ericBLESendLedOff is calling");
    
    static NSString * writeStr = @"s_of";
    //NSData* cData = [writeStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData* cData = [writeStr dataUsingEncoding:NSASCIIStringEncoding];
    
    
    //test for Unlock door , this code is not for eric project
    bool isTestSmartLock = YES;
    
    if(IS_TEST_SMART_LOCK) {
        unsigned c = 1;
        uint8_t* bytes = malloc(sizeof(*bytes)*c);
        unsigned i;
        for ( i = 0; i < c ; i++) {
            int byte = 0x02; //0x02 is lock
            bytes[i] = byte;
        }
        cData = [NSData dataWithBytes:bytes length:c];
    }
    
    NSLog(@"cData.length = %d",(int)cData.length);
    
    
    if(IS_TEST_SMART_LOCK ) {
        [self writeCharacteristic:mHMSoftPeripheral sUUID:@"FFAB" cUUID:@"FFF1" data:cData];
    }
    else {
        [self writeCharacteristic:mHMSoftPeripheral sUUID:@"FFE0" cUUID:@"FFE1" data:cData];
    }
}

- (IBAction)ericBLEConnectHMSoft:(id)sender {
    //if(mHMSoftPeripheral != nil) {
    if(mHMSoftPeripheral.state == CBPeripheralStateConnected) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"HMSoft" message:@"HMSoft is connect before, so discoonect it now" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        mHMSoftPeripheral.delegate = self;
        //[mCM cancelPeripheralConnection:mHMSoftPeripheral];
        //[mCM connectPeripheral:mHMSoftPeripheral options:nil];
    }
    else {
        mHMSoftPeripheral.delegate = self;
        [mCM connectPeripheral:mHMSoftPeripheral options:nil];
        
    }
    //}
    /*
     else {
     UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"HMSoft" message:@"Please click Scan to scan HMSoft" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
     //[alertView show];
     
     
     }
     */
    
    
    
    /*
     if (cbReady ==false) {
     [self.cbCM connectPeripheral:cbPeripheral options:nil];
     textSend.hidden = false;
     buttonSend.hidden = false;
     cbReady = true;
     }else {
     [self.cbCM cancelPeripheralConnection:cbPeripheral];
     textSend.hidden = true;
     buttonSend.hidden = true;
     cbReady = false;
     }
     */
}









#pragma mark - CoreBluetooth SmartLock basic ReadWrite functions


-(void) SmartLock_WriteByte:(uint8_t)b toService:(NSString*)sUUID andCharacteristic:(NSString*)cUUID {
    
    NSData* cData ;
    unsigned c = 1;
    uint8_t* bytes = malloc(sizeof(*bytes)*c);
    unsigned i;
    for ( i = 0; i < c ; i++) {
        //int byte = 0x02; //0x02 is lock
        int byte = b;
        bytes[i] = byte;
    }
    cData = [NSData dataWithBytes:bytes length:c];
    NSLog(@"cData.length = %d",(int)cData.length);
    //[self writeCharacteristic:mHMSoftPeripheral sUUID:@"FFF0" cUUID:@"FFF1" data:cData];
    [self writeCharacteristic:mHMSoftPeripheral sUUID:sUUID cUUID:cUUID data:cData];
    
    
}

-(void) SmartLock_ReadByteInService:(NSString*)sUUID andCharacteristic:(NSString*)cUUID {
    [self readCharacteristic:mHMSoftPeripheral sUUID:sUUID cUUID:cUUID];
}




static NSString * sSmartLock_sUUID =@"FFAB";

-(void) SmartLock_TerminateConnection {
    [self SmartLock_WriteByte:'D' toService:sSmartLock_sUUID andCharacteristic:@"FFF1"];
}
-(void) SmartLock_OwnerDoLock  {
    NSLog(@"SmartLock_DoLock is calling");
    [self SmartLock_WriteByte:'L' toService:sSmartLock_sUUID andCharacteristic:@"FFE1"];
}

-(void) SmartLock_OwnerDoUnlock  {
    NSLog(@"SmartLock_DoUnlock is calling");
    [self SmartLock_WriteByte:'U' toService:sSmartLock_sUUID andCharacteristic:@"FFE1"];
}

-(void) SmartLock_GuestDoLock {
    NSLog(@"SmartLock_GuestDoLock");
    [self SmartLock_WriteByte:'l' toService:sSmartLock_sUUID andCharacteristic:@"FFE1"];
}
-(void) SmartLock_GuestDoUnlock {
    NSLog(@"SmartLock_GuestDoUnlock");
    [self SmartLock_WriteByte:'u' toService:sSmartLock_sUUID andCharacteristic:@"FFE1"];
}

-(void) SmartLock_GetLockStatus {
    NSLog(@"SmartLock_GetLockStatus is calling");
    [self SmartLock_ReadByteInService:sSmartLock_sUUID andCharacteristic:@"FFE2"];
}

-(void) SmartLock_GiveKey {
    NSLog(@"SmartLock_GiveKey is calling");
    [self SmartLock_WriteByte:'K' toService:sSmartLock_sUUID andCharacteristic:@"FFE3"];
}

-(void) SmartLock_ReturnKey {
    NSLog(@"SmartLock_ReturnKey is calling");
    [self SmartLock_WriteByte:'k' toService:sSmartLock_sUUID andCharacteristic:@"FFE3"];
}

-(void) SmartLock_GetKeyStatus {
    NSLog(@"SmartLock_GetKeyStatus is calling");
    [self SmartLock_ReadByteInService:sSmartLock_sUUID andCharacteristic:@"FFE4"];
}

-(void) SmartLock_InReceiving {
    NSLog(@"SmartLock_InReceiving is calling");
    [self SmartLock_WriteByte:'I' toService:sSmartLock_sUUID andCharacteristic:@"FFE5"];
}

-(void) SmartLock_NotInReceiving {
    NSLog(@"Smartlock_NotInReceiving is calling");
    [self SmartLock_WriteByte:'i' toService:sSmartLock_sUUID andCharacteristic:@"FFE5"];
}

-(void) SmartLock_IsInReceiving {
    NSLog(@"SmartLock_IsInReceiving is calling");
    [self SmartLock_ReadByteInService:sSmartLock_sUUID andCharacteristic:@"FFE6"];
}





@end
