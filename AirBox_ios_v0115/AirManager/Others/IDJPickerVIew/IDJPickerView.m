//
//  IDJPickerView.m
//

#import "IDJPickerView.h"
#import "IDJScrollComponent.h"

@interface IDJPickerView (Private)
- (void)_setBackgroundImage;
- (void)_setWheelView;
- (void)_setTableViews:(NSUInteger)scroll;
- (void)_setSelectionArea;
- (void)createPickerView;
@end

@implementation IDJPickerView

@synthesize _numberOfCellsInScroll;

#pragma mark -init method-
- (id)initWithFrame:(CGRect)frame dataLoop:(BOOL)_loop{
    self = [super initWithFrame:frame];
    if (self) {
        dataLoop=_loop;
        NSMutableArray *array = [[NSMutableArray alloc] init];
        self._numberOfCellsInScroll = array;
    }
    return self;
}

- (void)configPickerView {
    
    [self _setBackgroundImage];
    
    NSArray *array=[@"1:1" componentsSeparatedByString:@":"];
    CGFloat total=0.0;
    for (int i=0; i<array.count; i++) {
        total+=[[array objectAtIndex:i]floatValue];
    }
    _scrollWidthProportion=[[NSMutableArray alloc]initWithCapacity:array.count];
    for (int i=0; i<array.count; i++) {
        [_scrollWidthProportion addObject:[NSString stringWithFormat:@"%f", [[array objectAtIndex:i]floatValue]/total]];
    }
    
    _scrolls=[[NSMutableArray alloc]initWithCapacity:_scrollWidthProportion.count];
    [self _setWheelView];
    
    _cellCountInVisible=3;
    _selectionPosition=1;
    if (_selectionPosition>=_cellCountInVisible) {
        NSException *e=[NSException
                        exceptionWithName: @"IDJException"
                        reason: @"The _selectionPosition must be less than _cellCountInVisible."
                        userInfo:nil];
        @throw e;
    }
    [self _setSelectionArea];
    [self _setTableViews:INT_MAX];
}

#pragma mark -Assemble UI Elements-

- (void)_setBackgroundImage {
    UIImageView *bgImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    bgImage.backgroundColor = [UIColor clearColor];//kSetTimeCellBodyColor;
    [self addSubview:bgImage];
}


- (void)_setWheelView {
    
    wheelCenterView=[[UIImageView alloc]initWithFrame:CGRectMake(0,0,self.frame.size.width,162)];
    wheelCenterView.backgroundColor = [UIColor clearColor];//kSetTimeCellBodyColor;
    [self addSubview:wheelCenterView];
    
    wheelCenterView.clipsToBounds=YES;
}


