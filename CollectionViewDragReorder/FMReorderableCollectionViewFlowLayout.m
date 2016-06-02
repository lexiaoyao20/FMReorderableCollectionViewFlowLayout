//
//  FMReorderableCollectionViewFlowLayout.m
//  CollectionViewDragReorder
//
//  Created by Subo on 16/6/2.
//  Copyright © 2016年 Followme. All rights reserved.
//

#import "FMReorderableCollectionViewFlowLayout.h"

@interface _FMDragObject : NSObject

@property (nonatomic) CGPoint offset;
@property (nonatomic) UICollectionViewCell *sourceCell;
@property (nonatomic) UIView *representationImageView;
@property (nonatomic) NSIndexPath *currentIndexPath;

@end

@implementation _FMDragObject


@end

@interface FMReorderableCollectionViewFlowLayout ()<UIGestureRecognizerDelegate>

@property (nonatomic) CGRect collectionViewFrameInCanvas;
@property (strong, nonatomic) NSMutableDictionary *hitTestRectagles;

@property (strong, nonatomic) UIView *canvas;
@property (nonatomic) FMDraggingAxis axis;

@property (strong, nonatomic) _FMDragObject *dragObject;

@end

@implementation FMReorderableCollectionViewFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"collectionView"];
}

- (void)commonInit {
    _animating = NO;
    _dragEnable = YES;
    _axis = FMDraggingAxisFree;
    
    [self addObserver:self forKeyPath:@"collectionView" options:NSKeyValueObservingOptionNew context:nil];
}



- (void)calculateBorders {
    if (!self.collectionView) {
        return;
    }
    
    UICollectionView *collectionView = self.collectionView;
    _collectionViewFrameInCanvas = collectionView.frame;
    
    if (self.canvas != collectionView.superview) {
        _collectionViewFrameInCanvas = [self.canvas convertRect:_collectionViewFrameInCanvas fromView:collectionView];
    }
    
    CGRect leftRect = _collectionViewFrameInCanvas;
    leftRect.size.width = 20.0;
    _hitTestRectagles[@"left"] = [NSValue valueWithCGRect:leftRect];
    
    CGRect topRect = _collectionViewFrameInCanvas;
    topRect.size.height = 20.0;
    _hitTestRectagles[@"top"] = [NSValue valueWithCGRect:topRect];
    
    CGRect rightRect = _collectionViewFrameInCanvas;
    rightRect.origin.x = rightRect.size.width - 20.0;
    rightRect.size.width = 20;
    _hitTestRectagles[@"right"] = [NSValue valueWithCGRect:rightRect];
    
    CGRect bottomRect = _collectionViewFrameInCanvas;
    bottomRect.origin.y = bottomRect.origin.y + rightRect.size.height - 20.0;
    bottomRect.size.height = 20.0;
    _hitTestRectagles[@"bottom"] = [NSValue valueWithCGRect:bottomRect];
}

- (void)setUp {
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    gesture.minimumPressDuration = 0.2;
    gesture.delegate = self;
    [self.collectionView addGestureRecognizer:gesture];
    
    if (self.canvas == nil) {
        self.canvas = self.collectionView.superview;
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture {
    
}

#pragma mark - ......::::::: UIGestureRecognizerDelegate :::::::......

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.dragEnable) {
        return NO;
    }
    
    UIView *ca = self.canvas;
    UICollectionView *cv = self.collectionView;
    
    if (ca && cv) {
        CGPoint pointPressedInCanvas = [gestureRecognizer locationInView:ca];
        for (UICollectionViewCell *cell in cv.visibleCells) {
            CGRect cellInCanvasFrame = [ca convertRect:cell.frame fromView:cv];
            
            if (CGRectContainsPoint(cellInCanvasFrame, pointPressedInCanvas)) {
                UIView *dragView = [cell snapshotViewAfterScreenUpdates:YES];
                dragView.frame = cellInCanvasFrame;
                CGPoint offset = CGPointMake(pointPressedInCanvas.x - cellInCanvasFrame.origin.x,
                                             pointPressedInCanvas.y - cellInCanvasFrame.origin.y);
                
                self.dragObject.offset = offset;
                self.dragObject.currentIndexPath = [cv indexPathForCell:cell];
                self.dragObject.sourceCell = cell;
                self.dragObject.representationImageView = dragView;
                break;
            }
        }
    }
    
    return self.dragObject != nil;
}

#pragma mark - ......::::::: override :::::::......

- (void)prepareLayout {
    [super prepareLayout];
    [self calculateBorders];
}

#pragma mark - ......::::::: Observer :::::::......

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"collectionView"]) {
        [self setUp];
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - ......::::::: Getter and Setter :::::::......

- (NSMutableDictionary *)hitTestRectagles {
    if (!_hitTestRectagles) {
        _hitTestRectagles = [[NSMutableDictionary alloc] init];
    }
    return _hitTestRectagles;
}

- (void)setCanvas:(UIView *)canvas {
    _canvas = canvas;
    
    if (canvas) {
        [self calculateBorders];
    }
}

- (_FMDragObject *)dragObject {
    if (!_dragObject) {
        _dragObject = [[_FMDragObject alloc] init];
    }
    
    return _dragObject;
}

@end
