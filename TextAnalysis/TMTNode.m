//
//  TMTNode.m
//  TextAnalysis
//
//  Created by Greg on 2014-03-17.
//  Copyright (c) 2014 Tasty Morsels. All rights reserved.
//

#import "TMTNode.h"

@implementation TMTNode

-(id)init{
    self = [super init];
    if (self){
        _name = [[NSString alloc] init];
        _frequency = [[NSNumber alloc] initWithFloat:0.0];
        _occurrences = [[NSNumber alloc] initWithLong:1];
        _tree = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id)initWithName:(NSString *)aName{
    self = [super init];
    if (self){
        _name = [[NSString alloc] initWithString:aName];
        _frequency = [[NSNumber alloc] initWithFloat:0.0];
        _occurrences = [[NSNumber alloc] initWithLong:1];
        _tree = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)reinitialize{
    self.name = @"";
    self.frequency = [NSNumber numberWithFloat:0.0];
    self.occurrences = [NSNumber numberWithLong:1];
    [self.tree removeAllObjects];
}

-(void)normalizeTree{
    
    NSArray *keys = [NSArray arrayWithArray:[self.tree allKeys]];
    if (keys != nil){
        TMTNode *aNode = [[TMTNode alloc] init];
        double total = 0.0;
        for (int i=0; i < [keys count]; i++){
            aNode = self.tree[keys[i]];
            total += [[aNode occurrences] doubleValue];
        }
        for (int i=0; i < [keys count]; i++){
            [self.tree[keys[i]]
             setFrequency:[NSNumber
                           numberWithDouble:([[self.tree[keys[i]] occurrences] doubleValue]/total)]];
        }
        //Normalize the subnodes
        for (int i=0; i < [keys count]; i++){
            aNode = self.tree[keys[i]];
            [aNode normalizeTree];
        }
    }
}

-(void)incrementOccurrenceCount{
    long currentCount = [self.occurrences longValue];
    currentCount++;
    [self setOccurrences:[NSNumber numberWithLong:currentCount]];
}

- (void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name forKey:@"TMTNodeName"];
    [aCoder encodeObject:self.occurrences forKey:@"TMTNodeOccurrences"];
    [aCoder encodeObject:self.frequency forKey:@"TMTNodeFrequency"];
    [aCoder encodeObject:self.tree forKey:@"TMTNodeTree"];
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self){
        _name = [aDecoder decodeObjectForKey:@"TMTNodeName"];
        _occurrences = [aDecoder decodeObjectForKey:@"TMTNodeOccurrences"];
        _frequency = [aDecoder decodeObjectForKey:@"TMTNodeFrequency"];
        _tree = [aDecoder decodeObjectForKey:@"TMTNodeTree"];
    }
    return self;
}




@end



