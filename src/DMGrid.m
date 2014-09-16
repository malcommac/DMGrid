//
//  DMGrid.m
//  PathFinder
//
//  Created by daniele on 13/09/14.
//  Copyright (c) 2014 breakfastcode. All rights reserved.
//

#import "DMGrid.h"

@implementation NSIndexPath (GridExtensions)

+ (NSIndexPath *)indexPathForRow:(NSUInteger) aRow col:(NSUInteger) aCol {
	NSUInteger path[2] = {aRow, aCol};
	return [self indexPathWithIndexes:path length:2];
}

- (NSUInteger) row {
	return [self indexAtPosition:0];
}

- (NSUInteger) column {
	return [self indexAtPosition:1];
}

@end

@interface DMGrid () {
	NSMutableArray	*data;
}

@end

@implementation DMGrid

@synthesize dataGrid = data;

- (instancetype) gridByApplyTransformer:(id (^)(id originalValue)) aTransformer {
	DMGrid *grid = [[DMGrid alloc] initWithRows:_rows andColumns:_columns];
	[self enumerateWithBlock:^(NSUInteger pos, NSUInteger row, NSUInteger col, id value) {
		[grid setValue:aTransformer(value) atPosition:pos];
	}];
	return grid;
}

+ (instancetype) gridWithRows:(NSUInteger) aRows columns:(NSUInteger) aColumns {
	return [[DMGrid alloc] initWithRows:aRows andColumns:aColumns];
}

- (instancetype)initWithRows:(NSUInteger) aRows andColumns:(NSUInteger) aColumns {
	self = [super init];
	if (self) {
		_rows = aRows;
		_columns = aColumns;
		NSUInteger length = (_rows * _columns);
		data = [NSMutableArray arrayWithCapacity:length];
		for (int i = 0; i < length; ++i)
			[data addObject:[NSNull null]];
	}
	return self;
}

#pragma mark - Comparing Grids -

- (BOOL) isEqualToGrid:(DMGrid *) aGrid {
	return [data isEqualToArray:aGrid.dataGrid];
}

#pragma mark - Add/Remove/Get Elements -

- (NSUInteger) positionAtIndexPath:(NSIndexPath *) aIndexPath {
	return ((aIndexPath.row * _rows) + aIndexPath.column);
}

- (NSUInteger) positionForRow:(NSUInteger) aRow col:(NSUInteger) aCol {
	// ((number of columns * aRow)+(aCol+1) ) -1)
	return (((_columns*aRow)+(aCol+1))-1);
}

- (NSIndexPath *) indexPathForPosition:(NSUInteger) aPosition {
	NSUInteger rowIdx = (NSUInteger)(aPosition / _rows);
	NSUInteger columnIdx = (aPosition-(rowIdx * _rows));
	return [NSIndexPath indexPathForRow:rowIdx col:columnIdx];
}

- (id)objectForKeyedSubscript:(id)aKey {
	return [self valueAtRow:((NSIndexPath*)aKey).row col:((NSIndexPath*)aKey).column];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)aKey {
	[self setValue:obj atRow:((NSIndexPath*)aKey).row col:((NSIndexPath*)aKey).column];
}

- (id) valueAtIndexPath:(NSIndexPath *) aIndexPath {
	return [self valueAtRow:aIndexPath.row col:aIndexPath.column];
}

- (void) setValue:(id)value atIndexPath:(NSIndexPath *)aIndexPath {
	[self setValue:value atRow:aIndexPath.row col:aIndexPath.column];
}

- (id) valueAtRow:(NSUInteger) aRow col:(NSUInteger) aCol {
	NSUInteger position = [self positionForRow:aRow col:aCol];
	if (data[position] == [NSNull null])
		return nil;
	return data[position];
}

- (void) setValue:(id) aValue atRow:(NSUInteger) aRow col:(NSUInteger) aCol {
	NSUInteger position = [self positionForRow:aRow col:aCol];
	if (aValue == nil) aValue = [NSNull null];
	data[position] = aValue;
}

- (id) valueAtPosition:(NSUInteger) aPosition {
	return data[aPosition];
}

- (void) setValue:(id) aValue atPosition:(NSUInteger) aPosition {
	if (aValue == nil) aValue = [NSNull null];
	data[aPosition] = aValue;
}

- (void) enumerateWithBlock:(DMGridEnumerator) callback {
	[self enumerateWithBlockFrom:NSNotFound to:NSNotFound callback:callback];
}

