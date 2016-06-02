//
//  FMReorderableCollectionViewFlowLayout.h
//  CollectionViewDragReorder
//
//  Created by Subo on 16/6/2.
//  Copyright © 2016年 Followme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FMReorderableCollectionViewDelegateFlowLayout;

typedef NS_ENUM(NSUInteger, FMDraggingAxis) {
    FMDraggingAxisFree,
    FMDraggingAxisX,
    FMDraggingAxisY,
    FMDraggingAxisXY
};


@interface FMReorderableCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic) BOOL animating;
// Default is true
@property (nonatomic) BOOL dragEnable;



@end


@protocol FMReorderableCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

- (void)collectionView:(UICollectionView *)collectionView
                layout:(UICollectionViewLayout*)collectionViewLayout
           didMoveItem:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)indexPath;

@end