//
//  RDBannerView.m
//  RiceDonate
//
//  Created by ozr on 3/31/15.
//  Copyright (c) 2015 ricedonate. All rights reserved.
//

#import "RDBannerView.h"

#define BannerStartTag     1000

@interface RDBannerView()<UIScrollViewDelegate>

@property (nonatomic, weak)   UIScrollView*               scrollView;


@property (nonatomic, strong) NSArray*                    imagesArray;
@property (nonatomic, assign) BOOL                        enableRolling;
@property (nonatomic, assign) RDBannerViewScrollDirection scrollDirection;
@property (nonatomic, assign) NSInteger                   curPage;
@property (nonatomic, assign) NSInteger                   totalCount;
@property (nonatomic, assign) NSInteger                   totalPage;

@end

@implementation RDBannerView

- (instancetype)initWithFrame:(CGRect)frame scrollDirection:(RDBannerViewScrollDirection)direction
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollDirection = direction;
        self.curPage = 1;
        
        self.imagesArray = @[];
        self.totalPage = self.imagesArray.count;
        self.totalCount = self.totalPage;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        
        // 在水平方向滚动
        if(direction == RDBannerScrollDirectionLandscape)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3,
                                                scrollView.frame.size.height);
        }
        // 在垂直方向滚动
        else if(direction == RDBannerScrollDirectionPortait)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,
                                                scrollView.frame.size.height * 3);
        }

        for (NSInteger i = 0; i < 3; i++)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.userInteractionEnabled = YES;
            imageView.tag = BannerStartTag + i;
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [imageView addGestureRecognizer:singleTap];
            
            // 水平滚动
            if(self.scrollDirection == RDBannerScrollDirectionLandscape)
            {
                imageView.frame = CGRectOffset(imageView.frame, scrollView.frame.size.width * i, 0);
            }
            // 垂直滚动
            else if(self.scrollDirection == RDBannerScrollDirectionPortait)
            {
                imageView.frame = CGRectOffset(imageView.frame, 0, scrollView.frame.size.height * i);
            }
            
            [scrollView addSubview:imageView];
        }
        
        UIPageControl* pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(5, frame.size.height-15, 60, 15)];
        [self addSubview:pageControl];
        self.pageControl = pageControl;
        self.pageControl.numberOfPages = self.imagesArray.count;
        self.pageControl.currentPage = 0;

    }
    return self;
}

- (void)setPageStyle:(RDBannerViewPageStyle)pageStyle
{
    if (pageStyle == RDBannerPageStyleLeft)
    {
        [self.pageControl setFrame:CGRectMake(5, self.bounds.size.height-15, 60, 15)];
    }
    else if (pageStyle == RDBannerPageStyleRight)
    {
        [self.pageControl setFrame:CGRectMake(self.bounds.size.width-5-60, self.bounds.size.height-15, 60, 15)];
    }
    else if (pageStyle == RDBannerPageStyleMiddle)
    {
        [self.pageControl setFrame:CGRectMake((self.bounds.size.width-60)/2, self.bounds.size.height-15, 60, 15)];
    }
    else if (pageStyle == RDBannerPageStyleNone)
    {
        [self.pageControl setHidden:YES];
    }
}

- (void)setSquare:(NSInteger)square
{
    if (self.scrollView)
    {
        self.scrollView.layer.cornerRadius = square;
        if (square == 0)
        {
            self.scrollView.layer.masksToBounds = NO;
        }
        else
        {
            self.scrollView.layer.masksToBounds = YES;
        }
    }
}

- (void)reloadBannerWithData:(NSArray *)images
{
    if (self.enableRolling)
    {
        [self stopRolling];
    }
    
    self.imagesArray = [[NSArray alloc] initWithArray:images];
    
    self.totalPage = self.imagesArray.count;
    self.totalCount = self.totalPage;
    self.curPage = 1;
    self.pageControl.numberOfPages = self.totalPage;
    self.pageControl.currentPage = 0;
    [self refreshScrollView];
}

#pragma mark - Custom Method

- (void)refreshScrollView
{
    NSArray *curimageUrls = [self getDisplayImagesWithPageIndex:self.curPage];
    
    for (NSInteger i = 0; i < 3; i++)
    {
        UIImageView *imageView = (UIImageView *)[self.scrollView viewWithTag:BannerStartTag+i];
        NSDictionary *dic = [curimageUrls objectAtIndex:i];
        NSString *url = [dic objectForKey:@"img_url"];
        //        if (imageView && [imageView isKindOfClass:[UIImageView class]] && [url isNotEmpty])
        //        {
        [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
        //        }
    }
    
    // 水平滚动
    if (self.scrollDirection == RDBannerScrollDirectionLandscape)
    {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    }
    // 垂直滚动
    else if (self.scrollDirection == RDBannerScrollDirectionPortait)
    {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.size.height);
    }
    
    self.pageControl.currentPage = self.curPage - 1;
}

