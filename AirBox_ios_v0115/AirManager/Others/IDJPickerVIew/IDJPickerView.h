//
//  IDJPickerView.h
//

#import <UIKit/UIKit.h>
#import "IDJScrollComponent.h"
#define WHEEL_SPACE 10


@interface IDJPickerView : UIView <UITableViewDataSource, UITableViewDelegate, IDJScrollComponentDelegate> {
    NSMutableArray *_scrolls;
    NSMutableArray *_scrollWidthProportion;
    NSUInteger _cellCountInVisible;
    NSUInteger _selectionPosition;
    UIImageView *wheelCenterView;
    NSMutableArray *_numberOfCellsInScroll;
    BOOL dataLoop;
    int hour;
    int minute;
}

@property (nonatomic) NSTimeInterval countDownDuration;
@property (nonatomic,retain)NSMutableArray *_numberOfCellsInScroll;

- (id)initWithFrame:(CGRect)frame dataLoop:(BOOL)_loop;
- (void)selectCell:(NSUInteger)cell inScroll:(NSUInteger)scroll;
- (void)setHour:(int)anHour  minute:(int)onMinute;

- (void)reloadScroll:(NSUInteger)scroll;

- (void)configPickerView;

@end
