//
//  MJRefreshBaseView.m
//  MJRefresh
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJRefreshBaseView.h"
#import "MJRefreshConst.h"

@interface  MJRefreshBaseView()
{
    BOOL _hasInitInset;
    CGAffineTransform _transfom;
    CGAffineTransform _tmpTransfom;
    BOOL _beginbool;
    NSTimer *_timer;
}
/**
 交给子类去实现
 */
// 合理的Y值
- (CGFloat)validY;
// view的类型
- (MJRefreshViewType)viewType;
@end

@implementation MJRefreshBaseView

#pragma mark 创建一个UILabel
- (UILabel *)labelWithFontSize:(CGFloat)size
{
    UILabel *label = [[UILabel alloc] init];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont boldSystemFontOfSize:size];
    label.textColor = MJRefreshLabelTextColor;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

#pragma mark - 初始化方法
- (void)dealloc
{
    if([_timer isValid])
    {
        [_timer invalidate];
    }
    
    _timer = nil;
    DDLogFunction();
    
}
- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    if (self = [super init]) {
        self.scrollView = scrollView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!_hasInitInset) {
        _scrollViewInitInset = _scrollView.contentInset;
    
        [self observeValueForKeyPath:MJRefreshContentSize ofObject:nil change:nil context:nil];
        
        _hasInitInset = YES;
        
        if (_state == MJRefreshStateWillRefreshing) {
            [self setState:MJRefreshStateRefreshing];
        }
    }
}

#pragma mark 构造方法
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 1.自己的属性
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor blackColor];
        
        // 2.时间标签
        [self addSubview:_lastUpdateTimeLabel = [self labelWithFontSize:12]];
        
        // 3.状态标签
        [self addSubview:_statusLabel = [self labelWithFontSize:13]];
        
        // 4.箭头图片
        UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kSrcName(@"arrow.png")]];
        arrowImage.hidden = YES;
        arrowImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_arrowImage = arrowImage];
        
        // 5.指示器
//        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        activityView.bounds = arrowImage.bounds;
//        activityView.autoresizingMask = arrowImage.autoresizingMask;
//        [self addSubview:_activityView = activityView];
        UIImageView *ImageViewOut = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingImageOut.png"]];
        ImageViewOut.bounds = CGRectMake(0, 0, 40, 40);
        ImageViewOut.autoresizingMask = arrowImage.autoresizingMask;
        [self addSubview:_ImageView = ImageViewOut];

        UIImageView *ImageViewIn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingImageIn.png"]];
        ImageViewIn.frame = CGRectMake(7, 7, 25, 25);
        ImageViewIn.autoresizingMask = arrowImage.autoresizingMask;
        _transfom = ImageViewIn.transform;
        [ImageViewOut addSubview:_rotationView = ImageViewIn];
        _ImageView.hidden = YES;
        _beginbool = NO;
        
        // 6.设置默认状态
        [self setState:MJRefreshStateNormal];
    }
    return self;
}

#pragma mark 设置frame
- (void)setFrame:(CGRect)frame
{
    frame.size.height = 600;
    [super setFrame:frame];
    
    CGFloat w = frame.size.width;
    CGFloat h = 600;
    if (w == 0 || _arrowImage.center.y == h * 0.5) return;
    
    CGFloat statusX = 0;
    CGFloat statusY = 545;
    CGFloat statusHeight = 20;
    CGFloat statusWidth = w;
    // 1.状态标签
    _statusLabel.frame = CGRectMake(statusX, statusY + 20, statusWidth, statusHeight);

    // 2.时间标签
    //CGFloat lastUpdateY = statusY + statusHeight + 5;
    //_lastUpdateTimeLabel.frame = CGRectMake(statusX, lastUpdateY, statusWidth, statusHeight);
    
    // 3.箭头
    CGFloat arrowX = w * 0.5;
    _arrowImage.center = CGPointMake(arrowX, h * 0.5 + 240);
    
    // 4.指示器
    //_activityView.center = _arrowImage.center;
    _ImageView.center = _arrowImage.center;
}

- (void)setBounds:(CGRect)bounds
{
    bounds.size.height = MJRefreshViewHeight;
    [super setBounds:bounds];
}

