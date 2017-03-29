#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Countries+CoreDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@class RTCountryInfoViewController, RTCountriesDataProvider;

@interface RTCountriesViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic) RTCountryInfoViewController *detailViewController;
@property (nonatomic) NSPersistentContainer *persistentContainer;

@end

NS_ASSUME_NONNULL_END
