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
//  MKMTai.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

//#import "MKTransportableData.h"
#import "MKMAccountHelpers.h"

#import "MKMTai.h"

id<MKMDocumentFactory> MKMDocumentGetFactory(NSString *type) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext.docHelper getDocumentFactory:type];
}

void MKMDocumentSetFactory(NSString *type, id<MKMDocumentFactory> factory) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    [ext.docHelper setDocumentFactory:factory forType:type];
}

id<MKMDocument> MKMDocumentNew(NSString *type) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext.docHelper createDocumentWithData:nil
                                       signature:nil
                                         forType:type];
}

id<MKMDocument> MKMDocumentCreate(NSString *type,
                                  NSString *data,
                                  id<MKTransportableData> sig) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext.docHelper createDocumentWithData:data
                                       signature:sig
                                         forType:type];
}

id<MKMDocument> MKMDocumentParse(id doc) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext.docHelper parseDocument:doc];
}

#pragma mark Conveniences

NSMutableArray<id<MKMDocument>> *MKMDocumentConvert(NSArray<id> *array) {
    NSMutableArray<id<MKMDocument>> *documents;
    documents = [[NSMutableArray alloc] initWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id<MKMDocument> doc = MKMDocumentParse(obj);
        if (doc) {
            [documents addObject:doc];
        }
    }];
    return documents;
}

NSMutableArray<NSDictionary *> *MKMDocumentRevert(NSArray<id<MKMDocument>> *documents) {
    NSMutableArray<NSDictionary *> *array;
    array = [[NSMutableArray alloc] initWithCapacity:documents.count];
    [documents enumerateObjectsUsingBlock:^(id<MKMDocument> obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = [obj dictionary];
        if (dict) {
            [array addObject:dict];
        }
    }];
    return array;
}
