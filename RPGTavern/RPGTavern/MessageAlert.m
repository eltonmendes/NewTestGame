//
//  MessageAlert.m
//  RPGTavern
//
//  Created by Elton Mendes on 14/01/14.
//  Copyright (c) 2014 Elton Mendes Vieira Junior. All rights reserved.
//

#import "MessageAlert.h"

@implementation MessageAlert

- (void)showMessageAlert{
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    self.position =  ccp( size.width /2 , size.height/2 );
    self.color = ccc3(255, 100, 100);

    CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:4 opacity:0];
    CCCallBlock *removeSprite = [CCCallBlock actionWithBlock:^(void) {
        [self removeFromParent];
    }];
    NSArray * fadeOutAction = @[fadeOut,removeSprite];
    [self runAction:[CCSequence actionWithArray:fadeOutAction]];
    

}

@end
