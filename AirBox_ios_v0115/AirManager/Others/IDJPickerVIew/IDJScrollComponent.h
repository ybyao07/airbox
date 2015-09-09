//
//  ScrollComponent.h
//

#import <Foundation/Foundation.h>

@protocol IDJScrollComponentDelegate;

@interface IDJScrollComponent : UIScrollView<UIScrollViewDelegate> {
	NSArray *views;
	int curentIdx;
}
@property (retain, nonatomic) NSArray *views;
@property (assign, nonatomic) int curentIdx;
@property (assign, nonatomic) id<IDJScrollComponentDelegate> idjsDelegate;
- (id)initWithFrame:(CGRect)rect withViews:(NSArray*)_views;
@end

@protocol IDJScrollComponentDelegate <NSObject>

@required - (void)stopScroll:(IDJScrollComponent *)sc;
@end

