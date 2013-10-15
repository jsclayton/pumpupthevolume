//
//  CMLViewController.h
//  Volume Testing
//
//  Created by John Clayton on 10/14/13.
//  Copyright (c) 2013 Code Monkey Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMLViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *systemVolumeLabel;
@property (weak, nonatomic) IBOutlet UISlider *playerVolumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *playerVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *actualPlayerVolume;

@end
