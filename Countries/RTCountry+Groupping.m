#import "RTCountry+Groupping.h"

@implementation RTCountry (Groupping)

- (NSString *)groupName
{
    // FIXME: May fail if name starts to be localized
    return [self.name substringToIndex:1];
}

@end
