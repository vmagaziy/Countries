#import "Countries+CoreDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTCountry (JSONUpdate)

- (void)updateWithJSONDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
