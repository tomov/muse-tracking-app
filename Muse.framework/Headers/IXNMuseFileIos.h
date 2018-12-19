// Copyright 2015 InteraXon, Inc.

#import <Foundation/Foundation.h>
#import "Muse/gen-objc/IXNMuseFile.h"

/**
 * An iOS-specifc implementation of IXNMuseFile.
 * This implementation keeps the file open until the ::IXNMuseFile::close:
 * function is explicitly called. If you need a different implementation for
 * your situation or you want to write to the network instead of a file, use
 * the IXNMuseFile interface and provide your own implementation.
 */

@interface IXNMuseFileIos : NSObject <
                IXNMuseFile
>

- (instancetype)initWithFilePath:(NSString *)filePath;

@end
