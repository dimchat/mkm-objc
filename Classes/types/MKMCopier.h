// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2022 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2022 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  MKMCopier.h
//  MingKeMing
//
//  Created by Albert Moky on 2022/8/4.
//  Copyright © 2022 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

/*
 *  Shallow Copy
 *  ~~~~~~~~~~~~
 */

id MKMCopy(id obj);

NSMutableDictionary<NSString *, id> *MKMCopyMap(NSDictionary<NSString *, id> *dict);

NSMutableArray<id> *MKMCopyList(NSArray<id> *list);

/*
 *  Deep Copy
 *  ~~~~~~~~~
 */

id MKMDeepCopy(id obj);

NSMutableDictionary<NSString *, id> *MKMDeepCopyMap(NSDictionary<NSString *, id> *dict);

NSMutableArray<id> *MKMDeepCopyList(NSArray<id> *list);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

#pragma mark - Converter

#ifdef __cplusplus
extern "C" {
#endif

NSString *MKMConverterGetString(id value);

/**
 *  assume value can be a config string:
 *      'true', 'false', 'yes', 'no', 'on', 'off', '1', '0', ...
 */
BOOL MKMConverterGetBool(id value);

int MKMConverterGetInt(id value);
long MKMConverterGetLong(id value);
short MKMConverterGetShort(id value);
char MKMConverterGetChar(id value);

float MKMConverterGetFloat(id value);
double MKMConverterGetDouble(id value);

unsigned int MKMConverterGetUnsignedInt(id value);
unsigned long MKMConverterGetUnsignedLong(id value);
unsigned short MKMConverterGetUnsignedShort(id value);
unsigned char MKMConverterGetUnsignedChar(id value);

NSInteger MKMConverterGetInteger(id value);
NSUInteger MKMConverterGetUnsignedInteger(id value);

/**
 *  assume value can be a timestamp (seconds from 1970-01-01 00:00:00)
 */
NSDate *MKMConverterGetDate(id value);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
