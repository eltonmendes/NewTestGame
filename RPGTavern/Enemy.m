//
//  Enemy.m
//  RPGTavern
//
//  Created by Elton Mendes on 13/01/14.
//  Copyright (c) 2014 Elton Mendes Vieira Junior. All rights reserved.
//

#import "Enemy.h"
@interface Enemy()
@property (nonatomic,strong) CCAction *walkAction;

@end
@implementation Enemy


- (id)initWithSpriteFrameName:(NSString *)spriteFrameName{

    
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"io.plist"];

    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"player0.png"];
    spriteSheet.position = CGPointMake(screenRect.size.height/2-100, 100);
    [self addChild:spriteSheet];
    
    
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    for (int i=1; i<=6; i++) {
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"player%d.png",i]]];
    }
    
    CCAnimation *walkAnim = [CCAnimation
                             animationWithSpriteFrames:walkAnimFrames delay:0.2f];
    
    self.walkAction = [CCRepeatForever actionWithAction:
                             [CCAnimate actionWithAnimation:walkAnim]];
    
    return [super initWithSpriteFrameName:spriteFrameName];
}

- (void)runWalkAnimationToTarget:(CCSprite*)target{
    self.target = target;
    [self runAction:self.walkAction];
}
- (void)enemyMoveEnd{
    [self stopAllActions];
    self.isHungry = YES;
    self.isSearchingFoodDrink = YES;

    
}
- (void)feedEnemy{
    //If this is false go to another place!!!
    self.isHungry = NO;
    self.isSearchingFoodDrink = NO;

    [self schedule:@selector(quitTavern) interval:5];
}
- (void)dontFeedEnemy{
    self.isSearchingFoodDrink = NO;
    [self schedule:@selector(quitTavern) interval:5];

}

- (void)quitTavern{
    [self runAction:self.walkAction];
    CCAction * moveAction = [CCMoveTo actionWithDuration:3 position:CGPointMake(self.position.x, self.position.y -200)];
    CCCallBlock *removeSprite = [CCCallBlock actionWithBlock:^(void) {
        [self removeFromParent];
        self.isQuited = true;

    }];
    NSArray * quitArray = @[moveAction,removeSprite];
    [self runAction:[CCSequence actionWithArray:quitArray]];
    [self.delegate didLeaveTavern];
}
@end
