//
//  ContainerViewController.m
//  TCCKronos
//
//  Created by Luke Roberts on 12/09/2023.
//

#import "ContainerViewController.h"
#import "SetupViewController.h"

@interface ContainerViewController ()

@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SetupViewController* setupViewController = [[SetupViewController alloc] initWithNibName:@"SetupView" bundle:nil];
    
    [self addChildViewController:setupViewController];
}

@end
