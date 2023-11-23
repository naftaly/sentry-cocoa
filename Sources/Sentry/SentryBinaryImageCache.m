#import "SentryBinaryImageCache.h"
#import "SentryCrashBinaryImageCache.h"
#import "SentryDependencyContainer.h"
#include <mach/mach_time.h>

static void binaryImageWasAdded(const SentryCrashBinaryImage *image);

static void binaryImageWasRemoved(const SentryCrashBinaryImage *image);

@implementation SentryBinaryImageInfo
@end

@interface
SentryBinaryImageCache ()
@property (nonatomic, strong) NSMutableArray<SentryBinaryImageInfo *> *cache;
- (void)binaryImageAdded:(const SentryCrashBinaryImage *)image;
- (void)binaryImageRemoved:(const SentryCrashBinaryImage *)image;
@end

@implementation SentryBinaryImageCache

- (void)start
{
    _cache = [NSMutableArray array];
    sentrycrashbic_registerAddedCallback(&binaryImageWasAdded);
    sentrycrashbic_registerRemovedCallback(&binaryImageWasRemoved);
}

- (void)stop
{
    sentrycrashbic_registerAddedCallback(NULL);
    sentrycrashbic_registerRemovedCallback(NULL);
    _cache = nil;
}

- (void)binaryImageAdded:(const SentryCrashBinaryImage *)image
{
    SentryBinaryImageInfo *newImage = [[SentryBinaryImageInfo alloc] init];
    newImage.name = [NSString stringWithCString:image->name encoding:NSUTF8StringEncoding];
    newImage.address = image->address;
    newImage.size = image->size;
    newImage.startReadingPages = [self convertUint:image->startReadingPages];
    newImage.endReadingPages = [self convertUint:image->endReadingPages];

    @synchronized(self) {
        NSUInteger left = 0;
        NSUInteger right = _cache.count;

        while (left < right) {
            NSUInteger mid = (left + right) / 2;
            SentryBinaryImageInfo *compareImage = _cache[mid];
            if (newImage.address < compareImage.address) {
                right = mid;
            } else {
                left = mid + 1;
            }
        }

        [_cache insertObject:newImage atIndex:left];
    }
}

- (NSDate *)convertUint:(uint64_t)absoluteTime
{

    // Step 1: Get timebase info
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);

    // Step 4: Convert to nanoseconds
    uint64_t absoluteNanos = absoluteTime * info.numer / info.denom;

    uint64_t absoluteNowNanos = mach_absolute_time() * info.numer / info.denom;

    // Step 5: Convert to seconds
    NSTimeInterval absoluteSeconds = (NSTimeInterval)absoluteNanos / 1e9;
    NSTimeInterval absoluteNowSeconds = (NSTimeInterval)absoluteNowNanos / 1e9;

    // Step 6: Add to a reference NSDate (assuming now is the reference)
    NSDate *referenceDate = [NSDate date];
    NSDate *resultDate =
        [referenceDate dateByAddingTimeInterval:-(absoluteNowSeconds - absoluteSeconds)];

    return resultDate;
}

- (void)binaryImageRemoved:(const SentryCrashBinaryImage *)image
{
    @synchronized(self) {
        NSInteger index = [self indexOfImage:image->address];
        if (index >= 0) {
            [_cache removeObjectAtIndex:index];
        }
    }
}

- (nullable SentryBinaryImageInfo *)imageByAddress:(const uint64_t)address;
{
    @synchronized(self) {
        NSInteger index = [self indexOfImage:address];
        return index >= 0 ? _cache[index] : nil;
    }
}

- (NSInteger)indexOfImage:(uint64_t)address
{
    if (_cache == nil)
        return -1;

    NSInteger left = 0;
    NSInteger right = _cache.count - 1;

    while (left <= right) {
        NSInteger mid = (left + right) / 2;
        SentryBinaryImageInfo *image = _cache[mid];

        if (address >= image.address && address < (image.address + image.size)) {
            return mid;
        } else if (address < image.address) {
            right = mid - 1;
        } else {
            left = mid + 1;
        }
    }

    return -1; // Address not found
}

- (NSArray<SentryBinaryImageInfo *> *)imagesSortedByAddedDate
{
    NSMutableArray *copy = _cache.mutableCopy;

    [copy sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SentryBinaryImageInfo *image1 = (SentryBinaryImageInfo *)obj1;
        SentryBinaryImageInfo *image2 = (SentryBinaryImageInfo *)obj2;
        return [image1.startReadingPages compare:image2.startReadingPages];
    }];

    return copy;
}

@end

static void
binaryImageWasAdded(const SentryCrashBinaryImage *image)
{
    [SentryDependencyContainer.sharedInstance.binaryImageCache binaryImageAdded:image];
}

static void
binaryImageWasRemoved(const SentryCrashBinaryImage *image)
{
    [SentryDependencyContainer.sharedInstance.binaryImageCache binaryImageRemoved:image];
}
