#import "IamportKcpPlugin.h"
#import <Cordova/CDVPlugin.h>

@implementation IamportKcpPlugin

@synthesize viewController;

- (void)pluginInitialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

- (void)handleOpenURL:(NSNotification*)notification
{
    // override to handle urls sent to your app
    // register your url schemes in your App-Info.plist

    NSURL* url = [notification object];
    NSString* MY_APP_SCHEME = [self.commandDelegate.settings objectForKey:[@"IamportAppScheme" lowercaseString]]; //ionic plugin 설치 시 설정한 scheme을 그대로 사용
    NSString* scheme = [url scheme];
    NSString* query = [url query];
    
    if( scheme !=  nil && [scheme hasPrefix:MY_APP_SCHEME] ) {
        query = [query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //ISP 신용카드 인증 후 복귀하는 경우 app_scheme://card_pay?&approval_key=1U4o7afhafcialhfilsan.RSGsgm.fasdfasfas 5ei0000 와 같이 approval_key와 함께 리턴됩니다.
        // approval_key의 마지막 4자리는 ISP인증 결과가 성공이었는지를 나타내는 코드입니다.
        // 실제 카드결제 승인처리는 서버단에서 동작하므로 openURL이 실행된 시점과 승인이 완료되는 시점과는 무관합니다.

        // ISP인증이 잘 되었는지 로깅용으로 approval_key 마지막 4자리 추출
        NSDictionary* query_map = [self parseQueryString:query];
        NSString* approval_key = query_map[@"approval_key"];

        if ( approval_key != nil ) {
            NSLog(@"approval_key is %@", approval_key);

            NSRange range = {[approval_key length]-4,4};
            NSString *resultCode = [approval_key substringWithRange:range];
            NSLog(@"resultCode is %@", resultCode);
            
            if ( [resultCode isEqualToString:@"0000"] == YES ) {
                NSLog(@"ISP인증 성공");
            } else {
                NSLog(@"ISP인증 실패 : %@", resultCode);
            }
        }
    }
}

- (BOOL)shouldOverrideLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    //ISP호출인지부터 체크
    NSString* URLString = [NSString stringWithString:[request.URL absoluteString]];
    //APP STORE URL 경우 openURL 함수를 통해 앱스토어 어플을 활성화 한다.
    BOOL bAppStoreURL = ([URLString rangeOfString:@"phobos.apple.com" options:NSCaseInsensitiveSearch].location != NSNotFound);
    BOOL bAppStoreURL2 = ([URLString rangeOfString:@"itunes.apple.com" options:NSCaseInsensitiveSearch].location != NSNotFound);
    if(bAppStoreURL || bAppStoreURL2) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
    //ISP 호출하는 경우
    if([URLString hasPrefix:@"ispmobile://"]) {
        NSURL *appURL = [NSURL URLWithString:URLString];
        if([[UIApplication sharedApplication] canOpenURL:appURL]) {
            [[UIApplication sharedApplication] openURL:appURL];
        } else {
            [self showAlertViewWithEvent:@"모바일 ISP가 설치되어 있지 않아\nApp Store로 이동합니다." tagNum:99];
            return NO;
        }
    }
    
    //기타(금결원 실시간계좌이체 등)
    NSString *strHttp = @"http://";
    NSString *strHttps = @"https://";
    NSString *strFiles = @"file://"; // index.html(local html file )
    NSString *strIonic = @"ionic://"; // ionic default scheme
    NSString *reqUrl=[[request URL] absoluteString]; NSLog(@"webview 에 요청된 url==>%@",reqUrl);
    if (!([reqUrl hasPrefix:strHttp]) && !([reqUrl hasPrefix:strHttps]) && !([reqUrl hasPrefix:strFiles]) && !([reqUrl hasPrefix:strIonic])) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

- (void)finishLaunching:(NSNotification *)notification
{
    NSLog(@"finishLaunching");
    // iOS6에서 세션끊어지는 상황 방지하기 위해 쿠키 설정. (iOS설정에서 사파리 쿠키 사용 설정도 필요)
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}

-(void)showAlertViewWithEvent:(NSString*)_msg tagNum:(NSInteger)tag
{
    UIAlertView *v = [[UIAlertView alloc]initWithTitle:@"알림"
                                               message:_msg
                                               delegate:self cancelButtonTitle:@"확인"
                                      otherButtonTitles:nil];
    v.tag = tag;
    [v show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 99) {
        // ISP 앱 스토어로 이동
        NSString* URLString = @"https://itunes.apple.com/app/mobail-gyeolje-isp/id369125087?mt=8";
        NSURL* storeURL = [NSURL URLWithString:URLString]; [[UIApplication sharedApplication] openURL:storeURL];
    }
}

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

@end
