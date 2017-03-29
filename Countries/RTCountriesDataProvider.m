#import "RTCountriesDataProvider.h"
#import "RTCancellable.h"
#import "Countries+CoreDataModel.h"
#import "RTCountry+JSONUpdate.h"

NSString *const RTCountriesDataProviderErrorDomain = @"RTCountriesDataProviderErrorDomain";

@interface RTCountriesDataProvider ()

@property (atomic) NSPersistentContainer *container;
@property (atomic, readwrite, getter=isReloadingData) BOOL reloadingData;

@end

@interface NSURLSessionDataTask () <RTCancellable>
@end

@implementation RTCountriesDataProvider

- (instancetype)initWithPersistentContainer:(NSPersistentContainer *)container
{
    self = [super init];
    if (self)
    {
        _container = container;
    }
    return self;
}

- (id<RTCancellable>)reloadDataWithCompletion:(RTCountriesDataProviderCompletion)completion
{
    NSAssert(!self.isReloadingData, @"Invalid state");

    self.reloadingData = YES;

    NSURL *url = [[self class] URLForJSONData];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                 if (!data)
                                                                 {
                                                                     self.reloadingData = NO;
                                                                     NSDictionary *userInfo = error ? @{NSUnderlyingErrorKey: error} : nil;
                                                                     completion(NO, [NSError errorWithDomain:RTCountriesDataProviderErrorDomain
                                                                                                        code:RTCountriesDataProviderErrorCodeNetworkRequestFailed
                                                                                                    userInfo:userInfo]);
                                                                 }
                                                                 else
                                                                 {
                                                                     [weakSelf reloadWithData:data completion:completion];
                                                                 }
                                                             }];

    [task resume];

    return task;
}

#pragma mark -

- (void)reloadWithData:(NSData *)data
            completion:(RTCountriesDataProviderCompletion)completion
{
    // avoid blocking URL session queue for processing data and updates
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *jsonError;
        NSArray<NSDictionary *> *jsonEntries = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (!jsonEntries)
        {
            self.reloadingData = NO;
            NSDictionary *userInfo = jsonError ? @{NSUnderlyingErrorKey: jsonError} : nil;
            completion(NO, [NSError errorWithDomain:RTCountriesDataProviderErrorDomain
                                               code:RTCountriesDataProviderErrorCodeMalformedJSONData
                                           userInfo:userInfo]);
            return;
        }

        NSMutableDictionary *jsonEntriesMap = [NSMutableDictionary dictionaryWithCapacity:jsonEntries.count];
        for (NSDictionary *jsonEntry in jsonEntries)
        {
            NSString *countryId = jsonEntry[@"alpha2Code"];
            if (countryId)
            {
                jsonEntriesMap[countryId] = jsonEntry;
            }
        }

        [weakSelf reloadWithJSONEntriesMap:jsonEntriesMap completion:completion];
    });
}

- (void)reloadWithJSONEntriesMap:(NSDictionary *)map
                      completion:(RTCountriesDataProviderCompletion)completion
{
    // update the background context and save changes in a batch to generate corresponding UI updates
    __weak typeof(self) weakSelf = self;
    [self.container performBackgroundTask:^(NSManagedObjectContext *context) {
        NSError *fetchError;
        NSArray *countries = [context executeFetchRequest:RTCountry.fetchRequest error:&fetchError];
        if (!countries)
        {
            weakSelf.reloadingData = NO;
            NSDictionary *userInfo = fetchError ? @{NSUnderlyingErrorKey: fetchError} : nil;
            completion(NO, [NSError errorWithDomain:RTCountriesDataProviderErrorDomain
                                               code:RTCountriesDataProviderErrorCodeMalformedJSONData
                                           userInfo:userInfo]);
            return;
        }

        NSMutableSet<NSString *> *handledCountryIds = [NSMutableSet set];
        for (RTCountry *country in countries)
        {
            NSString *countryId = country.alpha2Code;
            if (countryId)
            {
                NSDictionary *jsonDictionary = map[countryId];
                if (jsonDictionary)
                {
                    [country updateWithJSONDictionary:jsonDictionary];
                    [context refreshObject:country mergeChanges:YES];
                }

                [handledCountryIds addObject:countryId];
            }
            else
            {
                [context deleteObject:country]; // delete no longer referenced country
            }
        }

        // add new countries
        [map enumerateKeysAndObjectsUsingBlock:^(NSString *countryId, NSDictionary *jsonDictionary, BOOL *stop) {
            if (![handledCountryIds containsObject:countryId])
            {
                RTCountry *country = [[RTCountry alloc] initWithContext:context];
                if (country)
                {
                    [country updateWithJSONDictionary:jsonDictionary];
                    [context insertObject:country];
                }
            }
        }];

        NSError *saveError;
        if (![context save:&saveError])
        {
            weakSelf.reloadingData = NO;
            NSDictionary *userInfo = saveError ? @{NSUnderlyingErrorKey: saveError} : nil;
            completion(NO, [NSError errorWithDomain:RTCountriesDataProviderErrorDomain
                                               code:RTCountriesDataProviderErrorCodePersistingData
                                           userInfo:userInfo]);
            return;
        }

        weakSelf.reloadingData = NO;
        completion(YES, nil);
    }];
}

+ (NSURL *)URLForJSONData
{
    return [NSURL URLWithString:@"https://restcountries.eu/rest/v2/all"];
}

@end
