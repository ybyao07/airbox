//
//  AlertBoxViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>
#import "AlertBox.h"

@interface AlertBoxViewController : UIViewController
{

}

- (void)dismiss:(void(^)())completionHandler;

@property (nonatomic, strong) NSString *message;
@property (nonatomic) BOOL hasCancelButton;
@property (nonatomic, weak) id <AlertBoxDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;


@end
