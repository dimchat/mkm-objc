// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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
//  MKMID.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAddress.h"
#import "MKMAccountHelpers.h"

#import "MKMID.h"

id<MKMIDFactory> MKMIDGetFactory(void) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext.idHelper getIdentifierFactory];
}

void MKMIDSetFactory(id<MKMIDFactory> factory) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    [ext.idHelper setIdentifierFactory:factory];
}

id<MKMID> MKMIDGenerate(id<MKMMeta> meta,
                        MKMEntityType network,
                        NSString * _Nullable terminal) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext.idHelper generateIdentifier:network
                                   withMeta:meta
                                   terminal:terminal];
}

id<MKMID> MKMIDCreate(NSString * _Nullable name,
                      id<MKMAddress> address,
                      NSString * _Nullable terminal) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext.idHelper createIdentifierWithName:name
                                          address:address
                                         terminal:terminal];
}

id<MKMID> MKMIDParse(id identifier) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext.idHelper parseIdentifier:identifier];
}

#pragma mark Conveniences

NSMutableArray<id<MKMID>> *MKMIDConvert(NSArray<id> *array) {
    NSMutableArray<id<MKMID>> *members;
    members = [[NSMutableArray alloc] initWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id<MKMID> ID = MKMIDParse(obj);
        if (ID) {
            [members addObject:ID];
        }
    }];
    return members;
}

NSMutableArray<NSString *> *MKMIDRevert(NSArray<id<MKMID>> *identifiers) {
    NSMutableArray<NSString *> *array;
    array = [[NSMutableArray alloc] initWithCapacity:identifiers.count];
    [identifiers enumerateObjectsUsingBlock:^(id<MKMID> obj, NSUInteger idx, BOOL *stop) {
        NSString *str = [obj string];
        if (str) {
            [array addObject:str];
        }
    }];
    return array;
}
