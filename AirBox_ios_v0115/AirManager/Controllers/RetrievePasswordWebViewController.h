//
//  RetrievePasswordWebViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface RetrievePasswordWebViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView                  *_webView;
    IBOutlet UIActivityIndicatorView    *_indicator;
}

@property (nonatomic, strong) UIView *baseview;

@end
