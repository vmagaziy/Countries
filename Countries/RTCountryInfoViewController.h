#import <UIKit/UIKit.h>
#import "Countries+CoreDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTCountryInfoViewController : UITableViewController

@property (nonatomic, nullable) RTCountry *country;

@property (nonatomic) IBOutlet UITableViewCell *alpha2CodeCell;
@property (nonatomic) IBOutlet UITableViewCell *alpha3CodeCell;
@property (nonatomic) IBOutlet UITableViewCell *capitalCell;
@property (nonatomic) IBOutlet UITableViewCell *regionCell;
@property (nonatomic) IBOutlet UITableViewCell *populationCell;
@property (nonatomic) IBOutlet UITableViewCell *nativeNameCell;

@property (nonatomic) IBOutlet UIView *headerView;
@property (nonatomic) IBOutlet UIImageView *flagImageView;

@end

NS_ASSUME_NONNULL_END
