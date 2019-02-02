//
//  MKMBarrack+LocalStorage.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDictionary+Binary.h"

#import "MKMID.h"
#import "MKMMeta.h"

#import "MKMBarrack+LocalStorage.h"

@implementation MKMBarrack (LocalStorage)

static NSString *s_directory = nil;

// "Documents/.mkm"
- (NSString *)directory {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths;
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                    NSUserDomainMask, YES);
        NSString *dir = paths.firstObject;
        s_directory = [dir stringByAppendingPathComponent:@".mkm"];
    });
    return s_directory;
}

- (void)setDirectory:(NSString *)directory {
    s_directory = directory;
}

// "Documents/.mkm/{address}/meta.plist"
- (NSString *)_pathWithID:(const MKMID *)ID filename:(NSString *)name {
    NSString *dir = self.directory;
    dir = [dir stringByAppendingPathComponent:ID.address];
    
    // check base directory exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir isDirectory:nil]) {
        NSError *error = nil;
        // make sure directory exists
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES
                       attributes:nil error:&error];
        assert(!error);
    }
    
    return [dir stringByAppendingPathComponent:name];
}

- (MKMMeta *)loadMetaForEntityID:(const MKMID *)ID {
    MKMMeta *meta = nil;
    NSString *path = [self _pathWithID:ID filename:@"meta.plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        NSDictionary *dict;
        dict = [NSDictionary dictionaryWithContentsOfFile:path];
        meta = [[MKMMeta alloc] initWithDictionary:dict];
    }
    return meta;
}

- (BOOL)saveMeta:(const MKMMeta *)meta forEntityID:(const MKMID *)ID {
    if (![meta matchID:ID]) {
        NSAssert(!meta, @"meta error: %@, ID = %@", meta, ID);
        return NO;
    }
    NSString *path = [self _pathWithID:ID filename:@"meta.plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        NSLog(@"meta file already exists: %@, IGNORE!", path);
        return YES;
    }
    return [meta writeToBinaryFile:path];
}

@end
