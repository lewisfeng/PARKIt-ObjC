//
//  PITutorialViewController.m
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-18.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import "PITutorialViewController.h"
#import "PITutorialPageContentViewController.h"
#import "PIConstants.h"

@interface PITutorialViewController () <UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (copy, nonatomic) NSArray *pageImageNamesArray;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@end

@implementation PITutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageImageNamesArray = @[@"MainScreen.png"       ,
                                 @"MapLegendTutorial.png",
                                 @"SetTimerTutorial.png" ,
                                 @"InfoMeter.png"        ,
                                 @"TimerOnTutorial.png" ];
    
    // create page view controller
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.view.backgroundColor = kColorMain;
    
    PITutorialPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    // bring skip button to front
    [self.view bringSubviewToFront:self.skipButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    // set page view controller frame after viewDidAppear because we can only get skip button real frame here
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + self.skipButton.frame.size.height);
}

- (IBAction)skipButtonClicked:(UIButton *)sender {
    // if this is the first time user see the tutorial, change root view controller to home view controller
    [[NSNotificationCenter defaultCenter] postNotificationName:RootViewControllerChangeNotification object:nil];
    
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((PITutorialPageContentViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((PITutorialPageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    return [self viewControllerAtIndex:index];
}

- (PITutorialPageContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageImageNamesArray count] == 0) || (index >= [self.pageImageNamesArray count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PITutorialPageContentViewController *tutorialPageViewController = [[PITutorialPageContentViewController alloc] init];
    tutorialPageViewController.imageFile = self.pageImageNamesArray[index];
    tutorialPageViewController.pageIndex = index;
    
    return tutorialPageViewController;
}

// optional

//- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
//    return [self.pageImageNamesArray count];
//}
//
//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
//    return 0;
//}



@end
