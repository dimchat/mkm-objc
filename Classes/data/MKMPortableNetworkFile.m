// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  MKMPortableNetworkFile.m
//  MingKeMing
//
//  Created by Albert Moky on 2023/12/6.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "MKMFormatFactoryManager.h"

#import "MKMPortableNetworkFile.h"

id<MKMPortableNetworkFileFactory> MKMPortableNetworkFileGetFactory(void) {
    MKMFormatFactoryManager *man = [MKMFormatFactoryManager sharedManager];
    return [man.generalFactory portableNetworkFileFactory];
}

void MKMPortableNetworkFileSetFactory(id<MKMPortableNetworkFileFactory> factory) {
    MKMFormatFactoryManager *man = [MKMFormatFactoryManager sharedManager];
    [man.generalFactory setPortableNetworkFileFactory:factory];
}

id<MKMPortableNetworkFile> MKMPortableNetworkFileParse(id pnf) {
    MKMFormatFactoryManager *man = [MKMFormatFactoryManager sharedManager];
    return [man.generalFactory parsePortableNetworkFile:pnf];
}

id<MKMPortableNetworkFile> MKMPortableNetworkFileCreate(id<MKMTransportableData> data,
                                                        NSString *filename,
                                                        NSURL *url,
                                                        id<MKMDecryptKey> password) {
    MKMFormatFactoryManager *man = [MKMFormatFactoryManager sharedManager];
    return [man.generalFactory createPortableNetworkFile:data
                                                filename:filename
                                                     url:url
                                                password:password];
}
