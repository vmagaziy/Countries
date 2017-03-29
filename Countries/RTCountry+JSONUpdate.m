#import "RTCountry+JSONUpdate.h"

@implementation RTCountry (JSONUpdate)

- (void)updateWithJSONDictionary:(NSDictionary *)dictionary
{
    self.name = dictionary[@"name"];
    self.alpha2Code = dictionary[@"alpha2Code"];
    self.alpha3Code = dictionary[@"alpha3Code"];
    self.capital = dictionary[@"capital"];
    self.region = dictionary[@"region"];
    self.population = [dictionary[@"population"] integerValue];
    self.nativeName = dictionary[@"nativeName"];
}

@end
