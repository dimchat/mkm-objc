// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2025 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2025 Albert Moky
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
//  MKMBroadcast.h
//  MingKeMing
//
//  Created by Albert Moky on 2025/10/7.
//  Copyright © 2025 DIM Group. All rights reserved.
//

#import <MingKeMing/MKMAddress.h>
#import <MingKeMing/MKMID.h>

NS_ASSUME_NONNULL_BEGIN

//
//  Broadcast Addresses
//

FOUNDATION_EXPORT id<MKMAddress> MKMAnywhere;    // "anywhere"
FOUNDATION_EXPORT id<MKMAddress> MKMEverywhere;  // "everywhere"

//
//  Broadcast IDs
//

FOUNDATION_EXPORT id<MKMID> MKMAnyone;    // "anyone@anywhere"
FOUNDATION_EXPORT id<MKMID> MKMEveryone;  // "everyone@everywhere"
FOUNDATION_EXPORT id<MKMID> MKMFounder;   // "moky@anywhere" (DIM Founder)

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Initializes broadcast ID/addresses.
 *
 * This function is designed to be automatically called before main()
 * using the GCC/Clang `__attribute__((constructor))` extension.
 *
 * Internally, it employs `dispatch_once` to ensure that the actual
 * initialization logic (creating NSString objects) is executed
 * exactly once across the application's lifecycle, and in a thread-safe manner.
 *
 * Manual invocation of this function is generally NOT required,
 * as it's automatically handled at program startup. It is primarily
 * exposed for extreme edge cases where the automatic invocation might
 * be circumvented (e.g., in highly specialized non-standard environments),
 * or for specific debugging/testing scenarios if necessary.
 * Multiple manual calls will still only result in a single initialization.
 */
void MKMInitializeBroadcastAddresses(void);
void MKMInitializeBroadcastIdentifiers(void);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

#pragma mark - Base Address

@interface MKMAddress : MKString <MKMAddress>

- (instancetype)initWithString:(NSString *)address
                          type:(MKMEntityType)network
NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - Base ID

@interface MKMID : MKString <MKMID>

/**
 *  Initialize an ID with string form "name@address[/terminal]"
 *
 * @param string - ID string
 * @param seed - username
 * @param address - hash(fingerprint)
 * @param location - login point (optional)
 * @return ID object
 */
- (instancetype)initWithString:(NSString *)string
                          name:(nullable NSString *)seed
                       address:(id<MKMAddress>)address
                      terminal:(nullable NSString *)location
NS_DESIGNATED_INITIALIZER;

@end

#ifdef __cplusplus
extern "C" {
#endif

//
//  ID format:
//
//      name + "@" + address + "/" + terminal
//
NSString *MKMIDConcat(NSString * _Nullable name,
                      id<MKMAddress> address,
                      NSString *_Nullable terminal);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
