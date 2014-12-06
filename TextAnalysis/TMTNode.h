//
//  TMTNode.h
//  TextAnalysis
//
//  Created by Greg on 2014-03-17.
//  Copyright (c) 2014 Tasty Morsels. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMTNode : NSObject <NSCoding>

@property NSString *name;
@property NSNumber *occurrences;
@property NSNumber *frequency;
@property NSMutableDictionary *tree;
@property NSDictionary *archivedTree;

-(id)init;
-(id)initWithName:(NSString *)aName;
-(void)normalizeTree;
-(void)incrementOccurrenceCount;
-(void)reinitialize;

- (void) encodeWithCoder:(NSCoder *)aCoder;
- (id) initWithCoder:(NSCoder *)aDecoder;

@end
