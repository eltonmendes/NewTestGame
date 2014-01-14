//
//  Coin.h
//  RPGTavern
//
//  Created by Elton Mendes on 14/01/14.
//  Copyright (c) 2014 Elton Mendes Vieira Junior. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"

@interface Coin : CCSprite

@property (nonatomic,strong) CCSprite *target;

- (void)runActionCoin;

@end
