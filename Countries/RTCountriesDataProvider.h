#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol RTCancellable;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const RTCountriesDataProviderErrorDomain;

typedef NS_OPTIONS(NSUInteger, RTCountriesDataProviderErrorCode) {
    RTCountriesDataProviderErrorCodeNetworkRequestFailed,
    RTCountriesDataProviderErrorCodeMalformedJSONData,
    RTCountriesDataProviderErrorCodePersistingData
};

@interface RTCountriesDataProvider : NSObject

- (instancetype)initWithPersistentContainer:(NSPersistentContainer *)container;

@property (atomic, readonly, getter=isReloadingData) BOOL reloadingData;

typedef void (^RTCountriesDataProviderCompletion)(BOOL success, NSError *_Nullable error);
- (id<RTCancellable>)reloadDataWithCompletion:(RTCountriesDataProviderCompletion)completion;

@end

NS_ASSUME_NONNULL_END