#pragma mark - UIScrollView相关
#pragma mark 设置UIScrollView
- (void)setScrollView:(UIScrollView *)scrollView
{
    // 移除之前的监听器
    [_scrollView removeObserver:self forKeyPath:MJRefreshContentOffset context:nil];
    // 监听contentOffset
    [scrollView addObserver:self forKeyPath:MJRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
    
    // 设置scrollView
    _scrollView = scrollView;
    [_scrollView addSubview:self];
}

#pragma mark 监听UIScrollView的contentOffset属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![MJRefreshContentOffset isEqualToString:keyPath]) return;
    
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden
        || _state == MJRefreshStateRefreshing) return;
   
    _arrowImage.hidden = YES;
    _ImageView.hidden = NO;
    
    // scrollView所滚动的Y值 * 控件的类型（头部控件是-1，尾部控件是1）
    CGFloat offsetY = _scrollView.contentOffset.y * self.viewType;
    CGFloat rotation = (offsetY - 50) / 15;
    CGFloat validY = self.validY;
    if (offsetY <= validY) return;    
    
    if (_scrollView.isDragging) {
        
        if (_beginbool == NO) {
            [_timer invalidate];
            _timer = nil;
            [_rotationView.layer removeAllAnimations];
            _rotationView.transform = CGAffineTransformRotate(_transfom,rotation);
            _tmpTransfom = _rotationView.transform;
        }

        CGFloat validOffsetY = validY + MJRefreshViewHeight;
        if (_state == MJRefreshStatePulling && offsetY <= validOffsetY) {
            // 转为普通状态
            [self setState:MJRefreshStateNormal];
            // 通知代理
            if ([_delegate respondsToSelector:@selector(refreshView:stateChange:)]) {
                [_delegate refreshView:self stateChange:MJRefreshStateNormal];
            }
            
            // 回调
            if (_refreshStateChangeBlock) {
                _refreshStateChangeBlock(self, MJRefreshStateNormal);
            }
        } else if (_state == MJRefreshStateNormal && offsetY > validOffsetY) {
            // 转为即将刷新状态
            [self setState:MJRefreshStatePulling];
            // 通知代理
            if ([_delegate respondsToSelector:@selector(refreshView:stateChange:)]) {
                [_delegate refreshView:self stateChange:MJRefreshStatePulling];
            }
            
            // 回调
            if (_refreshStateChangeBlock) {
                _refreshStateChangeBlock(self, MJRefreshStatePulling);
            }
        }
    } else { // 即将刷新 && 手松开
        _rotationView.transform = _transfom;
        if (_state == MJRefreshStatePulling) {
            // 开始刷新
            [self setState:MJRefreshStateRefreshing];
            // 通知代理
            if ([_delegate respondsToSelector:@selector(refreshView:stateChange:)]) {
                [_delegate refreshView:self stateChange:MJRefreshStateRefreshing];
            }
            
            // 回调
            if (_refreshStateChangeBlock) {
                _refreshStateChangeBlock(self, MJRefreshStateRefreshing);
            }
        }
    }
}

#pragma mark 设置状态
- (void)setState:(MJRefreshState)state
{
    if (_state != MJRefreshStateRefreshing) {
        // 存储当前的contentInset
        _scrollViewInitInset = _scrollView.contentInset;
        _hasInitInset = YES;
//        DDLogCVerbose(@"最终位置...");
    }
    
    // 1.一样的就直接返回
    if (_state == state) return;
    
    // 2.根据状态执行不同的操作
    switch (state) {
		case MJRefreshStateNormal: // 普通状态
            // 显示箭头
            _arrowImage.hidden = YES;
            // 停止转圈圈
            
			//[_activityView stopAnimating];
            [_ImageView setHidden:NO];
            [_timer invalidate];
            _timer = nil;
            // 说明是刚刷新完毕 回到 普通状态的
            if (MJRefreshStateRefreshing == _state) {
                // 通知代理
                _beginbool = NO;

                if ([_delegate respondsToSelector:@selector(refreshViewEndRefreshing:)]) {
                    [_delegate refreshViewEndRefreshing:self];
                }
                
                // 回调
                if (_endStateChangeBlock) {
                    _endStateChangeBlock(self);
                    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }
            }
            
			break;
            
        case MJRefreshStatePulling:
            break;
            
		case MJRefreshStateRefreshing:
            // 开始转圈圈
			//[_activityView startAnimating];
            _ImageView.hidden = NO;
            _beginbool = YES;
            _rotationView.transform = _transfom;
            _timer = [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(rotationView) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
            [_timer fire];
            // 隐藏箭头
			_arrowImage.hidden = YES;
            _arrowImage.transform = CGAffineTransformIdentity;
            
            // 通知代理
            if ([_delegate respondsToSelector:@selector(refreshViewBeginRefreshing:)]) {
                [_delegate refreshViewBeginRefreshing:self];
            }
            
            // 回调
            if (_beginRefreshingBlock) {
                _beginRefreshingBlock(self);
            }
			break;
        default:
            break;
	}
    
    // 3.存储状态
    _state = state;
    
   
}

- (void)rotationView
{
    int direction = 1;  //-1为逆时针
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:(M_PI * 2)  * direction];
    rotationAnimation.duration = 2.0f;
//    rotationAnimation.repeatCount = 1;
    //    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_rotationView.layer addAnimation:rotationAnimation forKey:@"rotateAnimation"];

}

#pragma mark - 状态相关
#pragma mark 是否正在刷新
- (BOOL)isRefreshing
{
    return MJRefreshStateRefreshing == _state;
}
#pragma mark 开始刷新
- (void)beginRefreshing
{
    //if (self.window) {
        [self setState:MJRefreshStateRefreshing];
//    } else {
//        _state = MJRefreshStateWillRefreshing;
//    }
}
#pragma mark 结束刷新
- (void)endRefreshing
{
    double delayInSeconds = self.viewType == MJRefreshViewTypeFooter ? 0.3 : 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self setState:MJRefreshStateNormal];
    });
}

#pragma mark - 随便实现
- (CGFloat)validY { return 0;}
- (MJRefreshViewType)viewType {return MJRefreshViewTypeHeader;}
- (void)free
{
    [_scrollView removeObserver:self forKeyPath:MJRefreshContentOffset];
}
- (void)removeFromSuperview
{
    [self free];
    _scrollView = nil;
    [super removeFromSuperview];
}
- (void)endRefreshingWithoutIdle
{
    [self endRefreshing];
}
@end