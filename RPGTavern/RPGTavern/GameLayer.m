//
//  GameLayer.m
//  RPGTavern
//
//  Created by Elton Mendes on 07/01/14.
//  Copyright (c) 2014 Elton Mendes Vieira Junior. All rights reserved.
//

#import "GameLayer.h"
#import "CCProgressTimer.h"

@interface GameLayer() {
    ccTime sceneTime;
    int controllerMoveX;
    BOOL isMovingItem;
}
@property (nonatomic,strong) CCSprite *healthBarController;
@property (nonatomic,strong) CCSprite *healthBar;
@property (nonatomic,strong) CCSprite *selectedSpriteToMove;
@property (nonatomic) NSUInteger *selectedItemPosition;
@property (nonatomic) CGPoint selectedSpriteOriginalLocation;
@property (nonatomic,strong) NSArray *menuItens;
@property (nonatomic,strong) NSArray *tables;
@property (nonatomic,strong) NSMutableArray *menuItensCoolDown;
@property (nonatomic,strong) NSMutableDictionary *tableCapacity;

@end
@implementation GameLayer

- (id) init
{
    if((self = [super init])){
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        
        //Background
        CCSprite *background = [[CCSprite alloc]initWithFile:@"backgroundTavern.png"];
        background.position = CGPointMake(400, 300);
        background.opacity = 100;
        [self addChild:background];

        
        //HEALTH BAR
        
        self.healthBar = [[CCSprite alloc]initWithFile:@"healthbar.png"];
        self.healthBar.position = CGPointMake(screenRect.size.height/2, screenRect.size.width-20);
        [self addChild: self.healthBar];
        
        self.healthBarController = [[CCSprite alloc]initWithFile:@"healthController.png"];
        self.healthBarController.position = CGPointMake(self.healthBar.boundingBox.size.width/2 + screenRect.size.height/2,screenRect.size.width-20);
        [self addChild: self.healthBarController];

        
        //TABLE ASSET
        CCSprite *table1 = [[CCSprite alloc]initWithFile:@"table.png"];
        table1.position = CGPointMake(screenRect.size.height/2, 100);
        [self addChild: table1];
        
        CCSprite *table2 = [[CCSprite alloc]initWithFile:@"table.png"];
        table2.position = CGPointMake(screenRect.size.height/2 - 150, 100);
        [self addChild: table2];
        
        self.tables = @[table1,table2];
        
        //Table Capacity
        self.tableCapacity = [[NSMutableDictionary alloc]init];
        self.tableCapacity = [@{@"0":@"0", @"1":@"0"} mutableCopy];
        //progress + menu itens

        
        //Menu Itens
        
        CCSprite *menuItem1 = [CCSprite spriteWithFile:@"woodbeer2x.png"];

        [menuItem1 setTag:0];
        menuItem1.position = ccp(screenRect.size.height/3, screenRect.size.width-60);
        [self addChild:menuItem1];

        CCSprite *menuItem2 = [CCSprite spriteWithFile:@"waterNormal.png"];

        [menuItem2 setTag:1];
        menuItem2.position = ccp(screenRect.size.height/3+30, screenRect.size.width-60);
        [self addChild:menuItem2];

        CCSprite *menuItem3 = [CCSprite spriteWithFile:@"waterPure.png"];

        [menuItem3 setTag:2];
        menuItem3.position = ccp(screenRect.size.height/3+60, screenRect.size.width-60);
        [self addChild:menuItem3];

        CCSprite *menuItem4 = [CCSprite spriteWithFile:@"woodbeer2x.png"];

        [menuItem4 setTag:3];
        menuItem4.position = ccp(screenRect.size.height/3+90, screenRect.size.width-60);
        [self addChild:menuItem4];

        CCSprite *menuItem5 = [CCSprite spriteWithFile:@"waterNormal.png"];

        [menuItem5 setTag:4];
        menuItem5.position = ccp(screenRect.size.height/3+120, screenRect.size.width-60);
        [self addChild:menuItem5];
        
        if(self.menuItens == nil){
            self.menuItens = [[NSArray alloc]init];
            self.menuItensCoolDown = [[NSMutableArray alloc]init];
        }

        self.menuItens = @[menuItem1,menuItem2,menuItem3,menuItem4,menuItem5];
        self.menuItensCoolDown  = [@[ @NO,@NO,@NO,@NO,@NO ] mutableCopy];
        //Damage icon
        
        CCMenuItem *menuItem6 = [CCMenuItemImage
                                 itemWithNormalImage:@"swordIcon.png" selectedImage:@"swordIconSelected.png"
                                 target:self selector:@selector(damageHealth:)];
        [menuItem6 setTag:5];
        menuItem6.position = ccp(screenRect.size.height/3+60, screenRect.size.width-120);
        
        [self setTouchEnabled:YES];

        //Config Init
        
        controllerMoveX =self.healthBar.boundingBox.size.width/10;
        
        [self schedule:@selector(update:) interval:0];
    }
    return self;
}

