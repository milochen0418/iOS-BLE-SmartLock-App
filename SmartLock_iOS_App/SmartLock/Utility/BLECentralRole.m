//
//  BLECentralRole.m
//  SmartLock
//
//  Created by Milo Chen on 2/24/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import "BLECentralRole.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "iToast.h"


@interface BLECentralRole()

@property (nonatomic,strong) CBCentralManager *mCM;
@property (nonatomic,strong) CBPeripheral * mPeripheral;
@property (nonatomic,copy) void (^mDataRecvListener)(NSData* data, int length);
@property (nonatomic,strong) NSMutableArray* mDevices;
@property (nonatomic,strong) NSMutableArray * mSensors;



@end


@implementation BLECentralRole

@synthesize mPeripheral,mCM;
@synthesize mDataRecvListener;
@synthesize mDevices;

//the code may called by viewDidLoad
-(void) startCentralRole {
    [self doBLEScan];
}



-(void)doBLEScan {
    self.mDevices = [[NSMutableArray alloc] init];
    self.mSensors = [[NSMutableArray alloc] init];
    //self.title = @"BLE Device Scan";
    //[self.tableView reloadData];
    
    [self ericBLEInit];
}

- (void)ericBLEInit {
    NSLog(@"ericBLEInit is calling");
    
    mCM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [mCM scanForPeripheralsWithServices:nil options:nil];
//    [[[[iToast makeText:NSLocalizedString(@"scan start 5 sec.", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationShort ] show];
    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(scanTimeout:) userInfo:nil repeats:NO];

}

- (IBAction)ericBLEScan:(id)sender {
    NSLog(@"ericBLEScan is calling");
    
    //[mCM scanForPeripheralsWithServices:nil options:nil];
    
    //add by milochen
    NSArray *uuidArray= [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"FFE0"],[CBUUID UUIDWithString:@"FFF0"], nil];
    //[mCM scanForPeripheralsWithServices:uuidArray options:nil];
    [mCM scanForPeripheralsWithServices:nil options:nil];
}



-(void) ericBLEDeinit {
    NSLog(@"ericBLEDeinit is calling");
}
- (IBAction)ericBLEStopScan:(id)sender {
    NSLog(@"ericBLEStopScan is calling");
}


- (IBAction)ericBLESendLedOn:(id)sender {
    NSLog(@"");
    NSLog(@"ericBLESendLedOn is calling");
    static NSString * writeStr = @"s_on";
    //NSData* cData = [writeStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData* cData = [writeStr dataUsingEncoding:NSASCIIStringEncoding];

    
    
    unsigned c = 1;
    uint8_t* bytes = malloc(sizeof(*bytes)*c);
    unsigned i;
    for ( i = 0; i < c ; i++) {
        int byte = 0x01; //0x01 is unlock
        bytes[i] = byte;
    }
    cData = [NSData dataWithBytes:bytes length:c];
    
    NSLog(@"cData.length = %d",(int)cData.length);
    //[self writeCharacteristic:mHMSoftPeripheral sUUID:sUUID cUUID:cUUID data:cData];
    [self writeCharacteristic:mPeripheral sUUID:@"FFE0" cUUID:@"FFE1" data:cData];
}




- (IBAction)ericBLESendLedOff:(id)sender {
    NSLog(@"ericBLESendLedOff is calling");
    
    static NSString * writeStr = @"s_of";
    //NSData* cData = [writeStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData* cData = [writeStr dataUsingEncoding:NSASCIIStringEncoding];
    
    
    unsigned c = 1;
    uint8_t* bytes = malloc(sizeof(*bytes)*c);
    unsigned i;
    for ( i = 0; i < c ; i++) {
        int byte = 0x02; //0x02 is lock
        bytes[i] = byte;
    }
    cData = [NSData dataWithBytes:bytes length:c];
    
    NSLog(@"cData.length = %d",(int)cData.length);
    
    [self writeCharacteristic:mPeripheral sUUID:@"FFE0" cUUID:@"FFE1" data:cData];
    //[self writeCharacteristic:mHMSoftPeripheral sUUID:sUUID cUUID:cUUID data:cData];
    
    
}



