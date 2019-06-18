//
//  MKMID.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAddress.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  ID for entity (Account/Group)
 *
 *      data format: "name@address[/terminal]"
 *
 *      fileds:
 *          name     - entity name, the seed of fingerprint to build address
 *          address  - a string to identify an entity
 *          terminal - entity login resource(device), OPTIONAL
 */
@interface MKMID : MKMString

@property (readonly, strong, nonatomic, nullable) NSString *name;
@property (readonly, strong, nonatomic) const MKMAddress *address;

@property (readonly, nonatomic) MKMNetworkType type; // Network ID
@property (readonly, nonatomic) UInt32 number;       // search number

@property (strong, nonatomic, nullable) NSString * terminal;

@property (readonly, nonatomic, getter=isValid) BOOL valid;

/**
 *  Initialize an ID with string form "name@address[/terminal]"
 *
 * @param aString - ID string
 * @return ID object
 */
- (instancetype)initWithString:(NSString *)aString;

/**
 *  Initialize an ID with username & address
 *
 * @param seed - username
 * @param addr - hash(fingerprint)
 * @return ID object
 */
- (instancetype)initWithName:(nullable const NSString *)seed
                     address:(const MKMAddress *)addr;

/**
 *  For BTC address
 */
- (instancetype)initWithAddress:(const MKMAddress *)addr;

/**
 *  ID without terminal
 *
 * @return ID object
 */
- (instancetype)naked;

@end

// convert String to ID
#define MKMIDFromString(identifier)      [MKMID getInstance:(identifier)]

@interface MKMID (Runtime)

+ (nullable instancetype)getInstance:(id)ID;

@end

NS_ASSUME_NONNULL_END
