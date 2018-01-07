//
//  FileStorageHelper.m
//  AntiLost
//
//  Created by Milo Chen on 6/26/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import "FileStorageHelper.h"

@interface FileStorageHelper ()

-(NSString*) convertToJsonStrFromJsonObj:(NSObject*) jsonObj;
-(NSObject*) convertToJsonObjFromJsonString:(NSString*) jsonStr;



void *NewBase64Decode(
                      const char *inputBuffer,
                      size_t length,
                      size_t *outputLength);

char *NewBase64Encode(
                      const void *inputBuffer,
                      size_t length,
                      bool separateLines,
                      size_t *outputLength);

- (NSString*)getBase64EncodedString:(NSData*)data;
- (NSString *)getBase64EncodedStringWithSeparateLines:(BOOL)separateLines withData:(NSData*)data;
- (NSData *)getDataFromBase64String:(NSString *)aString;



@end


@implementation FileStorageHelper

-(void) jsonConvertorTestCode {
    // the follow example code is translate JSON String to NSObject
    NSString *jsonString = @"[{\"id\": \"1\", \"name\":\"Aaa\"}, {\"id\": \"2\", \"name\":\"Bbb\"}]";
    NSLog(@"jsonString = %@", jsonString);
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    NSLog(@"%@ , get [1].name = %@", json, [(NSDictionary*)[json objectAtIndex:1] valueForKey:@"name"]);

    
    
    //the follow example code is translate NSObject to JSON String
    NSObject * attachement = json;
    NSError * error;
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:attachement options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData2) {
        //Deal with error
        NSLog(@"Deal with error");
    } else {
        NSString *requestJson = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        NSLog(@"requestJson = %@", requestJson);
    }
}



-(void) writeJsonStr:(NSString*) jsonStr onFileName:(NSString*)fileName {
    [self writeTxtBodyStr:jsonStr onFileName:fileName];
}
-(NSString*) readJsonStrOnFileName:(NSString*) fileName {
    return [self readTxtBodyStrOnFileName:fileName];
}


-(NSString*) convertToJsonStrFromJsonObj:(NSObject*) jsonObj {
    NSObject * attachement = jsonObj;
    NSError * error;
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:attachement options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData2) {
        return @"";
    } else {
        NSString *requestJson = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        return requestJson;

    }

}

-(NSObject*) convertToJsonObjFromJsonString:(NSString*) jsonStr {
    NSString * jsonString = jsonStr;
//    NSLog(@"jsonString = %@", jsonString);
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSObject * jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    return jsonObj;
}





+(FileStorageHelper * ) sharedInstance {
    static  FileStorageHelper * staticFileStorageHelper = nil;
    if(staticFileStorageHelper == nil) {
        staticFileStorageHelper = [[FileStorageHelper alloc] init];
    }
    return staticFileStorageHelper;
}

