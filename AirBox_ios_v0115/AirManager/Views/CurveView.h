//
//  CurveView.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface CurveView : UIView
{
    
}

/**
 *  init view with frame and set the data will display on this view
 **/
- (id)initWithFrame:(CGRect)frame andData:(NSMutableArray *)array isPM:(BOOL)pm;

@end
