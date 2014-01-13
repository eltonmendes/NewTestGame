//
//  Enemy.h
//  RPGTavern
//
//  Created by Elton Mendes on 13/01/14.
//  Copyright (c) 2014 Elton Mendes Vieira Junior. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"
@protocol EnemyDelegate <NSObject>
- (void)didLeaveTavern;
@end

@interface Enemy : CCSprite
{
    id <EnemyDelegate> _delegate;
    
}
@property (nonatomic,strong) id delegate;
@property (nonatomic) BOOL isSearchingFoodDrink;
@property (nonatomic) BOOL isHungry;
@property (nonatomic) BOOL isQuited;
@property (nonatomic,strong) CCSprite * target;

- (void)runWalkAnimationToTarget:(CCSprite*)target;
- (void)enemyMoveEnd;
- (void)feedEnemy;
- (void)dontFeedEnemy;



@end
