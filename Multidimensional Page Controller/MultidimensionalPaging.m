//
//  MultidimensionalPaging.m
//  Multidimensional Page Controller
//
//  Created by Jonathan Neumann Massey on 01/04/2014.
//  Copyright (c) 2014 Zombie Processus. All rights reserved.
//  Find more at WWW.ZOMBIEPROCESS.US

// IN ORDER TO CALL THE SINGLETON DO (DON'T FORGET TO ADD THIS CLASS WHEREVER IT'S CALLED!)
// MultidimensionalPaging *multidimensionalPaging = [MultidimensionalPaging getSingleton];

#import "MultidimensionalPaging.h"

@implementation MultidimensionalPaging

#pragma mark - Singleton Methods

//publicly accessible method
+(id)getSingleton {
    
    static MultidimensionalPaging *sharedUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUser = [[self alloc] init];
    });
    return sharedUser;
}

- (id)init {
    
    if (self = [super init]){
        
        // INIT THE PAGE CONTROLLER
        self.completePageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        
        // SET THE DELEGATE AND SOURCE TO SELF
        self.completePageController.dataSource = self;
        self.completePageController.delegate = self;
        
        // I ASSUME YOU WANT THE MULTIDIMENSIONAL PAGE CONTROLLER TO FILL THE WHOLE SCREEN, RIGHT?
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        _screenWidth = screenRect.size.width;
        _screenHeight = screenRect.size.height;

        [[self.completePageController view] setFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
        
        // BY DEFAULT CREATE A FLUID NAVIGATION WITH STANDARD CYCLE
        _navigationMode = fluid;
        _cycleMode = standard;
        
    }
    
    return self;
}


- (UIPageViewController *) createMultidimensionalPagingWithArray:(NSArray *)hierarchyArray startHierarchyAtRow:(int)horizontalIndex Column:(int)verticalIndex{
    
    _hierarchyArray = [hierarchyArray mutableCopy];
    _verticalPageControllersArray = [[NSMutableArray alloc] init];
    
    // Protection against wrong column and row
    //verticalIndex = (verticalIndex < [hierarchyArray count]) ? verticalIndex : 0;
    verticalIndex = ([_hierarchyArray objectAtIndex:verticalIndex] != nil) ? verticalIndex : 0;
    horizontalIndex = ([[_hierarchyArray objectAtIndex:verticalIndex] objectAtIndex:horizontalIndex] != nil) ? horizontalIndex : 0;
    _currentHorizontalIndex = verticalIndex;
    _currentVerticalIndex = (verticalIndex+1)*10+horizontalIndex;
    
    
    int hI = 0;
    
    // Create a temp Array as an object cannot be replaced in an array while it is being enumerated
    NSArray *temp1Array = [_hierarchyArray copy];

    for (NSMutableArray *verticalArray in temp1Array) {
        
        int i = 0;
        
        // Create a temp Array as an object cannot be replaced in an array while it is being enumerated
        NSArray *temp2Array = [verticalArray copy];
        for (UIViewController *viewController in temp2Array) {
            
            if (viewController != (id)[NSNull null]) {
                
                int tag = (hI+1)*10 + i;
                viewController.view.tag = tag;
                [verticalArray replaceObjectAtIndex:i withObject:viewController];
            }
            
            i++;
        }
        
        [_hierarchyArray replaceObjectAtIndex:hI withObject:verticalArray];
        
        UIPageViewController *verticalPageController = [self createNewVerticalPageController];
        NSArray *initialViewController = [NSArray arrayWithObject:[verticalArray objectAtIndex:horizontalIndex]];
        [verticalPageController setViewControllers:initialViewController direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        verticalPageController.view.tag = hI;
        
        [_verticalPageControllersArray addObject:verticalPageController];
        
        hI++;
        
    }
    
    NSArray *initialViewController = [NSArray arrayWithObject:[_verticalPageControllersArray objectAtIndex:verticalIndex]];
    [self.completePageController setViewControllers:initialViewController direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    return self.completePageController;
}

- (UIPageViewController *) createNewVerticalPageController{
    
    UIPageViewController *verticalPageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    verticalPageController.dataSource = self;
    verticalPageController.delegate = self;
    
    [[verticalPageController view] setFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    
    return verticalPageController;
}

#pragma mark - UIPageViewControllerDataSource Methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    if (viewController.view.tag/10 < 1) {
        
        _currentHorizontalIndex = viewController.view.tag;
        
        [self viewMovedTo:viewController.view.tag];
        
        // get the tag of the current view -1
        NSInteger index = viewController.view.tag;
        index--;
        
        if (index < 0 && (_cycleMode == standard || _cycleMode == verticalInfinite)) {
            return nil;
        }
        else if (index < 0 && (_cycleMode == horizontalInfinite || _cycleMode == infinite)) {
            index = [_verticalPageControllersArray count]-1;
        }
        
        return ([_verticalPageControllersArray objectAtIndex:index] != (id)[NSNull null]) ? [_verticalPageControllersArray objectAtIndex:index] : nil;
        
    }
    else {
        
        _currentVerticalIndex = viewController.view.tag;
        
        [self viewMovedTo:viewController.view.tag];
        
        float division = viewController.view.tag/10;
        int roundedDown = floor(division);
        
        // get the tag of the current view -1
        NSInteger index = viewController.view.tag%10;
        index--;
        
        if (index < 0 && (_cycleMode == standard || _cycleMode == horizontalInfinite)) {
            return nil;
        }
        else if (index < 0 && (_cycleMode == verticalInfinite || _cycleMode == infinite)) {
            index = [[_hierarchyArray objectAtIndex:roundedDown-1] count]-1;
        }

        return ([[_hierarchyArray objectAtIndex:roundedDown-1] objectAtIndex:index] != (id)[NSNull null]) ? [[_hierarchyArray objectAtIndex:roundedDown-1] objectAtIndex:index] : nil;
    }
    
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if (viewController.view.tag/10 < 1) {
        
        _currentHorizontalIndex = viewController.view.tag;
        [self viewMovedTo:viewController.view.tag];
        
        // get the tag of the current view +1
        NSInteger index = viewController.view.tag;
        index++;
        
        if (index >= [_verticalPageControllersArray count] && (_cycleMode == standard || _cycleMode == verticalInfinite)) {
            return nil;
        }
        else if (index >= [_verticalPageControllersArray count] && (_cycleMode == horizontalInfinite ||  _cycleMode == infinite)) {
            index = 0;
        }
        
        return ([_verticalPageControllersArray objectAtIndex:index] != (id)[NSNull null]) ? [_verticalPageControllersArray objectAtIndex:index] : nil;
        
    }
    else {
        
        _currentVerticalIndex = viewController.view.tag;
        [self viewMovedTo:viewController.view.tag];
        
        // get the tag of the current view +1
        NSInteger index = viewController.view.tag%10;
        index++;
        
        float division = viewController.view.tag/10;
        int roundedDown = floor(division);
        
        if (index == [[_hierarchyArray objectAtIndex:roundedDown-1]count] && (_cycleMode == standard || _cycleMode == horizontalInfinite)) {
            return nil;
        }
        else if (index == [[_hierarchyArray objectAtIndex:roundedDown-1]count] && (_cycleMode == verticalInfinite || _cycleMode == infinite)) {
            index = 0;
        }
        
        return ([[_hierarchyArray objectAtIndex:roundedDown-1] objectAtIndex:index] != (id)[NSNull null]) ? [[_hierarchyArray objectAtIndex:roundedDown-1] objectAtIndex:index] : nil;
        
    }
    
}

- (void) pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    
    if (finished && completed && _navigationMode == grid) {
        
        int tag = [[pageViewController.viewControllers[0] view] tag];
        
        // Means we have swiped up or down
        if (tag/10 >= 1 && _navigationMode == grid) {
            
            for (int i = 0; i < [_verticalPageControllersArray count]; i++) {
                
                if (i != _currentHorizontalIndex){
                    
                    UIPageViewController *verticalPageViewController = [_verticalPageControllersArray objectAtIndex:i];
                    NSArray *adaptedViewController = [NSArray arrayWithObject: [[_hierarchyArray objectAtIndex:i]objectAtIndex:tag%10]];
                        
                        [verticalPageViewController setViewControllers:adaptedViewController direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
                        [_verticalPageControllersArray replaceObjectAtIndex:i withObject:verticalPageViewController];

                }
            }
        }
        
    }
}

- (void) viewMovedTo:(int)tag{
    
    NSLog(@"current view is view %d", tag);
    
}

@end
