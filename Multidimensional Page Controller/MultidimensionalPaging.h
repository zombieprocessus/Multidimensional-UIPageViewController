//
//  MultidimensionalPaging.h
//  Multidimensional Page Controller
//
//  Created by Jonathan Neumann Massey on 01/04/2014.
//  Copyright (c) 2014 Zombie Processus. All rights reserved.
//  Find more at WWW.ZOMBIEPROCESS.US

#import <Foundation/Foundation.h>

@interface MultidimensionalPaging : NSObject <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

typedef enum
{
    fluid,
    grid
} NavigationMode;

typedef enum
{
    standard,
    horizontalInfinite,
    verticalInfinite,
    infinite
} CycleMode;

@property (strong, nonatomic) UIPageViewController *completePageController;
@property (strong, nonatomic) NSMutableArray *hierarchyArray;
@property (strong, nonatomic) NSMutableArray *verticalPageControllersArray;
@property CGFloat screenWidth;
@property CGFloat screenHeight;
@property int currentHorizontalIndex;
@property int currentVerticalIndex;
@property NavigationMode navigationMode;
@property CycleMode cycleMode;

+ (id)getSingleton;
- (UIPageViewController *) createMultidimensionalPagingWithArray:(NSArray *)hierarchyArray startHierarchyAtRow:(int)horizontalIndex Column:(int)verticalIndex;

@end
