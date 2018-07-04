//
//  LDCycleScrollView.m
//  QTTableKit
//
//  Created by cxs on 2018/4/19.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "LDCycleScrollView.h"
#import "LDCycleCollectionViewCell.h"

NSString * const ID = @"LDCycleCollectionViewCell";

@implementation LDCycleItem
@end


@interface LDCycleScrollView () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_flowLayout;
    NSTimer *_rotateTimer;
}
@property (nonatomic, strong) NSArray<LDCycleItem *>*cycleItems;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) LDCycleScrollViewDirection direction;
@end

@implementation LDCycleScrollView
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame items:(NSArray<LDCycleItem *> *)itemsArray direction:(LDCycleScrollViewDirection)direction {
    LDCycleScrollView *scrollView = [[LDCycleScrollView alloc] initWithFrame:frame];
    NSMutableArray *arr = [NSMutableArray arrayWithObject:[itemsArray lastObject]];
    [arr addObjectsFromArray:itemsArray];
    [arr addObject:[itemsArray lastObject]];
    scrollView.cycleItems = [NSArray arrayWithArray:arr];
    scrollView.direction = direction;
    scrollView -> _flowLayout.scrollDirection  = (UICollectionViewScrollDirection)direction;
    return scrollView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupCollectionView];
    }
    return self;
}

// 设置显示图片的collectionView
- (void)setupCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.itemSize = self.bounds.size;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _flowLayout = flowLayout;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"LDCycleCollectionViewCell" bundle:[NSBundle bundleForClass:[LDCycleScrollView class]]] forCellWithReuseIdentifier:ID];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.scrollsToTop = NO;
    [self addSubview:collectionView];
    _collectionView = collectionView;
    [self addTimer];
}

#pragma mark -- UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cycleItems.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(LDCycleCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell.imageView setImage:self.cycleItems[indexPath.row].image];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LDCycleItem *cycleItem = self.cycleItems[indexPath.row];
    if (cycleItem.didSelectedBlock) {
        cycleItem.didSelectedBlock();
    }
}

#pragma mark -- <UIScrollViewDelegate>
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self addTimer];
}

- (NSInteger)currentIndex {
    switch (self.direction) {
        case LDCycleScrollViewDirectionHorizontal:
            return _collectionView.contentOffset.x / _collectionView.bounds.size.width;
        case LDCycleScrollViewDirectionVertical:
            return _collectionView.contentOffset.y / _collectionView.bounds.size.height;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self addTimer];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self addTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    switch (self.direction) {
        case LDCycleScrollViewDirectionHorizontal:
            if (scrollView.bounds.size.width / 2.f > scrollView.contentOffset.x) {
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x + scrollView.bounds.size.width * (self.cycleItems.count - 2), 0);
            } else if (scrollView.contentOffset.x >= scrollView.bounds.size.width * ([self.cycleItems count] - 1.5)) {
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x - scrollView.bounds.size.width * (self.cycleItems.count - 2), 0);
            }
            break;
        case LDCycleScrollViewDirectionVertical:
            if (scrollView.bounds.size.height / 2.f > scrollView.contentOffset.y) {
                scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y + scrollView.bounds.size.height * (self.cycleItems.count - 2));
            } else if (scrollView.contentOffset.y >= scrollView.bounds.size.height * ([self.cycleItems count] - 1.5)) {
                scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y - scrollView.bounds.size.height * (self.cycleItems.count - 2));
            }
        break;
    }
}

#pragma mark -- <timer>
- (void)removeTimer {
    if (_rotateTimer) {
        [_rotateTimer invalidate];
        _rotateTimer = nil;
    }
}

- (void)addTimer {
    [self removeTimer];
    _rotateTimer = [NSTimer timerWithTimeInterval:self.autoScrollTimeInterval > 0?:2.0 target:self selector:@selector(rollingBanner:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_rotateTimer forMode:NSRunLoopCommonModes];
}

- (void)rollingBanner:(NSTimer *)timer {
    [self removeTimer];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(self.currentIndex + 1) % [self.cycleItems count] inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
}

@end
