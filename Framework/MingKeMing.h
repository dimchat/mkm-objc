// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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
//  MingKeMing.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for MingKeMing.
FOUNDATION_EXPORT double MingKeMingVersionNumber;

//! Project version string for MingKeMing.
FOUNDATION_EXPORT const unsigned char MingKeMingVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MingKeMing/PublicHeader.h>

#if !defined(__MING_KE_MING__)
#define __MING_KE_MING__ 1

#import <MingKeMing/MKMSymmetricKey.h>
#import <MingKeMing/MKMPublicKey.h>
#import <MingKeMing/MKMPrivateKey.h>

#import <MingKeMing/MKMDataCoder.h>
#import <MingKeMing/MKMDataParser.h>
#import <MingKeMing/MKMDataDigester.h>

// Entity
#import <MingKeMing/MKMID.h>
#import <MingKeMing/MKMAddress.h>
#import <MingKeMing/MKMMeta.h>
#import <MingKeMing/MKMProfile.h>
#import <MingKeMing/MKMEntity.h>

//-
#import <MingKeMing/MKMUser.h>
#import <MingKeMing/MKMGroup.h>


#endif /* ! __MING_KE_MING__ */
