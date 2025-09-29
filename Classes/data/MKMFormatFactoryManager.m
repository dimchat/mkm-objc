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
//  MKMFormatFactoryManager.m
//  MingKeMing
//
//  Created by Albert Moky on 2023/12/6.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "MKConverter.h"
#import "MKCopier.h"
#import "MKDataParser.h"
#import "MKMSymmetricKey.h"

#import "MKMFormatFactoryManager.h"

@implementation MKMFormatFactoryManager

static MKMFormatFactoryManager *s_manager = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [super allocWithZone:zone];
        s_manager.generalFactory = [[MKMGeneralFormatFactory alloc] init];
    });
    return s_manager;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[self alloc] init];
    });
    return s_manager;
}

@end

#pragma mark -

@interface MKMGeneralFormatFactory () {
    
    NSMutableDictionary<NSString *, id<MKMTransportableDataFactory>> *_tedFactories;
    
    id<MKMPortableNetworkFileFactory> _pnfFactory;
}

@end

@implementation MKMGeneralFormatFactory

- (instancetype)init {
    if ([super init]) {
        _tedFactories = [[NSMutableDictionary alloc] init];
        _pnfFactory = nil;
    }
    return self;
}

- (NSArray<NSString *> *)split:(NSString *)text {
    NSMutableArray<NSString *> *array = [[NSMutableArray alloc] init];
    // "{TEXT}", or
    // "base64,{BASE64_ENCODE}", or
    // "data:image/png;base64,{BASE64_ENCODE}"
    NSRange range1, range2, range3;
    range1 = [text rangeOfString:@"://"];
    if (range1.location != NSNotFound) {
        // [URL]
        [array addObject:text];
        return array;
    }
    range1 = [text rangeOfString:@";"];
    range2 = [text rangeOfString:@","];
    if (range2.location != NSNotFound) {
        // [data, algorithm]
        if (range1.location != NSNotFound) {
            range3 = NSMakeRange(range1.location + 1, range2.location - range1.location - 1);
        } else {
            range3 = NSMakeRange(0, range2.location);
        }
        [array addObject:[text substringFromIndex:(range2.location + 1)]];
        [array addObject:[text substringWithRange:range3]];
    } else if (range1.location != NSNotFound) {
        // [data]
        [array addObject:[text substringFromIndex:(range1.location + 1)]];
    } else {
        // [data]
        [array addObject:text];
    }
    return array;
}

- (NSDictionary *)decode:(id)data defaultKey:(NSString *)aKey {
    if ([data conformsToProtocol:@protocol(MKDictionary)]) {
        return [data dictionary];
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        return data;
    }
    NSString *text = [data isKindOfClass:[NSString class]] ? data : [data description];
    if ([text length] == 0) {
        return nil;
    } else if ([text hasPrefix:@"{"] && [text hasSuffix:@"}"]) {
        return MKJsonMapDecode(text);
    }
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    NSArray *array = [self split:text];
    if ([array count] == 1) {
        [info setObject:array.firstObject forKey:aKey];
    } else {
        NSAssert([array count] == 2, @"split error: %@ => %@", text, array);
        [info setObject:array.lastObject forKey:@"algorithm"];
        [info setObject:array.firstObject forKey:@"data"];
    }
    return info;
}

#pragma mark TED - Transportable Encoded Data

- (NSString *)algorithm:(NSDictionary<NSString *,id> *)ted defaultValue:(NSString *)aValue {
    id algorithm = [ted objectForKey:@"algorithm"];
    return MKConvertString(algorithm, aValue);
}

- (void)setTransportableDataFactory:(id<MKMTransportableDataFactory>)factory
                       forAlgorithm:(NSString *)algorithm {
    [_tedFactories setObject:factory forKey:algorithm];
}

- (id<MKMTransportableDataFactory>)transportableDataFactoryForAlgorithm:(NSString *)algorithm {
    return [_tedFactories objectForKey:algorithm];
}

- (id<MKMTransportableData>)createTransportableData:(NSData *)data
                                      withAlgorithm:(NSString *)algorithm {
    id<MKMTransportableDataFactory> factory = [self transportableDataFactoryForAlgorithm:algorithm];
    NSAssert(factory, @"TED algorithm not support: %@", algorithm);
    return [factory createTransportableData:data];
}

- (id<MKMTransportableData>)parseTransportableData:(id)ted {
    if (!ted) {
        return nil;
    } else if ([ted conformsToProtocol:@protocol(MKMTransportableData)]) {
        return ted;
    }
    // unwrap
    NSDictionary *info = [self decode:ted defaultKey:@"data"];
    if (!info) {
        NSAssert(false, @"TED error: %@", ted);
        return nil;
    }
    NSString *algorithm = [self algorithm:info defaultValue:@"*"];
    id<MKMTransportableDataFactory> factory = [self transportableDataFactoryForAlgorithm:algorithm];
    if (!factory) {
        NSAssert(![algorithm isEqualToString:@"*"], @"TED factory not ready: %@", ted);
        factory = [self transportableDataFactoryForAlgorithm:@"*"];  // unknown
        NSAssert(factory, @"default TED factory not found");
    }
    return [factory parseTransportableData:info];
}

#pragma mark PNF - Portable Network File

- (void)setPortableNetworkFileFactory:(id<MKMPortableNetworkFileFactory>)factory {
    _pnfFactory = factory;
}

- (id<MKMPortableNetworkFileFactory>)portableNetworkFileFactory {
    return _pnfFactory;;
}

- (id<MKMPortableNetworkFile>)createPortableNetworkFile:(id<MKMTransportableData>)data
                                               filename:(NSString *)name
                                                    url:(NSURL *)locator
                                               password:(id<MKMDecryptKey>)key {
    id<MKMPortableNetworkFileFactory> factory = [self portableNetworkFileFactory];
    NSAssert(factory, @"PNF factory not ready");
    return [factory createPortableNetworkFile:data filename:name url:locator password:key];
}

- (id<MKMPortableNetworkFile>)parsePortableNetworkFile:(id)pnf {
    if (!pnf) {
        return nil;
    } else if ([pnf conformsToProtocol:@protocol(MKMPortableNetworkFile)]) {
        return pnf;
    }
    // unwrap
    NSDictionary *info = [self decode:pnf defaultKey:@"URL"];
    if (!info) {
        NSAssert(false, @"PNF error: %@", pnf);
        return nil;
    }
    id<MKMPortableNetworkFileFactory> factory = [self portableNetworkFileFactory];
    NSAssert(factory, @"PNF factory not ready");
    return [factory parsePortableNetworkFile:info];
}

@end
