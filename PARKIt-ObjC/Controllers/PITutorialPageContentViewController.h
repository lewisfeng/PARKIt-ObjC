//
//  PITutorialPageContentViewController.h
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-18.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PITutorialPageContentViewController : UIViewController
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, copy) NSString *imageFile;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end