-(void) writeTxtBodyStr:(NSString*) txtBodyStr onFileName:(NSString*)fileName {
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    [[txtBodyStr dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}


-(NSString*) readTxtBodyStrOnFileName:(NSString*)fileName {
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString* fileName = @"myTextFile.txt";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    NSData *fileData = [NSData dataWithContentsOfFile:fileAtPath];
    NSString * txtBody = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding] ;
    return txtBody;
}




-(NSObject*) readJsonObjOnFileName:(NSString*) fileName {
    NSString * jsonStr = [self readJsonStrOnFileName:fileName];
    return [self convertToJsonObjFromJsonString:jsonStr];
}

-(void) writeJsonObj:(NSObject*) jsonObj onFileName:(NSString*)fileName {
    NSString * jsonStr = [self convertToJsonStrFromJsonObj:jsonObj];
    [self writeJsonStr:jsonStr onFileName:fileName];
}









#pragma mark - base64

static unsigned char base64EncodeLookup[65] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

//
// Definition for "masked-out" areas of the base64DecodeLookup mapping
//
#define xx 65

//
// Mapping from ASCII character to 6 bit pattern.
//
static unsigned char base64DecodeLookup[256] =
{
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 62, xx, xx, xx, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, xx, xx, xx, xx, xx, xx,
    xx,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, xx, xx, xx, xx, xx,
    xx, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
};


#define BINARY_UNIT_SIZE 3
#define BASE64_UNIT_SIZE 4

char *NewBase64Encode(
                      const void *buffer,
                      size_t length,
                      bool separateLines,
                      size_t *outputLength)
{
    const unsigned char *inputBuffer = (const unsigned char *)buffer;
    
#define MAX_NUM_PADDING_CHARS 2
#define OUTPUT_LINE_LENGTH 64
#define INPUT_LINE_LENGTH ((OUTPUT_LINE_LENGTH / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE)
#define CR_LF_SIZE 2
    
    //
    // Byte accurate calculation of final buffer size
    //
    size_t outputBufferSize =
    ((length / BINARY_UNIT_SIZE)
     + ((length % BINARY_UNIT_SIZE) ? 1 : 0))
    * BASE64_UNIT_SIZE;
    if (separateLines)
    {
        outputBufferSize +=
        (outputBufferSize / OUTPUT_LINE_LENGTH) * CR_LF_SIZE;
    }
    
    //
    // Include space for a terminating zero
    //
    outputBufferSize += 1;
    
    //
    // Allocate the output buffer
    //
    char *outputBuffer = (char *)malloc(outputBufferSize);
    if (!outputBuffer)
    {
        return NULL;
    }
    
    size_t i = 0;
    size_t j = 0;
    const size_t lineLength = separateLines ? INPUT_LINE_LENGTH : length;
    size_t lineEnd = lineLength;
    
    while (true)
    {
        if (lineEnd > length)
        {
            lineEnd = length;
        }
        
        for (; i + BINARY_UNIT_SIZE - 1 < lineEnd; i += BINARY_UNIT_SIZE)
        {
            //
            // Inner loop: turn 48 bytes into 64 base64 characters
            //
            outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
            outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                                   | ((inputBuffer[i + 1] & 0xF0) >> 4)];
            outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i + 1] & 0x0F) << 2)
                                                   | ((inputBuffer[i + 2] & 0xC0) >> 6)];
            outputBuffer[j++] = base64EncodeLookup[inputBuffer[i + 2] & 0x3F];
        }
        
        if (lineEnd == length)
        {
            break;
        }
        
        //
        // Add the newline
        //
        outputBuffer[j++] = '\r';
        outputBuffer[j++] = '\n';
        lineEnd += lineLength;
    }
    
    if (i + 1 < length)
    {
        //
        // Handle the single '=' case
        //
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                               | ((inputBuffer[i + 1] & 0xF0) >> 4)];
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i + 1] & 0x0F) << 2];
        outputBuffer[j++] =	'=';
    }
    else if (i < length)
    {
        //
        // Handle the double '=' case
        //
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0x03) << 4];
        outputBuffer[j++] = '=';
        outputBuffer[j++] = '=';
    }
    outputBuffer[j] = 0;
    
    //
    // Set the output length and return the buffer
    //
    if (outputLength)
    {
        *outputLength = j;
    }
    return outputBuffer;
}