- (IBAction)ericBLEConnectHMSoft:(id)sender {
    //if(mHMSoftPeripheral != nil) {
    if(mPeripheral.state == CBPeripheralStateConnected) {
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"HMSoft" message:@"HMSoft is connect before, so discoonect it now" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertView show];
        
        mPeripheral.delegate = self;
        [mCM cancelPeripheralConnection:mPeripheral];

    }
    else {
        mPeripheral.delegate = self;
        [mCM connectPeripheral:mPeripheral options:nil];
    }
}





-(void)requestBLEIntoConnectStatus {
    CBPeripheral *p = mPeripheral;
    if (!p.isConnected) {
        mCM.delegate = self;
        [mCM connectPeripheral:p options:nil];
    }
    else {
        mCM.delegate = self;
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
                    //[peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                    
                    //the following code is for SmartLock 
                    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    
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
            [cManager scanForPeripheralsWithServices:nil options:nil];
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
        [[[[iToast makeText:NSLocalizedString(@"timeout to stop scan", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationShort ] show];
    }else{
        NSLog(@"CM is Null!");
    }
    NSLog(@"scanTimeout function is done");
}


-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    
    BOOL replace = NO;
    BOOL found = NO;
    NSLog(@"Services scanned !");
    [self.mCM cancelPeripheralConnection:peripheral];
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
    
}



-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didConnectPeripheral");
    NSLog(@"Connect To Peripheral with name: %@\nwith UUID:%@\n",peripheral.name,CFUUIDCreateString(NULL, peripheral.UUID));
    
    peripheral.delegate=self;
    [peripheral discoverServices:nil];//一定要執行"discoverService"功能去尋找可用的Service
    
    [[[[iToast makeText:NSLocalizedString(@"did connect", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationShort ] show];
        //[peripheral discoverService:@"FFE0"];
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%@",[NSString stringWithFormat:@"Disconnected from peripheral: %@ with UUID: %@",peripheral,peripheral.UUID]);
    NSLog(@"%@",[NSString stringWithFormat:@"%@: Has Disconnected",peripheral.name]);
    
    [[[[iToast makeText:NSLocalizedString(@"did disconnect", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationShort] show];
    //[self ericBLEInit];
    
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"Found Services.");
    
    int i=0;
    for (CBService *s in peripheral.services) {
        //[self.nServices addObject:s];
    }
    for (CBService *s in peripheral.services) {
        //[self updateLog:[NSString stringWithFormat:@"%d :Service UUID: %@(%@)",i,s.UUID.data,s.UUID]];
        NSLog(@"%@", [NSString stringWithFormat:@"%d :Service UUID: %@(%@)",i,s.UUID.data,s.UUID]);
        i++;
        [peripheral discoverCharacteristics:nil forService:s];
    }
}



//-----------start-----------
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"%@", [NSString stringWithFormat:@"Found Characteristics in Service:%@ (%@)",service.UUID.data ,service.UUID]  );
    for (CBCharacteristic *c in service.characteristics) {
        //[self updateLog:[NSString stringWithFormat:@"Characteristic UUID: %@ (%@)",c.UUID.data,c.UUID]];
        NSLog(@"%@",[NSString stringWithFormat:@"Characteristic UUID: %@ (%@)",c.UUID.data,c.UUID]);
        [self setNotificationForCharacteristic:peripheral sUUID:@"FFE0" cUUID:@"FFE1" enable:YES];
        //[nCharacteristics addObject:c];
    }
}




//已读到char
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"didUpdateValueForCharacteristic is invoked");
    if (error) {
        return;
    }
    mDataRecvListener(characteristic.value, (int)characteristic.value.length);
}



- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"Did write characteristic value : %@ with ID %@", characteristic.value, characteristic.UUID);
    NSLog(@"With error: %@", [error localizedDescription]);
}


-(void) setOnBleRecvStringListener: (void(^)(NSData*,int))listener {
    mDataRecvListener = listener;
}







@end
