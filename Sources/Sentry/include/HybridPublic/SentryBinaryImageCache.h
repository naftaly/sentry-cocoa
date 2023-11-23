#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SentryBinaryImageInfo : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic) uint64_t address;
@property (nonatomic) uint64_t size;
@property (nonatomic, copy) NSDate *startReadingPages;
@property (nonatomic, copy) NSDate *endReadingPages;
@end

/**
 * This class listens to `SentryCrashBinaryImageCache` to keep a copy of the loaded binaries
 * information in a sorted collection that will be used to symbolicate frames with better
 * performance.
 */
@interface SentryBinaryImageCache : NSObject

- (void)start;

- (void)stop;

- (nullable SentryBinaryImageInfo *)imageByAddress:(const uint64_t)address;

- (NSArray<SentryBinaryImageInfo *> *)imagesSortedByAddedDate;

@end

NS_ASSUME_NONNULL_END
