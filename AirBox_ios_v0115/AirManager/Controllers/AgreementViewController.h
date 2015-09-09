//
//  AgreementViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface AgreementViewController : UIViewController
{
    IBOutlet UIWebView  *_webView;
    BOOL isFromRegisteView;
}

@property (nonatomic,assign) BOOL isFromRegisteView;
@property (nonatomic, strong) UIView *baseview;

@end
