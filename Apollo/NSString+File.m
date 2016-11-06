//
//  NSString+File.m
//  Apollo
//
//  Created by Daniel Leivers on 05/11/2016.
//  Copyright © 2016 Daniel Leivers. All rights reserved.
//

#import "NSString+File.h"

@implementation NSString (File)

+ (NSString *)stringWithContentsOfTextFile:(NSString *)filename {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"txt"];
    return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

@end
