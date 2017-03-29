#import "RTCountriesViewController.h"
#import "RTCountryInfoViewController.h"
#import "Countries+CoreDataModel.h"
#import "RTCountriesDataProvider.h"
#import "RTCancellable.h"
#import "UIColor+Branding.h"

@interface RTCountriesViewController () <UISearchResultsUpdating>

@property (nonatomic) NSFetchedResultsController<RTCountry *> *fetchedResultsController;
@property (nonatomic) RTCountriesDataProvider *dataProvider;
@property (nonatomic) id<RTCancellable> currentTask;
@property (nonatomic) NSArray<NSString *> *sectionIndexTitles;
@property (nonatomic) UISearchController *searchController;

@end

@implementation RTCountriesViewController

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"Countries", @"Title for controller showing the list of countries");

    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];

    self.dataProvider = [[RTCountriesDataProvider alloc] initWithPersistentContainer:self.persistentContainer];
    self.detailViewController = (RTCountryInfoViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.placeholder = NSLocalizedString(@"Country name or code", @"Placeholder of filter for countries");
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;

    [self updateData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.currentTask cancel];
    self.currentTask = nil;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RTCountry *country = [self.fetchedResultsController objectAtIndexPath:indexPath];
        RTCountryInfoViewController *controller = (RTCountryInfoViewController *)[[segue destinationViewController] topViewController];
        controller.country = country;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = self.fetchedResultsController.sections.count;
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    NSInteger numberOfObjects = sectionInfo.numberOfObjects;
    return numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[[self class] cellReuseIdentifier] forIndexPath:indexPath];
    RTCountry *country = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withCountry:country];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.name;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.searchController.isActive ? nil : self.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (index == 0)
    {
        UISearchBar *searchBar = self.searchController.searchBar;
        [tableView scrollRectToVisible:searchBar.bounds animated:YES];
    }

    return index - 1;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController<RTCountry *> *)fetchedResultsController
{
    if (!_fetchedResultsController)
    {
        NSFetchRequest<RTCountry *> *fetchRequest = RTCountry.fetchRequest;

        NSString *query = self.searchController.searchBar.text;
        NSPredicate *predicate = (query.length != 0) ? [NSPredicate predicateWithFormat:@"name contains[c] %@ OR alpha2Code contains[c] %@", query, query] : nil;
        fetchRequest.predicate = predicate;

        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        fetchRequest.sortDescriptors = @[sortDescriptor];

        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.persistentContainer.viewContext sectionNameKeyPath:@"groupName" cacheName:nil];
        _fetchedResultsController.delegate = self;

        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error])
        {
            [self presentError:error];
        }
    }

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)country
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;

    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withCountry:country];
            break;

        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
}

#pragma mark - Implementation

- (void)updateData
{
    if (self.dataProvider.isReloadingData)
    {
        if (self.refreshControl.isRefreshing)
        {
            [self.refreshControl endRefreshing];
        }

        return;
    }

    __weak typeof(self) weakSelf = self;
    self.currentTask = [self.dataProvider reloadDataWithCompletion:^(BOOL success, NSError *_Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success)
            {
                weakSelf.currentTask = nil;
                if (weakSelf.refreshControl.isRefreshing)
                {
                    [weakSelf.refreshControl endRefreshing];
                }
            }
            else
            {
                [weakSelf presentError:error];
            }
        });
    }];
}

+ (NSString *)cellReuseIdentifier
{
    return @"Cell";
}

- (NSArray<NSString *> *)sectionIndexTitles
{
    if (!_sectionIndexTitles)
    {
        NSArray *collationSectionIndexTitles = [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
        _sectionIndexTitles = [@[UITableViewIndexSearch] arrayByAddingObjectsFromArray:collationSectionIndexTitles];
    }
    return _sectionIndexTitles;
}

- (void)configureCell:(UITableViewCell *)cell withCountry:(RTCountry *)country
{
    cell.textLabel.text = country.name;
}

- (void)presentError:(NSError *)error
{
    NSString *message;
    NSString *errorDomain = error.domain;
    NSInteger errorCode = error.code;
    if ([errorDomain isEqualToString:RTCountriesDataProviderErrorDomain])
    {
        if (errorCode == RTCountriesDataProviderErrorCodeNetworkRequestFailed)
        {
            message = NSLocalizedString(@"Failed to load data from the server. Please try again.", @"Error message shown on impossibility to load data from the server");
        }
        else if (errorCode == RTCountriesDataProviderErrorCodeMalformedJSONData)
        {
            message = NSLocalizedString(@"Malformed data is provided by the server. Please try again.", @"Error message shown on impossibility to parse data from the server");
        }
        else if (errorCode == RTCountriesDataProviderErrorCodePersistingData)
        {
            message = NSLocalizedString(@"Failed to save data. Please try again.", @"Error message shown on impossibility to save data to the persistent storage");
        }
    }
    else
    {
        message = error.localizedDescription;
    }

    if (!message)
    {
        message = NSLocalizedString(@"Unknown error", @"Message shown on unknown error");
    }

    NSString *title = NSLocalizedString(@"Unknown error", @"Message shown on unknown error");

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
