
#import <UIKit/UIKit.h>
/**
 *  提示信息类
 */
@interface MessageHUD : UIView

/**
 *  MBProgressHUD 样式
 */
+ (void)showMessage:(NSString *)text;

/**
 *  显示提示信息, 使用默认显示时常1.5秒
 *
 *  @param text      要显示的文字
 */
+(void)showText:(NSString *)text;

/**
 *  显示提示信息
 *
 *  @param text      要显示的文字
 *  @param iinterval 显示的时间
 */
+(void)showText:(NSString *)text withTimeInterval:(CGFloat)interval;

/**
 *  显示服务器返回的错误提示
 *
 *  @param errorDict 服务器返回的错误信息
 *  @param interval 显示的时间
 */
+(void)showErrorWithData:(NSDictionary *)errorDict withTimeInterval:(CGFloat)interval;

@end
