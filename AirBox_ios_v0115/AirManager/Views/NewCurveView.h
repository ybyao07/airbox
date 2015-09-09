//
//  NewCurveView.h
//  AirManager
//

#import <UIKit/UIKit.h>

typedef enum
{
    kExponent = 0,
    kTemp,
    kHum,
    kPM25
}CurveType;

@interface NewCurveView : UIView
{
    
}

/**
 *  init view with frame and set the data will display on this view
 **/
- (id)initWithFrame:(CGRect)frame andData:(NSMutableArray *)array isPM:(BOOL)pm curveType:(CurveType)type isDay:(BOOL)day;

@end