- (void)_setTableViews:(NSUInteger)scroll {
    if (dataLoop) {
        CGFloat x=0.0;
        int start=0;
        int counts=_scrollWidthProportion.count;
        
        if (scroll==INT_MAX) {
            NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:_scrollWidthProportion.count];
            self._numberOfCellsInScroll=array;
        } else {
            start=scroll;
            counts=scroll+1;
        }
        for (int i=start; i<counts; i++) {
            int numberOfCells = 0;
            
            if (i == start) {
                numberOfCells = 13;
            }
            
            if (i-1 == start) {
                numberOfCells = 60;
            }
            if (scroll==INT_MAX) {
                
                [_numberOfCellsInScroll addObject:[NSString stringWithFormat:@"%d", numberOfCells]];
            } else {
                [_numberOfCellsInScroll replaceObjectAtIndex:scroll withObject:[NSString stringWithFormat:@"%d", numberOfCells]];
            }
            NSMutableArray *views=[[NSMutableArray alloc]initWithCapacity:3];
            
            CGFloat height=wheelCenterView.frame.size.height/_cellCountInVisible*numberOfCells;
            if (height<wheelCenterView.frame.size.height) {
                NSException *e=[NSException
                                exceptionWithName: @"IDJException"
                                reason: @"The number of row must be greater and equal to the height of wheelCenterView."
                                userInfo:nil];
                @throw e;
            }
            
            for (int j=0; j<3; j++) {
                UITableView *tv=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, [[_scrollWidthProportion objectAtIndex:i]floatValue]*wheelCenterView.bounds.size.width, height) style:UITableViewStylePlain];
                tv.dataSource=self;
                tv.delegate=self;
                tv.scrollEnabled=NO;
                tv.backgroundColor=[UIColor clearColor];
                tv.separatorStyle=UITableViewCellSeparatorStyleNone;
                tv.showsVerticalScrollIndicator=NO;
                [views addObject:tv];
            }
            if (scroll==INT_MAX) {
                x+=(i==0?0:[[_scrollWidthProportion objectAtIndex:i-1]floatValue]*wheelCenterView.bounds.size.width);
            } else {
                for (int m=0; m<=i; m++) {
                    x+=(m==0?0:[[_scrollWidthProportion objectAtIndex:m-1]floatValue]*wheelCenterView.bounds.size.width);
                }
            }
            
            IDJScrollComponent *scrollComponent=[[IDJScrollComponent alloc]initWithFrame:CGRectMake(0+x+2, 0+3, [[_scrollWidthProportion objectAtIndex:i]floatValue]*wheelCenterView.bounds.size.width, height) withViews:views];
            scrollComponent.idjsDelegate=self;
            [wheelCenterView addSubview:scrollComponent];
            if (scroll==INT_MAX) {
                [_scrolls addObject:scrollComponent];
            } else {
                [_scrolls replaceObjectAtIndex:scroll withObject:scrollComponent];
            }
        }
    } else {
        CGFloat x=0.0;
        int start=0;
        int counts=_scrollWidthProportion.count;
        
        if (scroll==INT_MAX) {
            NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:_scrollWidthProportion.count];
            self._numberOfCellsInScroll=array;
        } else {
            start=scroll;
            counts=scroll+1;
        }
        for (int i=start; i<counts; i++) {
            
            int numberOfCells = 0;
            
            if (i == start) {
                numberOfCells = 12;
            }
            
            if (i-1 == start) {
                numberOfCells = 60;
            }
            
            if (scroll==INT_MAX) {
                
                [_numberOfCellsInScroll addObject:[NSString stringWithFormat:@"%d", numberOfCells]];
            } else {
                [_numberOfCellsInScroll replaceObjectAtIndex:scroll withObject:[NSString stringWithFormat:@"%d", numberOfCells]];
            }
            if (scroll==INT_MAX) {
                x+=(i==0?0:[[_scrollWidthProportion objectAtIndex:i-1]floatValue]*wheelCenterView.bounds.size.width);
            } else {
                for (int m=0; m<=i; m++) {
                    x+=(m==0?0:[[_scrollWidthProportion objectAtIndex:m-1]floatValue]*wheelCenterView.bounds.size.width);
                }
            }
            CGFloat height=wheelCenterView.frame.size.height/_cellCountInVisible*_cellCountInVisible;
            
            UITableView *tv=[[UITableView alloc]initWithFrame:CGRectMake(0+x+2, 0+3, [[_scrollWidthProportion objectAtIndex:i]floatValue]*wheelCenterView.bounds.size.width, height) style:UITableViewStylePlain];
            tv.dataSource=self;
            tv.delegate=self;
            tv.scrollEnabled=YES;
            tv.backgroundColor=[UIColor clearColor];
            tv.separatorStyle=UITableViewCellSeparatorStyleNone;
            tv.showsVerticalScrollIndicator=NO;
            tv.bounces=NO;
            tv.decelerationRate=0;
            [wheelCenterView addSubview:tv];
            if (scroll==INT_MAX) {
                [_scrolls addObject:tv];
            } else {
                [_scrolls replaceObjectAtIndex:scroll withObject:tv];
            }
        }
    }
}

