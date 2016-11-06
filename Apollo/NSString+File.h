//
//  NSString+File.h
//  Apollo
//
//  Created by Daniel Leivers on 05/11/2016.
//  Copyright © 2016 Daniel Leivers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (File)

+ (NSString *)stringWithContentsOfTextFile:(NSString *)filename;

@end
