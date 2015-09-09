//
//  MainViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController
{

}

@property (nonatomic, strong) UIView *baseview;

/**
 *  Open Home Page
 **/
- (void)pushToHomeView;

/**
 *  Open Air Box Bind Page
 **/
- (void)openAirBoxBindPage;

/**
 *  Open activate page in main view.
 **/
- (void)openActivatePage;

/**
 *  Auto login after registe succeed
 **/
- (void)autoLogin:(NSString *)userName andPassword:(NSString *)password;

- (void)clearLoginInfo;

@end