- (void) enumerateWithBlockFromPath:(NSIndexPath *) aFromIndexPath toPath:(NSIndexPath *) aToIndexPath callback:(DMGridEnumerator) callback {
	NSUInteger fromPosition = 0;
	NSUInteger toPosition = 0;
	if (aFromIndexPath) fromPosition = [self positionForRow:aFromIndexPath.row col:aFromIndexPath.column];
	if (aToIndexPath) toPosition = [self positionForRow:aToIndexPath.row col:aToIndexPath.column];

	[self enumerateWithBlockFrom:fromPosition to:toPosition callback:callback];
}

- (void) enumerateWithBlockFrom:(NSUInteger) aStartPos to:(NSUInteger) aEndPost callback:(DMGridEnumerator) callback {
	if (aStartPos == NSNotFound) aStartPos = 0;
	if (aEndPost == NSNotFound) aEndPost = data.count;
	
	NSUInteger currentRow = (NSUInteger)(aStartPos / _rows);
	NSUInteger currentColumn = (aStartPos-(currentRow * _rows));
	NSUInteger length = (aEndPost - aStartPos);

	for (NSUInteger idx = aStartPos; idx < length; ++idx) {
		callback(idx,currentRow,currentColumn,(data[idx] == [NSNull null] ? nil : data[idx]));
		if (currentColumn == (_columns-1)) {
			currentRow++;
			currentColumn = 0;
		} else
			++currentColumn;
	}
}

- (NSArray *) arrayForColumsAtRow:(NSUInteger) aRow {
	if (aRow > _rows) return nil;
	return [data subarrayWithRange:NSMakeRange((aRow*_columns), _columns)];
}

- (NSArray *) arrayForColumsAtRowIndexes:(NSIndexSet *) aRowIndexes {
	NSMutableArray *columns = [NSMutableArray arrayWithCapacity:aRowIndexes.count];
	[aRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		NSArray *subArray = [data subarrayWithRange:NSMakeRange( (idx*_columns), _columns) ];
		if (subArray) [columns addObject:subArray];
	}];
	return columns;
}

- (NSArray *) arrayOfRowsAtColumn:(NSUInteger) aColumn {
	NSMutableArray *rowItems = [NSMutableArray arrayWithCapacity:_rows];
	NSUInteger position;
	for (NSUInteger row = 0; row < _rows; ++row) {
		position = [self positionForRow:row col:aColumn];
		[rowItems addObject: data[position]];
	}
	return rowItems;
}

- (NSArray *) arrayOfRowsAtColumnIndexes:(NSIndexSet *) aColumnIndexes {
	NSMutableArray *rowsList = [NSMutableArray arrayWithCapacity:aColumnIndexes.count];
	[aColumnIndexes enumerateIndexesUsingBlock:^(NSUInteger columnIdx, BOOL *stop) {
		NSArray *subArray = [self arrayOfRowsAtColumn:columnIdx];
		if (subArray) [rowsList addObject:subArray];
	}];
	return rowsList;
}

- (NSArray *) itemsAtPaths:(NSArray *) aArrayOfIndexPath {
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:aArrayOfIndexPath.count];
	for (NSIndexPath *path in aArrayOfIndexPath) {
		NSUInteger pathPos = [self positionForRow:path.row col:path.column];
		[items addObject: data[pathPos]];
	}
	return items;
}

- (BOOL) containsObject:(id) aObject {
	return [data containsObject:aObject];
}

- (NSInteger) indexOfObject:(id) aObject {
	return [data indexOfObject:aObject];
}

- (NSIndexPath *) indexPathOfObject:(id) aObject {
	NSInteger position = [data indexOfObject:aObject];
	if (position == NSNotFound) return nil;
	return [self indexPathForPosition:position];
}

- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts
						 passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
	return [data indexOfObjectAtIndexes:indexSet options:opts passingTest:predicate];
}

- (NSIndexPath *) indexPathOfObjectAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts
								 passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
	NSUInteger position = [data indexOfObjectAtIndexes:indexSet options:opts passingTest:predicate];
	return [self indexPathForPosition:position];
}

- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
	return [data indexesOfObjectsPassingTest:predicate];
}

- (NSArray *) indexPathsOfObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
	return [self indexPathFromPositions: [data indexesOfObjectsPassingTest:predicate]];
}

- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts
								passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
	return [data indexesOfObjectsWithOptions:opts passingTest:predicate];
}

- (NSArray *)indexPathsOfObjectsWithOptions:(NSEnumerationOptions)opts
								passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
	return [self indexPathFromPositions:[data indexesOfObjectsWithOptions:opts passingTest:predicate]];
}

- (NSArray *) indexPathFromPositions:(NSIndexSet *) aIndexSet {
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:aIndexSet.count];
	[aIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[items addObject: [self indexPathForPosition:idx]];
	}];
	return items;
}

@end