//设置选中区域的图片
- (void)_setSelectionArea {
    UIImageView *selectionCenterView=[[UIImageView alloc]initWithFrame:CGRectMake(10,10,300,162)];
    [self addSubview:selectionCenterView];
}

#pragma mark -UITableView-
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight=wheelCenterView.frame.size.height/_cellCountInVisible;
    return rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (dataLoop) {
        for (int i=0; i<_scrollWidthProportion.count; i++) {
            if ([_scrolls objectAtIndex:i]==[tableView superview]) {
                return [[_numberOfCellsInScroll objectAtIndex:i]intValue];
            }
        }
    } else {
        for (int i=0; i<_scrollWidthProportion.count; i++) {
            if ([_scrolls objectAtIndex:i]==tableView) {
                
                int count=[[_numberOfCellsInScroll objectAtIndex:i]intValue]+_selectionPosition+(_cellCountInVisible-(_selectionPosition+1));
                return count;
            }
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=nil;
    if (dataLoop) {
        static NSString *CellIdentifier=@"IDJPickerCell";
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor clearColor];//kSetTimeCellBodyColor;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 54)];
            label.font = [UIFont fontWithName:@"Helvetica Light" size:30];
            label.textColor = kTextColor;
            label.tag = 1000;
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label];
        }
    } else {
        
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    if (dataLoop) {
        for (int i=0; i<_scrollWidthProportion.count; i++) {
            if ([_scrolls objectAtIndex:i]==[tableView superview]) {
                UILabel *label = (UILabel *)[cell.contentView viewWithTag:1000];
                if (i == 0) {
                    label.text = [@(indexPath.row) stringValue];
                }
                if (i == 1) {
                    label.text = [@(indexPath.row) stringValue];
                }
                break;
            }
        }
    } else {
        for (int i=0; i<_scrollWidthProportion.count; i++) {
            if (indexPath.row>=0&&indexPath.row<_selectionPosition) {
                
                if ([_scrolls objectAtIndex:i]==tableView) {
                    cell.textLabel.text=@"";
                    break;
                }
            } else if (indexPath.row>=_selectionPosition&&indexPath.row<_selectionPosition+[[_numberOfCellsInScroll objectAtIndex:i]intValue]) {
                if ([_scrolls objectAtIndex:i]==tableView) {
                    
                    if (i == 0) {
                        cell.textLabel.text = [@(indexPath.row-_selectionPosition+1) stringValue];
                    }
                    if (i == 1) {
                        cell.textLabel.text = [@(indexPath.row-_selectionPosition) stringValue];
                    }
                    
                    
                    break;
                }
            } else {
                
                if ([_scrolls objectAtIndex:i]==tableView) {
                    cell.textLabel.text=@"";
                    break;
                }
            }
        }
    }
    return cell;
}

- (void)setHour:(int)onHour  minute:(int)onMinute
{
    UIScrollView *sc=[_scrolls objectAtIndex:1];
    sc.scrollEnabled = YES;
    hour = onHour*60*60;
    minute = onMinute*60;
    [self selectCell:onHour inScroll:0];
    [self selectCell:onMinute inScroll:1];
    
    if (onHour > 11)
    {
        minute = 0;
        [self selectCell:0 inScroll:1];
        UIScrollView *sc=[_scrolls objectAtIndex:1];
        sc.scrollEnabled = NO;
    }
    else
    {
        UIScrollView *sc=[_scrolls objectAtIndex:1];
        sc.scrollEnabled = YES;
    }
}

#pragma mark -Action Handle-
- (void)selectCell:(NSUInteger)cell inScroll:(NSUInteger)scroll {
    UIScrollView *sc=[_scrolls objectAtIndex:scroll];
    CGFloat rowHeight=wheelCenterView.frame.size.height/_cellCountInVisible;
    
    if (dataLoop) {
        [sc setContentOffset:CGPointMake(sc.contentOffset.x, (cell+1-(_selectionPosition+1)+[[_numberOfCellsInScroll objectAtIndex:scroll]intValue])*rowHeight) animated:YES];
    } else {
        [sc setContentOffset:CGPointMake(sc.contentOffset.x, cell*rowHeight) animated:YES];
    }
}


