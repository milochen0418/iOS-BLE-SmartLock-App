//
//  FileStorageHelper.h
//  AntiLost
//
//  Created by Milo Chen on 6/26/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface FileStorageHelper : NSObject

+(FileStorageHelper * ) sharedInstance;


#pragma mark - txt file process
-(void) writeTxtBodyStr:(NSString*) txtBodyStr onFileName:(NSString*)fileName;
-(NSString*) readTxtBodyStrOnFileName:(NSString*)fileName;



#pragma mark - Json file process
-(NSObject*) readJsonObjOnFileName:(NSString*) fileName;
-(void) writeJsonObj:(NSObject*) jsonObj onFileName:(NSString*)fileName;
-(void) writeJsonStr:(NSString*) jsonStr onFileName:(NSString*)fileName;
-(NSString*) readJsonStrOnFileName:(NSString*) fileName;




#pragma mark - Base64 image process
- (NSString*) getBase64EncodedStringByImage:(UIImage*)image withCompressionQuality:(CGFloat)compressionQuality ;
- (UIImage*) getImageFromBase64EncodedString:(NSString*)base64Str;




#pragma mark - for test code
-(void) jsonConvertorTestCode; //for test, but not for use


@end
