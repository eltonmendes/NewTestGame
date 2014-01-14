//
//  Coin.m
//  RPGTavern
//
//  Created by Elton Mendes on 14/01/14.
//  Copyright (c) 2014 Elton Mendes Vieira Junior. All rights reserved.
//

#import "Coin.h"

@implementation Coin


- (void)runActionCoin{
    [[CCDirector sharedDirector] setProjection:kCCDirectorProjection3D];
    
    
    //UP + ROTATE
    CCAction *upAction = [CCMoveTo actionWithDuration:0.5 position:CGPointMake(self.position.x, self.position.y+30)];
    CCOrbitCamera *rotateUpAction = [CCOrbitCamera actionWithDuration:0.5 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:0];
    NSArray *upRotateActionArray = @[upAction,rotateUpAction];
    CCAction *upRotateAction = [CCSpawn actionWithArray:upRotateActionArray];
    
    
    //DOWN + ROTATE
    CCAction *downAction = [CCMoveTo actionWithDuration:1 position:CGPointMake(self.position.x, self.position.y+10)];
    CCOrbitCamera *rotateDownAction = [CCOrbitCamera actionWithDuration:1 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:0];
    NSArray *downRotateActionArray = @[downAction,rotateDownAction];
    CCAction *downRotateAction = [CCSpawn actionWithArray:downRotateActionArray];
    
    //MOVE + ROTATE
    CCOrbitCamera *rotateCoinAction = [CCOrbitCamera actionWithDuration:1 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:1440 angleX:0 deltaAngleX:0];
    
    CCAction *moveCointAction = [CCMoveTo actionWithDuration:1 position:self.target.position];
    
    CCCallBlock *removeAction = [CCCallBlock actionWithBlock:^(void) {
        [self removeFromParent];
    }];
    
    NSArray * arrayActions = @[moveCointAction,removeAction];
    
    CCAction *moveRemoveSequence = [CCSequence actionWithArray:arrayActions];
    
    CCCallBlock *goToLabelAction = [CCCallBlock actionWithBlock:^(void) {
        [self runAction:moveRemoveSequence];
        [self runAction:rotateCoinAction];
    }];
    
    //FULL ACTION
    
    NSArray * upAndDownArrayActions = @[upRotateAction,downRotateAction,goToLabelAction];
    
    
    CCAction *upAndDownMoveSequence = [CCSequence actionWithArray:upAndDownArrayActions];
    
    [self runAction:upAndDownMoveSequence];
}


@end
