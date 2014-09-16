//
//  DMGrid.h
//  PathFinder
//
//  Created by daniele on 13/09/14.
//  Copyright (c) 2014 breakfastcode. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DMGridEnumerator)(NSUInteger pos, NSUInteger row, NSUInteger col, id value);

@interface NSIndexPath (GridExtensions)

@property (nonatomic,readonly) NSUInteger column;
@property (nonatomic,readonly) NSUInteger row;

+ (NSIndexPath *)indexPathForRow:(NSUInteger) aRow col:(NSUInteger) aCol;

@end


@interface DMGrid : NSObject

@property (nonatomic,readonly)	NSUInteger	rows;
@property (nonatomic,readonly)	NSUInteger	columns;
@property (nonatomic,readonly)	NSArray		*dataGrid;

#pragma mark - Initialization -

+ (instancetype) gridWithRows:(NSUInteger) aRows columns:(NSUInteger) aColumns;
- (instancetype) gridByApplyTransformer:(id (^)(id originalValue)) aTransformer;

- (instancetype)initWithRows:(NSUInteger) aRows andColumns:(NSUInteger) aColumns;

#pragma mark - Comparing Grids -

- (BOOL) isEqualToGrid:(DMGrid *) aGrid;

#pragma mark - Get/Set Objects -

- (NSUInteger) positionForRow:(NSUInteger) aRow col:(NSUInteger) aCol;
- (NSIndexPath *) indexPathForPosition:(NSUInteger) aPosition;
- (NSArray *) indexPathFromPositions:(NSIndexSet *) aIndexSet;

- (id) valueAtRow:(NSUInteger) aRow col:(NSUInteger) aCol;
- (void) setValue:(id) aValue atRow:(NSUInteger) aRow col:(NSUInteger) aCol;

- (id) valueAtPosition:(NSUInteger) aPosition;
- (void) setValue:(id) aValue atPosition:(NSUInteger) aPosition;

- (id) valueAtIndexPath:(NSIndexPath *) aIndexPath;
- (void) setValue:(id)value atIndexPath:(NSIndexPath *)aIndexPath;

#pragma mark - Walking into the grid -

- (void) enumerateWithBlock:(DMGridEnumerator) callback;
- (void) enumerateWithBlockFromPath:(NSIndexPath *) aFromIndexPath toPath:(NSIndexPath *) aToIndexPath callback:(DMGridEnumerator)callback;
- (void) enumerateWithBlockFrom:(NSUInteger) aStartPos to:(NSUInteger) aEndPost callback:(DMGridEnumerator)callback;

#pragma mark - Isolate portion of the grid -

- (NSArray *) arrayForColumsAtRow:(NSUInteger) aRow;
- (NSArray *) arrayForColumsAtRowIndexes:(NSIndexSet *) aRowIndexes;
- (NSArray *) arrayOfRowsAtColumn:(NSUInteger) aColumn;
- (NSArray *) arrayOfRowsAtColumnIndexes:(NSIndexSet *) aColumnIndexes;
- (NSArray *) itemsAtPaths:(NSArray *) aArrayOfIndexPath;

#pragma mark - Finding objects in array -

- (BOOL) containsObject:(id) aObject;
- (NSInteger) indexOfObject:(id) aObject;
- (NSIndexPath *) indexPathOfObject:(id) aObject;


- (NSUInteger) indexOfObjectAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts
						 passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;

- (NSIndexPath *) indexPathOfObjectAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts
								 passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;


- (NSIndexSet *) indexesOfObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSArray *) indexPathsOfObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;


- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts
								passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;

- (NSArray *)indexPathsOfObjectsWithOptions:(NSEnumerationOptions)opts
								passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;

@end