void *NewBase64Decode(
                      const char *inputBuffer,
                      size_t length,
                      size_t *outputLength)
{
    if (length == -1)
    {
        length = strlen(inputBuffer);
    }
    
    size_t outputBufferSize =
    ((length+BASE64_UNIT_SIZE-1) / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE;
    unsigned char *outputBuffer = (unsigned char *)malloc(outputBufferSize);
    
    size_t i = 0;
    size_t j = 0;
    while (i < length)
    {
        //
        // Accumulate 4 valid characters (ignore everything else)
        //
        unsigned char accumulated[BASE64_UNIT_SIZE];
        size_t accumulateIndex = 0;
        while (i < length)
        {
            unsigned char decode = base64DecodeLookup[inputBuffer[i++]];
            if (decode != xx)
            {
                accumulated[accumulateIndex] = decode;
                accumulateIndex++;
                
                if (accumulateIndex == BASE64_UNIT_SIZE)
                {
                    break;
                }
            }
        }
        
        //
        // Store the 6 bits from each of the 4 characters as 3 bytes
        //
        // (Uses improved bounds checking suggested by Alexandre Colucci)
        //
        if(accumulateIndex >= 2)
            outputBuffer[j] = (accumulated[0] << 2) | (accumulated[1] >> 4);
        if(accumulateIndex >= 3)  
            outputBuffer[j + 1] = (accumulated[1] << 4) | (accumulated[2] >> 2);  
        if(accumulateIndex >= 4)  
            outputBuffer[j + 2] = (accumulated[2] << 6) | accumulated[3];
        j += accumulateIndex - 1;
    }
    
    if (outputLength)
    {
        *outputLength = j;
    }
    return outputBuffer;
}




- (NSString *)getBase64EncodedString:(NSData*)data
{
    size_t outputLength;
    char *outputBuffer =
    //    NewBase64Encode([self bytes], [self length], true, &outputLength);
    //    NewBase64Encode([data bytes], [data length], true, &outputLength);
    NewBase64Encode([data bytes], [data length],false, &outputLength);
    //the E-mail cannot accpet base64 encoding with seperate line
    //so we change the default value from true to false;
    
    
    NSString *result =
    [[NSString alloc]
     initWithBytes:outputBuffer
     length:outputLength
     encoding:NSASCIIStringEncoding];
    //     autorelease];
    
    
    free(outputBuffer);
    return result;
}


- (NSString *)getBase64EncodedStringWithSeparateLines:(BOOL)separateLines withData:(NSData*)data
{
    size_t outputLength;
    char *outputBuffer =
    //NewBase64Encode([self bytes], [self length], separateLines, &outputLength);
    NewBase64Encode([data bytes], [data length], separateLines, &outputLength);
    NSString *result =
    [[NSString alloc] initWithBytes:outputBuffer length:outputLength
                           encoding:NSASCIIStringEncoding];
    //     autorelease];
    free(outputBuffer);
    return result;
}


- (NSData *)getDataFromBase64String:(NSString *)aString
{
    NSData *data = [aString dataUsingEncoding:NSASCIIStringEncoding];
    size_t outputLength;
    void *outputBuffer = NewBase64Decode([data bytes], [data length], &outputLength);
    NSData *result = [NSData dataWithBytes:outputBuffer length:outputLength];
    free(outputBuffer);
    return result;
}



- (NSString*) getSyncBase64HtmlImgSrcWithUrl:(NSString*)urlStr andCompressionQuality:(CGFloat)quality {
    NSData * data;
//    UIImage * image = [self getSyncImageWithUrlStr:urlStr];
    UIImage * image = nil;
    data = UIImageJPEGRepresentation(image, quality);
    NSString *base64Header = @"data:image/jpeg;base64,";
    NSString * base64Content = [self getBase64EncodedString:data];
    // need to replace the last character = as %3D?
    NSString * base64Full = [NSString stringWithFormat:@"%@%@", base64Header, base64Content];
    return base64Full;
}


- (NSString*) getBase64EncodedStringByImage:(UIImage*)image withCompressionQuality:(CGFloat)compressionQuality {
    NSData * data;
    data = UIImageJPEGRepresentation(image, compressionQuality);
//    NSString * base64Str = [self getBase64EncodedStringWithSeparateLines:YES withData:data];
    NSString *base64Str = [self getBase64EncodedString:data];
    return base64Str;
}

- (UIImage*) getImageFromBase64EncodedString:(NSString*)base64Str {
    NSData * data = [self getDataFromBase64String:base64Str];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}





@end