- (void)menuButtonTapped:(CCSprite*)sprite{
    //Set if you are moving a item

    sprite.Opacity = 100;
 
    //move beer to table

    CCSprite *spriteToMove = [CCSprite spriteWithTexture:sprite.texture];
    [spriteToMove setPosition:sprite.position];
    [self addChild:spriteToMove];
    self.selectedSpriteToMove = spriteToMove;
    self.selectedSpriteOriginalLocation = sprite.position;
    self.selectedItemPosition = sprite.tag;
    //Comment
}

- (void)insertItem:(CCSprite *)sprite inTable:(CCSprite *) table withOrder:(NSUInteger) order{
    CCAction *insertItemAction = [CCMoveTo actionWithDuration:0.5 position:CGPointMake((table.position.x-20) + (order * 20),table.position.y+40)];
    [sprite runAction:insertItemAction];
    
}

- (void)applyCoolDown:(CCSprite *)sprite{
    
    CCProgressTimer *item = [CCProgressTimer progressWithSprite:sprite];
    
    item.position = sprite.position;
    item.opacity = 150;
    item.color = ccc3(255, 100, 100);
    [self addChild:item];
    
    CCProgressFromTo *to1 = [CCProgressFromTo actionWithDuration:5.0f from:0 to:100];
    //Block to re enable at end
    CCCallBlock *reEnable = [CCCallBlock actionWithBlock:^(void) {
        sprite.opacity = 255;
        item.color = ccc3(255, 255, 255);
        [item removeFromParent];
        //set cool down false
        [self.menuItensCoolDown replaceObjectAtIndex:[self.menuItens indexOfObject:sprite] withObject:@NO];

    }];
    [item runAction:[CCSequence actions:to1,reEnable,nil]];
}
- (IBAction)damageHealth:(id)sender{
    [self updateHealthBar];

}

- (void) update:(ccTime) time {
}

- (void) updateHealthBar{
    CCAction *healthMoveAction = [CCMoveTo actionWithDuration:1 position:CGPointMake(self.healthBarController.position.x - controllerMoveX, self.healthBarController.position.y)];
    [self.healthBarController runAction:healthMoveAction];
}

#pragma Touches Delegate

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    CCSprite *sprite = [CCSprite spriteWithFile:@"woodbeer2x.png"];
    
    self.selectedSpriteToMove =sprite;

    for(CCSprite *sprite in self.menuItens){
        if([sprite isKindOfClass:[CCSprite class]]){
            if(CGRectContainsPoint(sprite.boundingBox,location)){
                //Not in cool down
                int index =[self.menuItens indexOfObject:sprite] ;
                if(![[self.menuItensCoolDown objectAtIndex:index] boolValue]){
                    isMovingItem = true;
                    [self menuButtonTapped:sprite];
                }
            }
        }
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    

    if(isMovingItem){
        self.selectedSpriteToMove.position = ccp(location.x, location.y);
        
        //Table1 Logic
        
        for(CCSprite * table in self.tables){
            if(CGRectContainsPoint(table.boundingBox,location)){
                NSString *key = [NSString stringWithFormat:@"%i",[self.tables indexOfObject:table]];
                
                if([[self.tableCapacity objectForKey:key] intValue] >2){
                    [table setColor:ccc3(255, 100, 100)];
                    
                }
                else{
                    [table setColor:ccc3(100, 255, 100)];
                }
            }
            else{
                [table setColor:ccc3(255, 255, 255)];
                
            }
        }
       
    }

}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    BOOL returnToOrigin = true;
    CCSprite *sprite = [self.menuItens objectAtIndex:self.selectedItemPosition];

    for(CCSprite *table in self.tables){
        [table setColor:ccc3(255, 255, 255)];
        NSString *key = [NSString stringWithFormat:@"%i",[self.tables indexOfObject:table]];
        NSUInteger value = [[self.tableCapacity objectForKey:key] intValue];
        NSUInteger newValue = value+1;
        
        if(isMovingItem){
            //Apply cool Down // inserting item
            if(CGRectContainsPoint(table.boundingBox,self.selectedSpriteToMove.position) && [[self.tableCapacity objectForKey:key] intValue] <=2){
                [self applyCoolDown:sprite];
                [self.menuItensCoolDown replaceObjectAtIndex:self.selectedItemPosition withObject:@YES];
                [self.tableCapacity setValue:[NSString stringWithFormat:@"%i",newValue] forKey:key];
                returnToOrigin = false;
                
                //Make a animation to controll the inserted item
                [self insertItem:self.selectedSpriteToMove inTable:table withOrder:value];
                break;
            }
            else{
                returnToOrigin = true;
            }
  
        }

    }
    if(returnToOrigin){
        CCAction *goToOriginalPositionAction = [CCMoveTo actionWithDuration:0.1 position:self.selectedSpriteOriginalLocation];
        CCCallBlock *removeAction = [CCCallBlock actionWithBlock:^(void) {
            [self.selectedSpriteToMove removeFromParent];
            sprite.opacity = 255;
        }];
        
        NSArray * arrayActions = @[goToOriginalPositionAction,removeAction];
        [self.selectedSpriteToMove runAction:[CCSequence actionWithArray:arrayActions]];
        isMovingItem = false;
    }

}



@end
