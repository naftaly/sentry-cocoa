#include "SentryProfilingConditionals.h"
#import "SentryTransactionContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface
SentryTransactionContext ()

- (instancetype)initWithName:(NSString *)name
                  nameSource:(SentryTransactionNameSource)source
                   operation:(NSString *)operation
                      origin:(NSString *)origin;

- (instancetype)initWithName:(NSString *)name
                  nameSource:(SentryTransactionNameSource)source
                   operation:(NSString *)operation
                      origin:(NSString *)origin
                     sampled:(SentrySampleDecision)sampled;

- (instancetype)initWithName:(NSString *)name
                  nameSource:(SentryTransactionNameSource)source
                   operation:(nonnull NSString *)operation
                      origin:(NSString *)origin
                     traceId:(SentryId *)traceId
                      spanId:(SentrySpanId *)spanId
                parentSpanId:(nullable SentrySpanId *)parentSpanId
               parentSampled:(SentrySampleDecision)parentSampled;

- (instancetype)initWithName:(NSString *)name
                  nameSource:(SentryTransactionNameSource)source
                   operation:(NSString *)operation
                      origin:(NSString *)origin
                     traceId:(SentryId *)traceId
                      spanId:(SentrySpanId *)spanId
                parentSpanId:(nullable SentrySpanId *)parentSpanId
                     sampled:(SentrySampleDecision)sampled
               parentSampled:(SentrySampleDecision)parentSampled;

#if SENTRY_TARGET_PROFILING_SUPPORTED && SENTRY_PROFILING_MODE_LEGACY
// This is currently only exposed for testing purposes, see -[SentryProfilerTests
// testProfilerMutationDuringSerialization]
// !!!: the above comment is no longer true. remove this declaration
@property (nonatomic, strong) SentryThread *threadInfo;

- (SentryThread *)sentry_threadInfo;
#endif // SENTRY_TARGET_PROFILING_SUPPORTED && SENTRY_PROFILING_MODE_LEGACY

@end

NS_ASSUME_NONNULL_END
