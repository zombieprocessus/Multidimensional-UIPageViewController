//
//  MainViewController.m
//  Multidimensional Page Controller
//
//  Created by Jonathan Neumann Massey on 01/04/2014.
//  Copyright (c) 2014 Zombie Processus. All rights reserved.
//  Find more at WWW.ZOMBIEPROCESS.US

#import "MainViewController.h"
#import "MultidimensionalPaging.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // PREPARE THE VIEWS FOR THE INTENDED VIEW HIERARCHY
    // FOR EASE OF UNDERSTANDING ALL THE VIEW CONTROLLERS ARE IN THE STORYBOARD AND THEIR IDENTIFIERS HAVE BEEN SET IN THE RIGHT-HAND PANE.
    // A VIEW'S IDENTIFIER MUST MATCH ITS CLASS NAME!!!
    
    // EXAMPLE 1 - 3X3 MATRIX
    //  VIEW10  VIEW20  VIEW30
    //  VIEW11  VIEW21  VIEW31
    //  VIEW12  VIEW22  VIEW32
    
    NSArray *idFirstVerticalArray = [NSArray arrayWithObjects:@"view10", @"view11", @"view12", nil];
    NSArray *idSecondVerticalArray = [NSArray arrayWithObjects:@"view20", @"view21", @"view22", nil];
    NSArray *idThirdVerticalArray = [NSArray arrayWithObjects:@"view30", @"view31", @"view32", nil];
    
    
    NSArray *idArray = [NSArray arrayWithObjects:idFirstVerticalArray, idSecondVerticalArray, idThirdVerticalArray, nil];
    
    NSMutableArray *hierarchyArray = [self createHierarchyArrayWithIdArray:idArray];
    
    // EXAMPLE 2 - CUSTOM MATRIX
    //  VIEW10  X       X
    //  VIEW11  VIEW21  VIEW31
    //  X       X       VIEW32
    

    idFirstVerticalArray = [NSArray arrayWithObjects:@"view10", @"view11", @"X", nil];
    idSecondVerticalArray = [NSArray arrayWithObjects:@"X", @"view21", @"X", nil];
    idThirdVerticalArray = [NSArray arrayWithObjects:@"X", @"view31", @"view32", nil];
    

    idArray = [NSArray arrayWithObjects:idFirstVerticalArray, idSecondVerticalArray, idThirdVerticalArray, nil];
    
    hierarchyArray = [self createHierarchyArrayWithIdArray:idArray];
    
    // EXAMPLE 3 - CUSTOM MATRIX
    //  X       VIEW20       X
    //  VIEW11  VIEW21  VIEW31
    
    
    idFirstVerticalArray = [NSArray arrayWithObjects:@"X", @"view11", nil];
    idSecondVerticalArray = [NSArray arrayWithObjects:@"view20", @"view21", nil];
    idThirdVerticalArray = [NSArray arrayWithObjects:@"X", @"view31", nil];
    
    
    idArray = [NSArray arrayWithObjects:idFirstVerticalArray, idSecondVerticalArray, idThirdVerticalArray, nil];
    
    hierarchyArray = [self createHierarchyArrayWithIdArray:idArray];
    
    
    // THE ACTUAL BIT WHERE YOU ADD THE MULTIDIMENSIONAL PAGING CONTROLLER TO YOUR VIEW
    // Create the Singleton
    MultidimensionalPaging *multidimensionalPaging = [MultidimensionalPaging getSingleton];
    
    // Create a global UIPageViewController that will be added to your view
    UIPageViewController *myMultidimensionalController = [multidimensionalPaging createMultidimensionalPagingWithArray:hierarchyArray startHierarchyAtRow:1 Column:0];
    
    // There are 4 cycle modes - play with them!
    // standard - where the user can't swipe left, right, up or down when they reach the last views at the border
    // horizontalInfinite - where the user can swipe left and right infinitely and loop back onto their views
    // verticalInfinite - where the user can swipe up and down infinitely and loop back onto their views
    // infinite - where the user can swipe left, right, up and down infinitely and loop back onto their views
    [multidimensionalPaging setCycleMode:standard];
    
    // There are 2 navigation modes - play with them!
    // fluid - where each columns moves independently one from another, just like the date picker
    // grid - where all the columns move together so moving up one view brings all the other columns up one view too etc.
    [multidimensionalPaging setNavigationMode:grid];
    
    // WARNING! GRID DOESN'T WORK ON NON-SYMMETRICAL MATRICES!!!
    
    
    [self addChildViewController:myMultidimensionalController];
    [[self view] addSubview:[myMultidimensionalController view]];
    [myMultidimensionalController didMoveToParentViewController:self];
    // DONE!

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *) createHierarchyArrayWithIdArray:(NSArray *)idArray{
    
    NSMutableArray *hierarchyArray = [[NSMutableArray alloc] init];
    
    for (NSArray *array in idArray) {
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
        
        for (NSString *identifier in array) {
            
            @try {
                UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
                [mutableArray addObject:viewController];
                
            }
            @catch (NSException *exception) {
                [mutableArray addObject:[NSNull null]];
            }
            
        }
        
        [hierarchyArray addObject:mutableArray];
    }
    
    return hierarchyArray;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
