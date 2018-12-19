// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from sdk_bridge.djinni

#import <Foundation/Foundation.h>

/**
 * The Bluetooth Low Energy Characteristics supported by %Muse 2016 (
 * \if ANDROID_ONLY
 * \link com.choosemuse.libmuse.MuseModel.MU_02 MU_02\endlink
 * \elseif IOS_ONLY
 * \link ::IXNMuseModel::IXNMuseModelMu02 MU_02\endlink
 * \endif
 * ).
 */
typedef NS_ENUM(NSInteger, IXNCharacteristicId)
{
    /** Serial read/write. */
    IXNCharacteristicIdSerial,
    /**
     * Left auxiliary electrode measurement.
     *
     * This can be either left or left_bypass depending on the configuration.
     * The difference is that left_bypass has no gain applied to it.
     */
    IXNCharacteristicIdSignalAuxLeft,
    /** Behind-the-left-ear electrode measurement. */
    IXNCharacteristicIdSignalTp9,
    /** Left forehead electrode measurement. */
    IXNCharacteristicIdSignalFp1,
    /** Right forehead electrode measurement. */
    IXNCharacteristicIdSignalFp2,
    /** Behind-the-right-ear electrode measurement. */
    IXNCharacteristicIdSignalTp10,
    /**
     * Right auxiliary electrode measurement.
     *
     * This can be either right or right_bypass depending on the configuration.
     * The difference is that right_byapss has no gain applied to it.
     */
    IXNCharacteristicIdSignalAuxRight,
    /** DRL/REF measurement. */
    IXNCharacteristicIdDrlRef,
    /** Battery measurement. */
    IXNCharacteristicIdBattery,
    /** Accelerometer measurement. */
    IXNCharacteristicIdAccelerometer,
    /** Gyroscope measurement. */
    IXNCharacteristicIdGyro,
    /**
     * The id corresponding to the UUID for the %Muse service.
     *
     * This is technically not a characteristic, but we keep it here so we can
     * get its UUID in CharacteristicMapper.
     *
     * This is the first enum value after the last valid characteristic;
     * i.e. the code should be able to enumerate all valid characteristics by
     * iterating over the range [0, muse_service).
     */
    IXNCharacteristicIdMuseService,
};
