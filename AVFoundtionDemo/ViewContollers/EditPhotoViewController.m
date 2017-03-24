//
//  EditPhotoViewController.m
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/24.
//  Copyright © 2017年 David. All rights reserved.
//

#import "EditPhotoViewController.h"
#import "Masonry.h"
#import "FilterCellView.h"
#import "UIView+frameAdjust.h"

#define ScreenBounds [UIScreen mainScreen].bounds
#define ScreenHeight ScreenBounds.size.height
#define ScreenWidth ScreenBounds.size.width
#define FourThreeFrame (CGRect){0, 0, ScreenWidth, ScreenWidth * (4 / 3.0)}

#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6P (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

#define UIColorFromRGBWithAlpha(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]


#define kThemeCellIdentifier @"kThemeCellIdentifier"

static inline CGFloat filterCellWidth () {
    if (IS_IPHONE_6P) {
        return 76.0;
    } else {
        return 64.0;
    }
}

@interface EditPhotoViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UICollectionView *filterCollectionView;
@property (nonatomic, strong) CALayer *overlayLayer;

@end

@implementation EditPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.title = @"Edit Photo";
    
    [self setupSubViews];
}

- (void)setupSubViews {
    self.imageView = [[UIImageView alloc] initWithImage:self.takedImage];
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    
    [self.view.layer insertSublayer:self.overlayLayer atIndex:0];
    [self.view addSubview:self.filterCollectionView];
    
}


#pragma mark - Delegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCellView * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kThemeCellIdentifier forIndexPath:indexPath];
    [cell configWithFilter:self.filters[indexPath.item]];
    
    if (cell.selected) {
        cell.overlayLayer.hidden = NO;
    } else {
        cell.overlayLayer.hidden = YES;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(filterCellWidth(), filterCellWidth());
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCellView *cell = (FilterCellView *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.overlayLayer.hidden = NO;
    
//    if (_delegate && [_delegate respondsToSelector:@selector(filterViewDone:cellFrame:)]) {
//        CGRect visibleRect = [_delegate filterViewDone:indexPath.item cellFrame:cell.frame];
//        [collectionView scrollRectToVisible:visibleRect animated:YES];
//    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCellView *cell = (FilterCellView *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.overlayLayer.hidden = YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark - protect mothods

- (void)setTakedImage:(UIImage *)takedImage {
    _takedImage = takedImage;
}

- (UICollectionView *)filterCollectionView {
    if (!_filterCollectionView) {
        CGFloat newY = CGRectGetMaxY(FourThreeFrame);
        CGFloat height = ScreenWidth * (1 / 3.0);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        _filterCollectionView = [[UICollectionView alloc] initWithFrame:(CGRect){0, newY - height, ScreenWidth, filterCellWidth()} collectionViewLayout:layout];
        _filterCollectionView.delegate = self;
        _filterCollectionView.dataSource = self;
        _filterCollectionView.alwaysBounceHorizontal = YES;
        _filterCollectionView.backgroundColor = [UIColor clearColor];
        _filterCollectionView.showsHorizontalScrollIndicator = NO;
        [_filterCollectionView registerClass:[FilterCellView class] forCellWithReuseIdentifier:kThemeCellIdentifier];
        UIEdgeInsets inset = _filterCollectionView.contentInset;
        inset.left = 8;
        _filterCollectionView.contentInset = inset;
        _filterCollectionView.hidden = YES;
        _filterCollectionView.alpha = 0;
        _filterCollectionView.centerY = _overlayLayer.position.y;
    }
    return _filterCollectionView;
}

- (CALayer *)overlayLayer {
    if (!_overlayLayer) {
        CGFloat newY = CGRectGetMaxY(FourThreeFrame);
        CGFloat height = ScreenWidth * (1 / 3.0);
        _overlayLayer = [[CALayer alloc] init];
        _overlayLayer.frame = (CGRect){ 0, newY - height, ScreenWidth, height };
        _overlayLayer.hidden = YES;
        _overlayLayer.backgroundColor = UIColorFromRGBWithAlpha(0x000000, 0.85).CGColor;
    }
    return _overlayLayer;
}

@end
