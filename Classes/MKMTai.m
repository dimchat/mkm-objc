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

#import "MKMTransportableData.h"
#import "MKMFactoryManager.h"

#import "MKMTai.h"

id<MKMDocumentFactory> MKMDocumentGetFactory(NSString *type) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory documentFactoryForType:type];
}

void MKMDocumentSetFactory(NSString *type, id<MKMDocumentFactory> factory) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    [man.generalFactory setDocumentFactory:factory forType:type];
}

id<MKMDocument> MKMDocumentCreate(NSString *type,
                                  id<MKMID> ID,
                                  NSString *data,
                                  id<MKMTransportableData> sig) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory createDocument:ID
                                         type:type
                                         data:data
                                    signature:sig];
}

id<MKMDocument> MKMDocumentParse(id doc) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory parseDocument:doc];
}
