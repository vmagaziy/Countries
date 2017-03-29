#import "RTCountryInfoViewController.h"
#import "UIColor+Branding.h"

@implementation RTCountryInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.headerView.backgroundColor = [[UIColor rt_brandColor] colorWithAlphaComponent:0.1];

    self.alpha2CodeCell.textLabel.text = NSLocalizedString(@"Two-letter Code", @"Two-letter code");
    self.alpha3CodeCell.textLabel.text = NSLocalizedString(@"Three-letter Code", @"Three-letter code");
    self.capitalCell.textLabel.text = NSLocalizedString(@"Capital", @"Capital");
    self.regionCell.textLabel.text = NSLocalizedString(@"Region", @"Region");
    self.populationCell.textLabel.text = NSLocalizedString(@"Population", @"Population");
    self.nativeNameCell.textLabel.text = NSLocalizedString(@"Native Name", @"Native Name");

    [self updateView];
}

- (void)setCountry:(RTCountry *)country
{
    if (_country != country)
    {
        _country = country;
        [self updateView];
    }
}

#pragma mark - Implementation

- (void)updateView
{
    self.title = self.country.name;

    NSString *unknownString = NSLocalizedString(@"Unknown", @"Unknown");

    NSString *alpha2Code = self.country.alpha2Code;
    self.alpha2CodeCell.detailTextLabel.text = alpha2Code.length != 0 ? alpha2Code : unknownString;

    NSString *alpha3Code = self.country.alpha3Code;
    self.alpha3CodeCell.detailTextLabel.text = alpha3Code.length != 0 ? alpha3Code : unknownString;

    NSString *capital = self.country.capital;
    self.capitalCell.detailTextLabel.text = capital.length != 0 ? capital : unknownString;

    NSString *region = self.country.region;
    self.regionCell.detailTextLabel.text = region.length != 0 ? region : unknownString;

    self.populationCell.detailTextLabel.text = self.country.population != 0 ? [NSNumberFormatter localizedStringFromNumber:@(self.country.population) numberStyle:NSNumberFormatterDecimalStyle] : unknownString;

    NSString *nativeName = self.country.nativeName;
    self.nativeNameCell.detailTextLabel.text = nativeName.length != 0 ? nativeName : unknownString;

    UIImage *flagImage = [UIImage imageNamed:self.country.alpha2Code];
    self.flagImageView.image = flagImage;
    self.headerView.frame = flagImage ? CGRectMake(0, 0, 0, [[self class] defaultHeaderHeight]) : CGRectZero;
}

+ (CGFloat)defaultHeaderHeight
{
    return 100;
}

@end
