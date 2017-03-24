#import "MessageHUD.h"
#import "pop.h"

#import "MBProgressHUD.h"

@interface MessageHUD ()

@end

@implementation MessageHUD

#define IOS_VERSION_8_BELOW (([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)? (YES):(NO))

+ (void)showMessage:(NSString *)text {
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
    
    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    //    UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //    hud.customView = [[UIImageView alloc] initWithImage:image];
    // Looks a bit nicer if we make it square.
    hud.square = YES;
    // Optional label text.
    hud.label.text = text;
    
    [hud hideAnimated:YES afterDelay:.5f];
}

+(instancetype)shareHUD{
    static MessageHUD *_shareHUD;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == _shareHUD) {
            _shareHUD = [[MessageHUD alloc] init];
        }
    });
    
    return _shareHUD;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    }
    return self;
}

/**
 *  显示提示信息, 使用默认显示时常1.5秒
 *
 *  @param text      要显示的文字
 */
+(void)showText:(NSString *)text{
    [MessageHUD showText:text withTimeInterval:1.5];
}

/**
 *  显示提示信息
 *
 *  @param text      要显示的文字
 *  @param iinterval 显示的时间
 */
+(void)showText:(NSString *)text withTimeInterval:(CGFloat)interval{
    if(![text isKindOfClass:[NSString class]] || !text.length){
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MessageHUD *hud  = [MessageHUD shareHUD];
        [hud prepareToShow];
        
        if(IOS_VERSION_8_BELOW) {
            hud.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.numberOfLines = 0;
        textLabel.font = [UIFont systemFontOfSize:18.0];
        textLabel.text = text;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor whiteColor];
        CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width - 10.0;
        CGSize labelSize = [textLabel sizeThatFits:CGSizeMake(labelWidth/2, MAXFLOAT)];
        
        hud.bounds = CGRectMake(0.0, 0.0, labelSize.width + 60.0, labelSize.height + 60.0);
        hud.center = [UIApplication sharedApplication].keyWindow.center;
        
        CGFloat textLabelW = labelSize.width;
        CGFloat textLabelH = labelSize.height;
        CGFloat textLabelX = (CGRectGetWidth(hud.bounds) - textLabelW)/2;
        CGFloat textLabelY = (CGRectGetHeight(hud.bounds) - textLabelH)/2;
        textLabel.frame = CGRectMake(textLabelX, textLabelY, textLabelW, textLabelH);
        [hud addSubview:textLabel];
        [[UIApplication sharedApplication].keyWindow addSubview:hud];
        
        [hud performSelector:@selector(hiddenHUD) withObject:nil afterDelay:interval];
        
        [hud appearAnimation];
    });
}

/**
 *  显示服务器返回的错误提示
 *
 *  @param errorDict 服务器返回的错误信息
 *  @param interval 显示的时间
 */
+(void)showErrorWithData:(NSDictionary *)errorDict withTimeInterval:(CGFloat)interval;
{
    if ([errorDict isKindOfClass:[NSDictionary class]]) {
        id errorInfo = [errorDict valueForKey:@"error"];
        if ([errorInfo isKindOfClass:[NSString class]]) {
            [MessageHUD showText:errorInfo withTimeInterval:interval];
        }
        
        if ([errorInfo isKindOfClass:[NSDictionary class]]) {
            NSArray *values = [errorInfo allValues];
            id firstObj = [values firstObject];
            if ([firstObj isKindOfClass:[NSArray class]]) {
                NSString *errorString = [NSString stringWithFormat:@"%@", [firstObj firstObject]];
                [MessageHUD showText:errorString withTimeInterval:interval];
            }
        }
    }
}

-(void)prepareToShow{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenHUD) object:nil];
    
    MessageHUD *hud  = [MessageHUD shareHUD];
    for (UIView *subView in hud.subviews) {
        [subView removeFromSuperview];
    }
}

-(void)appearAnimation{
    MessageHUD *hud  = [MessageHUD shareHUD];
    
    //缩小动画
    POPSpringAnimation *scale =
    [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scale.toValue = [NSValue valueWithCGPoint:CGPointMake(0.8, 0.8)];
    scale.springBounciness = 5.0;
    scale.springSpeed = 15.0f;
    [hud pop_addAnimation:scale forKey:@"scale"];
}

-(void)hiddenHUD{
    MessageHUD *hud  = [MessageHUD shareHUD];
    for (UIView *subView in hud.subviews) {
        [subView removeFromSuperview];
    }
    hud.transform = CGAffineTransformIdentity;
    [hud removeFromSuperview];
}

@end
