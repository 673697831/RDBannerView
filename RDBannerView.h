//
//  RDBannerView.h
//  RiceDonate
//
//  Created by ozr on 3/31/15.
//  Copyright (c) 2015 ricedonate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

typedef NS_ENUM(NSInteger, RDBannerViewScrollDirection)
{
    // 水平滚动
    RDBannerScrollDirectionLandscape,
    // 垂直滚动
    RDBannerScrollDirectionPortait,
};

typedef NS_ENUM(NSInteger, RDBannerViewPageStyle)
{
    RDBannerPageStyleNone,
    RDBannerPageStyleLeft,
    RDBannerPageStyleRight,
    RDBannerPageStyleMiddle,
};

@class RDBannerView;

@protocol RDBannerViewDelegate <NSObject>

- (void)bannerView:(RDBannerView *)bannerView didSelectImageView:(NSInteger)index withData:(NSDictionary *)bannerData;

@end

@interface RDBannerView : UIView

@property (nonatomic, weak)   UIPageControl* pageControl;
@property (nonatomic, weak)   id<RDBannerViewDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval rollingDelayTime;
@property (nonatomic, assign) RDBannerViewPageStyle pageStyle;
@property (nonatomic, assign) NSInteger square;

- (instancetype)initWithFrame:(CGRect)frame
              scrollDirection:(RDBannerViewScrollDirection)direction;

- (void)reloadBannerWithData:(NSArray *)images;

- (void)startRolling;

@end