- (void)stopScroll:(IDJScrollComponent *)sc{
    CGFloat rowHeight=wheelCenterView.frame.size.height/_cellCountInVisible;
    
    [sc setContentOffset:CGPointMake(sc.contentOffset.x, round(sc.contentOffset.y/rowHeight)*rowHeight) animated:YES];
    NSUInteger cellCountsOffset=round(sc.contentOffset.y/rowHeight);
    int counts=[[_numberOfCellsInScroll objectAtIndex:[_scrolls indexOfObject:sc]]intValue];
    int whichCell=(cellCountsOffset+_selectionPosition)%counts;
    
    if ([_scrolls indexOfObject:sc] == 0)
    {
        hour = (whichCell)*60*60;
        if (whichCell > 11) {
            minute = 0;
            [self selectCell:0 inScroll:1];
            UIScrollView *sc=[_scrolls objectAtIndex:1];
            sc.scrollEnabled = NO;
        }
        else
        {
            UIScrollView *sc=[_scrolls objectAtIndex:1];
            sc.scrollEnabled = YES;
        }
    }
    else if ([_scrolls indexOfObject:sc] == 1)
    {
        minute = whichCell*60;
    }
    
    self.countDownDuration = hour + minute;
}


- (void)stopScrollNoLoop:(UIScrollView *)sc{
    CGFloat rowHeight=wheelCenterView.frame.size.height/_cellCountInVisible;
    
    [sc setContentOffset:CGPointMake(sc.contentOffset.x, round(sc.contentOffset.y/rowHeight)*rowHeight) animated:YES];
    NSUInteger cellCountsOffset=round(sc.contentOffset.y/rowHeight);
    int whichCell=cellCountsOffset;
    //    [delegate didSelectCell:whichCell inScroll:[_scrolls indexOfObject:sc]];
    
    if ([_scrolls indexOfObject:sc] == 0)
    {
        hour = (whichCell)*60*60;
        if (whichCell > 11) {
            minute = 0;
            [self selectCell:0 inScroll:1];
            UIScrollView *sc=[_scrolls objectAtIndex:1];
            sc.scrollEnabled = NO;
        }
        else
        {
            UIScrollView *sc=[_scrolls objectAtIndex:1];
            sc.scrollEnabled = YES;
        }
    }
    else if ([_scrolls indexOfObject:sc] == 1)
    {
        minute = whichCell*60;
    }
    
    self.countDownDuration = hour + minute;
}


-(void)scrollViewDidEndDragging:(UIScrollView *)sc willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self stopScrollNoLoop:sc];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)sc{
    [self stopScrollNoLoop:sc];
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    [super hitTest:point withEvent:event];
    if ([self pointInside:point withEvent:event]) {
        
        CGPoint sc_point=[self convertPoint:point toView:wheelCenterView];
        int x_less=0;
        int x_greater=0;
        for (int i=0; i<_scrollWidthProportion.count; i++) {
            x_less+=(i==0?0.0:wheelCenterView.bounds.size.width*[[_scrollWidthProportion objectAtIndex:i-1]floatValue]);
            x_greater+=wheelCenterView.bounds.size.width*[[_scrollWidthProportion objectAtIndex:i]floatValue];
            if (sc_point.x>x_less&&sc_point.x<x_greater&&sc_point.y>0&&sc_point.y<wheelCenterView.bounds.size.height) {
                return [_scrolls objectAtIndex:i];
            }
        }
        return self;
    } else {
        return nil;
    }
}

- (void)reloadScroll:(NSUInteger)scroll {
    UIScrollView *sc=[_scrolls objectAtIndex:scroll];
    
    [sc removeFromSuperview];
    [self _setTableViews:scroll];
}

#pragma mark -dealloc-
- (void)dealloc{
   
}

@end
