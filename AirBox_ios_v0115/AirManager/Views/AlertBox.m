//
//  AlertBox.m
//  AirManager
//

#import "AlertBox.h"
#import "AppDelegate.h"
#import "AlertBoxViewController.h"
#import "RetryBoxViewController.h"
#import "SucceedBoxViewController.h"
#import "VersionCheckViewController.h"
#import "HintViewController.h"
//static AlertBox     *_sharedInstance = nil;

@interface AlertBox()

@property (nonatomic, strong) AlertBoxViewController *alertBoxViewController;
@property (nonatomic, strong) SucceedBoxViewController *succeedBoxViewController;
@property (nonatomic, strong) RetryBoxViewController *retryBoxViewController;
@property (nonatomic, strong) VersionCheckViewController *versionCheckViewController;
@property (nonatomic, strong) HintViewController *hintViewController;

@end

@implementation AlertBox

+ (void)showWithMessage:(NSString *)message
{
    [AlertBox showWithMessage:message delegate:nil showCancel:NO];
}

+ (void)showWithMessage:(NSString *)message delegate:(id <AlertBoxDelegate>)delegate showCancel:(BOOL)show
{
    if(MainDelegate.isShowingAlertBox)return;
    MainDelegate.isShowingAlertBox = YES;

    AlertBoxViewController *vc = [AlertBox sharedInstance].alertBoxViewController;
    vc.delegate = delegate;
    vc.view.alpha = 0;
    vc.view.frame = MainDelegate.window.frame;
    vc.message = message;
    vc.hasCancelButton = show;
    
    [MainDelegate.window addSubview:vc.view];
    [UIView animateWithDuration:0.3 animations:^{
        vc.view.alpha = 1.0;
    }];
}

+ (void)showWithMessage:(NSString *)message delegate:(id <AlertBoxDelegate>)delegate showCancel:(BOOL)show withTag:(NSInteger)tag
{
    if(MainDelegate.isShowingAlertBox)return;
    MainDelegate.isShowingAlertBox = YES;
    
    AlertBoxViewController *vc = [AlertBox sharedInstance].alertBoxViewController;
    vc.delegate = delegate;
    vc.view.alpha = 0;
    vc.view.frame = MainDelegate.window.frame;
    vc.message = message;
    vc.hasCancelButton = show;
    vc.tag = tag;
    
    [MainDelegate.window addSubview:vc.view];
    [UIView animateWithDuration:0.3 animations:^{
        vc.view.alpha = 1.0;
    }];
}

//ybyao07
+ (void)showHintWithMessage:(NSString *)message
{
    [AlertBox showHintWithMessage:message delegate:nil showCancel:NO];
}
//ybyao07
+ (void)showHintWithMessage:(NSString *)message delegate:(id <AlertBoxDelegate>)delegate showCancel:(BOOL)show
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(MainDelegate.isShowingAlertBox)return;
        MainDelegate.isShowingAlertBox = YES;
        
        HintViewController *vc = [AlertBox sharedInstance].hintViewController;
        vc.delegate = delegate;
        vc.view.alpha = 0;
        vc.view.frame = MainDelegate.window.frame;
        
        vc.message = message;
        vc.hasCancelButton = show;
        [MainDelegate.window addSubview:vc.view];
        [UIView animateWithDuration:0.3 animations:^{
            vc.view.alpha = 1.0;
        }];
    });
}



+ (void)showIsRetryBoxWithDelegate:(id <AlertBoxDelegate>)delegate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(MainDelegate.isShowingAlertBox)return;
        MainDelegate.isShowingAlertBox = YES;
    
        RetryBoxViewController *vc = [AlertBox sharedInstance].retryBoxViewController;
        vc.delegate = delegate;
    
        vc.view.alpha = 0;
        vc.view.frame = MainDelegate.window.frame;
        [MainDelegate.window addSubview:vc.view];
        [UIView animateWithDuration:0.3 animations:^{
            vc.view.alpha = 1.0;
        }];
    });
}

+ (void)showIsSucceedWithMessage:(NSString *)message delegate:(id <AlertBoxDelegate>)delegate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(MainDelegate.isShowingAlertBox)return;
        MainDelegate.isShowingAlertBox = YES;
        
        SucceedBoxViewController *vc = [AlertBox sharedInstance].succeedBoxViewController;
        vc.delegate = delegate;
        vc.view.alpha = 0;
        vc.view.frame = MainDelegate.window.frame;
        [MainDelegate.window addSubview:vc.view];
        [UIView animateWithDuration:0.3 animations:^{
            vc.view.alpha = 1.0;
        }];

        vc.message = message;
        vc.hasCancelButton = (delegate) ? YES : NO;
    });
}

+ (void)showIsUpdateWithMessage:(NSString *)message delegate:(id <AlertBoxDelegate>)delegate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(MainDelegate.isShowingAlertBox)return;
        MainDelegate.isShowingAlertBox = YES;
        
        VersionCheckViewController *vc = [AlertBox sharedInstance].versionCheckViewController;
        vc.delegate = delegate;
        vc.view.alpha = 0;
        vc.view.frame = MainDelegate.window.frame;
        [MainDelegate.window addSubview:vc.view];
        [UIView animateWithDuration:0.3 animations:^{
            vc.view.alpha = 1.0;
        }];
        
        vc.message = message;
        vc.hasCancelButton = (delegate) ? YES : NO;
    });
}

+ (AlertBox *)sharedInstance
{
//    if (!_sharedInstance)
//    {
//        _sharedInstance = [[AlertBox alloc] init];
//    }
//    
//    return _sharedInstance;
    
    static AlertBox *singleton = nil;
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        singleton = [[super allocWithZone:NULL] init];
    });
    return singleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (id)init
{
    
    //if (_sharedInstance) return _sharedInstance;
    
    self = [super init];
    if (self)
    {
        self.alertBoxViewController = [[AlertBoxViewController alloc] initWithNibName:@"AlertBoxViewController" bundle:nil];
        self.succeedBoxViewController = [[SucceedBoxViewController alloc] initWithNibName:@"SucceedBoxViewController" bundle:nil];
        self.retryBoxViewController = [[RetryBoxViewController alloc] initWithNibName:@"RetryBoxViewController" bundle:nil];
        self.versionCheckViewController = [[VersionCheckViewController alloc] initWithNibName:@"VersionCheckViewController" bundle:nil];
        self.hintViewController = [[HintViewController alloc] initWithNibName:@"HintViewController" bundle:nil];
    }
    
    return self;
}

@end