- (NSArray *)getDisplayImagesWithPageIndex:(NSInteger)page
{
    NSInteger pre = [self getPageIndex:self.curPage-1];
    NSInteger last = [self getPageIndex:self.curPage+1];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:0];
    
    [images addObject:[self.imagesArray objectAtIndex:pre-1]];
    [images addObject:[self.imagesArray objectAtIndex:self.curPage-1]];
    [images addObject:[self.imagesArray objectAtIndex:last-1]];
    
    return images;
}

- (NSInteger)getPageIndex:(NSInteger)index
{
    // value＝1为第一张，value = 0为前面一张
    if (index == 0)
    {
        index = self.totalPage;
    }
    
    if (index == self.totalPage + 1)
    {
        index = 1;
    }
    
    return index;
}

#pragma mark Rolling

- (void)startRolling
{
    //    if (![self.imagesArray isNotEmpty] || self.imagesArray.count == 1)
    //    {
    //        return;
    //    }
    
    [self stopRolling];
    
    self.enableRolling = YES;
    [self performSelector:@selector(rollingScrollAction) withObject:nil afterDelay:self.rollingDelayTime];
}

- (void)stopRolling
{
    self.enableRolling = NO;
    //取消已加入的延迟线程
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rollingScrollAction) object:nil];
}

- (void)rollingScrollAction
{
    //NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
    
    [UIView animateWithDuration:0.25 animations:^{
        // 水平滚动
        if(self.scrollDirection == RDBannerScrollDirectionLandscape)
        {
            self.scrollView.contentOffset = CGPointMake(1.99*self.scrollView.frame.size.width, 0);
        }
        // 垂直滚动
        else if(self.scrollDirection == RDBannerScrollDirectionPortait)
        {
            self.scrollView.contentOffset = CGPointMake(0, 1.99*self.scrollView.frame.size.height);
        }
        //NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
    } completion:^(BOOL finished) {
        self.curPage = [self getPageIndex:self.curPage+1];
        [self refreshScrollView];
        
        if (self.enableRolling)
        {
            [self performSelector:@selector(rollingScrollAction) withObject:nil afterDelay:self.rollingDelayTime];
        }
    }];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    NSInteger x = aScrollView.contentOffset.x;
    NSInteger y = aScrollView.contentOffset.y;
    //NSLog(@"did  x=%d  y=%d", x, y);
    
    //取消已加入的延迟线程
    if (self.enableRolling)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rollingScrollAction) object:nil];
    }
    
    // 水平滚动
    if(self.scrollDirection == RDBannerScrollDirectionLandscape)
    {
        // 往下翻一张
        if (x >= 2 * self.scrollView.frame.size.width)
        {
            self.curPage = [self getPageIndex:self.curPage+1];
            [self refreshScrollView];
        }
        
        if (x <= 0)
        {
            self.curPage = [self getPageIndex:self.curPage-1];
            [self refreshScrollView];
        }
    }
    // 垂直滚动
    else if(self.scrollDirection == RDBannerScrollDirectionPortait)
    {
        // 往下翻一张
        if (y >= 2 * self.scrollView.frame.size.height)
        {
            self.curPage = [self getPageIndex:self.curPage+1];
            [self refreshScrollView];
        }
        
        if (y <= 0)
        {
            self.curPage = [self getPageIndex:self.curPage-1];
            [self refreshScrollView];
        }
    }
    
    //    if ([delegate respondsToSelector:@selector(DJCycleScrollView:didScrollImageView:)])
    //    {
    //        [delegate DJCycleScrollView:self didScrollImageView:curPage];
    //    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    //NSInteger x = aScrollView.contentOffset.x;
    //NSInteger y = aScrollView.contentOffset.y;
    
    //NSLog(@"--end  x=%d  y=%d", x, y);
    
    // 水平滚动
    if (self.scrollDirection == RDBannerScrollDirectionLandscape)
    {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    }
    // 垂直滚动
    else if (self.scrollDirection == RDBannerScrollDirectionPortait)
    {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.size.height);
    }
    
    if (self.enableRolling)
    {
        [self performSelector:@selector(rollingScrollAction) withObject:nil afterDelay:self.rollingDelayTime];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if (self.imagesArray.count < self.curPage) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerView:didSelectImageView:withData:)])
    {
        [self.delegate bannerView:self didSelectImageView:self.curPage-1 withData:[self.imagesArray objectAtIndex:self.curPage-1]];
    }
}


@end
