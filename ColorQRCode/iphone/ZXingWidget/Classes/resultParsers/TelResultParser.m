//
//  TelResultParser.m
//  ZXing
//
//  Created by Christian Brunschen on 25/06/2008.
/*
 * Copyright 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "TelResultParser.h"
#import "TelParsedResult.h"
#import "CBarcodeFormat.h"

#define PREFIX @"TEL:"

@implementation TelResultParser

+ (void)load {
  [ResultParser registerResultParserClass:self];
}

+ (ParsedResult *)parsedResultForString:(NSString *)s
                                 format:(BarcodeFormat)format {
  NSRange telRange = [s rangeOfString:PREFIX options:NSCaseInsensitiveSearch];
  if (telRange.location == 0) {
    int restStart = /*telRange.location + */ telRange.length;
    return [[[TelParsedResult alloc] initWithNumber:[s substringFromIndex:restStart]]
            autorelease];
  }
  return nil;
}


@end