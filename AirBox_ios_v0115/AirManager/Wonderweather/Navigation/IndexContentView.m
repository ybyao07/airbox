//
//  IndexContentView.m
//  wonderweather
//
//  Created by 先丰 刘 on 14-6-12.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "IndexContentView.h"
#import "ImageString.h"
#import  "AppDelegate.h"
@implementation IndexContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:0.2f] ;
        self.tag = 1;
        [self createContentView];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(press:)];
//        tap.numberOfTapsRequired = 1;
//        [self addGestureRecognizer:tap];
//        
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
//        [self addGestureRecognizer:pan];
        
        
    }
    return self;
}
- (void)move:(id)sender
{
    
}

- (void)closeView:(id)sender
{
        self.hidden = YES;
}

- (void)createContentView
{
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(37, 109, 245, 278)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.tag = 2;
    [self addSubview:contentView];
    
    
    NSInteger spaceYStart = 0;
    spaceYStart += 37;
    
    
    UIButton *closeButton = [[UIButton  alloc]init];
    [closeButton setFrame:CGRectMake(204, 0, 44, 44)];
    [closeButton setImage:[UIImage imageNamed:@"CloseButton.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:closeButton];
    
    _indexImageView = [[UIImageView alloc] initWithFrame:CGRectMake(80, spaceYStart, 86,86)];
    _indexImageView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:_indexImageView];
    
    spaceYStart += _indexImageView.frame.size.height;
    spaceYStart += 27;
    
    UILabel *splitLine = [[UILabel alloc] initWithFrame:CGRectMake(20, spaceYStart, 205,kLineHeight1px)];
    [splitLine setBackgroundColor:[UIColor colorWithHex:0x000000 alpha:0.2f]];
    [contentView addSubview:splitLine];
    
    spaceYStart += 29;
    
    _indexTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, spaceYStart ,150, 30)];
    _indexTitleLabel.text = NSLocalizedString(@"洗车指数",@"IndexContentView.m");//ybyao
    _indexTitleLabel.textColor = [UIColor colorWithHex:0x353535 alpha:1.0f];
    _indexTitleLabel.font = [UIFont systemFontOfSize:15.f];
    CGSize mySize = [_indexTitleLabel.text sizeWithFont:_indexTitleLabel.font];
    [_indexTitleLabel setFrame:CGRectMake(21, spaceYStart, mySize.width, mySize.height)];
    _indexTitleLabel.backgroundColor = [UIColor clearColor];
    [contentView addSubview:_indexTitleLabel];
    
    _indexContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(34 +mySize.width, spaceYStart  - 8, 450-34-mySize.width, 24)];
    _indexContentLabel.text = NSLocalizedString(@"适宜",@"IndexContentView.m");//ybyao
    _indexContentLabel.textColor = [UIColor colorWithHex:0x1786ee alpha:1];
    _indexContentLabel.backgroundColor = [UIColor clearColor];
    if ([MainDelegate isLanguageEnglish]) {
        _indexContentLabel.font = [UIFont systemFontOfSize:14.f];

    }else{
    _indexContentLabel.font = [UIFont systemFontOfSize:28.f];
    }
    [contentView addSubview:_indexContentLabel];
    
    _indexDecripeLabel = [[UILabel alloc] init];
    _indexDecripeLabel.numberOfLines = 0;
    _indexDecripeLabel.textColor = [UIColor colorWithHex:0x353535 alpha:1.0f];
    if ([MainDelegate isLanguageEnglish]) {
        _indexDecripeLabel.font = [UIFont systemFontOfSize:9.f];
    }else{
    _indexDecripeLabel.font = [UIFont systemFontOfSize:11.f];
    }
    _indexDecripeLabel.backgroundColor = [UIColor clearColor];
    [contentView addSubview:_indexDecripeLabel];
    
}

- (void)updateContentView:(IndexData *)indexData
{
    NSInteger spaceYStart = 177;
    _indexImageView.image = [UIImage imageNamed:[ImageString getIndexHeadImageStr:indexData.name]];
    _indexTitleLabel.text = NSLocalizedString(indexData.name,@"IndexContentView.m");//ybyao
    _indexContentLabel.text =NSLocalizedString( indexData.level,@"IndexContentView.m");//ybyao

    CGSize mySize = [_indexTitleLabel.text sizeWithFont:_indexTitleLabel.font];
    CGSize mySizeContent=[_indexContentLabel.text sizeWithFont:_indexContentLabel.font];
    
    if (mySize.width>120&&[MainDelegate isLanguageEnglish]) {
        mySize.width=120;
        [_indexTitleLabel setFrame:CGRectMake(21, spaceYStart, mySize.width, mySize.height)];
        [_indexTitleLabel setAdjustsFontSizeToFitWidth:YES];
        }else {
    [_indexTitleLabel setFrame:CGRectMake(21, spaceYStart, mySize.width, mySize.height)];
        }
    if ([MainDelegate isLanguageEnglish]) {
    
        if ((245-30-mySize.width - 21-mySizeContent.width)<0) {
            mySizeContent.width=245-30-mySize.width - 21;
        }
        [_indexContentLabel setFrame:CGRectMake(30 +mySize.width, spaceYStart -3 ,mySizeContent.width, 24)];
        [_indexContentLabel setAdjustsFontSizeToFitWidth:YES];
        
    }else{
    [_indexContentLabel setFrame:CGRectMake(34 +mySize.width, spaceYStart  - 8 ,245-34-mySize.width - 21, 24)];
    }
    [_indexContentLabel setAdjustsFontSizeToFitWidth:YES];
    
     _indexDecripeLabel.text = NSLocalizedString(indexData.content,@"IndexContentView.m"); //指数描述内容 ybyao
    CGSize size = [indexData.content sizeWithFont:_indexDecripeLabel.font constrainedToSize:CGSizeMake(209, 1000) lineBreakMode:NSLineBreakByCharWrapping];
    _indexDecripeLabel.frame = CGRectMake(21, 213, size.width, size.height);

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
