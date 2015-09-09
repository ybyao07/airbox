//
//  CitySelectionViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface CitySelectionViewController : UIViewController <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView    *_tableView;
    IBOutlet UISearchBar    *_searchBar;
    
    NSArray                 *_cityArray;
    NSMutableArray          *_filteredCityArray;
    
    BOOL                    fromDeviceBind;
}

@property(nonatomic,assign)BOOL fromDeviceBind;

@end
