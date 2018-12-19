// Copyright 2015 Interaxon, Inc.

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

#import "Muse/gen-objc/IXNCharacteristicId.h"
#import "Muse/gen-objc/IXNCharacteristicMapper.h"

@interface IXNCharacteristicMapperIos : NSObject

@property (nonatomic, readonly) IXNCharacteristicMapper* mapper;
@property (nonatomic, readonly) NSArray* allCharacteristicCBUUIDs;

+ (instancetype)instance;
- (CBUUID *)CBUUIDForCharacteristic:(IXNCharacteristicId)characteristic;
- (IXNCharacteristicId)characteristicForCBUUID:(CBUUID *)cbuuid;

@end
