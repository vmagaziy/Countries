#import "RTAppDelegate.h"
#import "RTCountryInfoViewController.h"
#import "RTCountriesViewController.h"
#import "UIColor+Branding.h"

@interface RTAppDelegate () <UISplitViewControllerDelegate>

@property (nonatomic) NSPersistentContainer *persistentContainer;

@end

@implementation RTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;

    UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
    RTCountriesViewController *controller = (RTCountriesViewController *)masterNavigationController.topViewController;
    controller.persistentContainer = self.persistentContainer;

    self.window.tintColor = [UIColor rt_brandColor];

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] &&
        [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[RTCountryInfoViewController class]] &&
        ([(RTCountryInfoViewController *)[(UINavigationController *)secondaryViewController topViewController] country] == nil))
    {
        return YES; // YES indicates that we have handled the collapse by doing nothing; the secondary controller will be discarded.
    }
    else
    {
        return NO;
    }
}

#pragma mark - Data

- (NSPersistentContainer *)persistentContainer
{
    @synchronized(self)
    {
        if (!_persistentContainer)
        {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Countries"];
            _persistentContainer.viewContext.automaticallyMergesChangesFromParent = YES;
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (!storeDescription)
                {
                    // FIXME: replace this implementation with code to handle the error appropriately.
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                }
            }];
        }
    }

    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext
{
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error])
    {
        // FIXME: replace this implementation with code to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
    }
}

@end
