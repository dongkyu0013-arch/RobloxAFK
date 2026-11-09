#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RobloxAFKManager : NSObject
@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, strong) UIWindow *overlayWindow;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) NSTimer *afkTimer;
+ (instancetype)sharedInstance;
@end

@implementation RobloxAFKManager

+ (instancetype)sharedInstance {
    static RobloxAFKManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RobloxAFKManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isEnabled = NO;
        // 앱 실행 3초 후 UI 생성
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self createOverlayUI];
        });
    }
    return self;
}

- (void)createOverlayUI {
    UIWindowScene *activeScene = nil;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
            activeScene = (UIWindowScene *)scene;
            break;
        }
    }

    if (activeScene) {
        self.overlayWindow = [[UIWindow alloc] initWithWindowScene:activeScene];
    } else {
        self.overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }

    // 좌측 상단 위치 설정
    self.overlayWindow.frame = CGRectMake(30, 80, 100, 44);
    self.overlayWindow.windowLevel = UIWindowLevelAlert + 1;
    self.overlayWindow.backgroundColor = [UIColor clearColor];

    self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleButton.frame = self.overlayWindow.bounds;
    self.toggleButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.85];
    self.toggleButton.layer.cornerRadius = 10;
    [self.toggleButton setTitle:@"AFK: OFF" forState:UIControlStateNormal];
    [self.toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.toggleButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.toggleButton addTarget:self action:@selector(toggleState) forControlEvents:UIControlEventTouchUpInside];

    [self.overlayWindow addSubview:self.toggleButton];
    self.overlayWindow.hidden = NO;
}

- (void)toggleState {
    self.isEnabled = !self.isEnabled;
    
    // 기존 타이머 초기화
    [self.afkTimer invalidate];
    self.afkTimer = nil;

    if (self.isEnabled) {
        [self.toggleButton setTitle:@"AFK: ON" forState:UIControlStateNormal];
        self.toggleButton.backgroundColor = [UIColor colorWithRed:0.1 green:0.
