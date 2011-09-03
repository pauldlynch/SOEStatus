// see http://www.icab.de/blog/2009/11/15/moving-objects-within-an-nsmutablearray/

@interface NSMutableArray (MoveArray)

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;

@end