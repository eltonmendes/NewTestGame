//
//  GameLayer.m
//  RPGTavern
//
//  Created by Elton Mendes on 07/01/14.
//  Copyright (c) 2014 Elton Mendes Vieira Junior. All rights reserved.
//

#import "GameLayer.h"
#import "CCProgressTimer.h"
#import "MenuItems.h"
#import "Item.h"
#import "Coin.h"
#import "MessageAlert.h"

@interface GameLayer() {
    ccTime sceneTime;
    int controllerMoveX;
    BOOL isMovingItem;
}
@property (nonatomic,strong) CCSprite *healthBarController;
@property (nonatomic,strong) CCSprite *healthBar;
@property (nonatomic,strong) Item *selectedItemToMove;
@property (nonatomic,strong) Item *sellingItem;
@property (nonatomic,strong) Enemy *enemy;
@property (nonatomic,strong) CCLabelTTF *moneyLabel;
@property (nonatomic) double tavernMoney;
@property (nonatomic) NSUInteger selectedItemPosition;
@property (nonatomic) NSUInteger numberOfClients;
@property (nonatomic) CGPoint selectedSpriteOriginalLocation;
@property (nonatomic,strong) NSArray *menuItens;
@property (nonatomic,strong) NSArray *tables;
@property (nonatomic,strong) NSMutableArray *menuItensCoolDown;
@property (nonatomic,strong) NSMutableDictionary *tableFullPositions;
@property (nonatomic,strong) NSMutableDictionary *tableFullItems;

@end
@implementation GameLayer

- (id) init
{
    if((self = [super init])){
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        
        //Money Info
        self.tavernMoney = 15.0;
        self.moneyLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.2fG",self.tavernMoney] fontName:@"Marker Felt" fontSize:10];
        self.moneyLabel.position = CGPointMake(screenRect.size.height - 100, 260);
        self.moneyLabel.color = ccc3(255, 255, 0);
        [self addChild:self.moneyLabel];
        
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
        table1.position = CGPointMake( screenRect.size.height/2, 100);
        [self addChild: table1];
        
        CCSprite *table2 = [[CCSprite alloc]initWithFile:@"table.png"];
        table2.position = CGPointMake(screenRect.size.height/2 - 150, 100);
        [self addChild: table2];
        
        self.tables = @[table1,table2];
        
        //Table Positions
        self.tableFullPositions = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *filledPositionsTable1 = [@{@"0":@"0",@"1":@"0",@"2":@"0"}mutableCopy];
        NSMutableDictionary *filledPositionsTable2 = [@{@"0":@"0",@"1":@"0",@"2":@"0"}mutableCopy];
        self.tableFullPositions = [@{@"0":filledPositionsTable1, @"1":filledPositionsTable2} mutableCopy];
        //progress + menu itens

        //Table Itens
        self.tableFullItems = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *filledItemsTable1 = [@{@"0":@"0",@"1":@"0",@"2":@"0"}mutableCopy];
        NSMutableDictionary *filledItemsTable2 = [@{@"0":@"0",@"1":@"0",@"2":@"0"}mutableCopy];
        self.tableFullItems = [@{@"0":filledItemsTable1, @"1":filledItemsTable2} mutableCopy];

        
        
        //Menu Items
        if(self.menuItens == nil){
            self.menuItens = [[NSArray alloc]init];
            self.menuItensCoolDown = [[NSMutableArray alloc]init];
        }
        
        MenuItems *items = [[MenuItems alloc]init];
        //add to screen
        for(Item *menuItems in items.menuItems){
            [self addChild:menuItems];
        }


        self.menuItens = items.menuItems;
        self.menuItensCoolDown  = [@[ @NO,@NO,@NO,@NO,@NO ] mutableCopy];
        
        
        [self setTouchEnabled:YES];

        //Config Init
        
        controllerMoveX =self.healthBar.boundingBox.size.width/10;
        
        [self schedule:@selector(update:) interval:0];
        
        
        //Client 1
        [self addClient];

        
    }
    return self;
}

- (void)addClient{
    //ENEMY 1
    
    self.enemy = [[Enemy alloc] initWithSpriteFrameName:@"player0.png"];
    [self.enemy setDelegate:self];
    self.enemy.position = CGPointMake(-100, 100);
    [self addChild: self.enemy];
    
    [self.enemy runWalkAnimationToTarget:[self.tables objectAtIndex:0]];
    CCAction *moveAction = [CCSequence actions:
                            [CCMoveTo actionWithDuration:3 position:CGPointMake(75, 130)],[CCMoveTo actionWithDuration:2 position:CGPointMake(75, 185)],[CCMoveTo actionWithDuration:3 position:CGPointMake(220, 185)],[CCMoveTo actionWithDuration:3 position:CGPointMake(220, 130)],
                            [CCCallFunc actionWithTarget:self.enemy selector:@selector(enemyMoveEnd)],
                            nil];
    [self.enemy runAction:moveAction];
    self.numberOfClients = 1;
}
- (void)menuButtonTapped:(Item*)item{
    //Set if you are moving a item
    item.Opacity = 100;
 
    //move beer to table

    Item *itemToMove = [Item spriteWithTexture:item.texture];
    itemToMove.price = item.price;
    itemToMove.cost = item.cost;
    [itemToMove setPosition:item.position];
    [self addChild:itemToMove];
    self.selectedItemToMove = itemToMove;
    self.selectedSpriteOriginalLocation = item.position;
    self.selectedItemPosition = item.tag;
    
    //Comment
}

- (void)insertItem:(Item *)item inTable:(CCSprite *) table withOrder:(NSString*) key{
    //Insert Logic + position
    NSUInteger positionToInsert = 0;
    
    NSMutableDictionary *positions =[self.tableFullPositions objectForKey:key];
    for(NSString *dicKey in positions){
        NSUInteger value = [[positions objectForKey:dicKey] intValue];
        if(value == 0){
            positionToInsert = [dicKey intValue];
            [positions setValue:@"1" forKey:dicKey];
            break;
        }
    }
    
    [[self.tableFullItems objectForKey:key] setValue:self.selectedItemToMove forKey:[NSString stringWithFormat:@"%i",positionToInsert]];
    
    [self applyCoolDown:item];
    [self.menuItensCoolDown replaceObjectAtIndex:self.selectedItemPosition withObject:@YES];

    
    //Insert Animation Sequence
    
    CCAction *insertItemAction = [CCMoveTo actionWithDuration:0.3 position:CGPointMake((table.position.x-20) + (positionToInsert * 20),table.position.y+40)];
    
    [self.selectedItemToMove runAction:insertItemAction];
    
    //Remove Money From Tavern
    [self schedule:@selector(showLessTavernMoney) interval:0.0005 repeat:item.cost-1 delay:0];

    
}


- (void)resetItemInTable:(CCSprite *) table {
    
    NSUInteger position = 0;
    
    //Table Key
    NSString *key = [NSString stringWithFormat:@"%i",[self.tables indexOfObject:table]];
    
    NSMutableDictionary * allTableItems = [self.tableFullItems objectForKey:key];
    
    Item *item = nil;
    for(NSString *dicKey in allTableItems){
        if([[allTableItems objectForKey:dicKey] isKindOfClass:[CCSprite class]]){
            //Item Find
            item =[allTableItems objectForKey:dicKey];
            [allTableItems setObject:@"" forKey:dicKey];
            //Show Coin Animation!
            self.sellingItem = item;
            int numberOfCoins = item.price / 20;
            [self schedule:@selector(showCoinOfItem) interval:0.5 repeat:numberOfCoins delay:0];

            //Show Money Count
            [self schedule:@selector(showPlusTavernMoney) interval:0.05 repeat:item.price-1 delay:0];
           

            break;
        }
        position +=1;
    }
    
    
    //Pulse Action
    CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:0.5 opacity:127];
    CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:0.5 opacity:255];
    
    CCSequence *pulseSequence = [CCSequence actionOne:fadeIn two:fadeOut];
    CCRepeat *repeat = [CCRepeat actionWithAction:pulseSequence times:5];
 
    //Remove Action
    CCCallBlock *removeSprite = [CCCallBlock actionWithBlock:^(void) {
        [item removeFromParent];
        
        //Remove from array
        
        NSString *key = [NSString stringWithFormat:@"%i",[self.tables indexOfObject:table]];
        NSMutableDictionary *positions = [self.tableFullPositions objectForKey:key];
        
        [positions setValue:@"0" forKey:[NSString stringWithFormat:@"%i",position]];

    }];

    [item runAction:[CCSequence actions:repeat,removeSprite, nil]];
}


- (void)showPlusTavernMoney{
    self.tavernMoney +=1;
    self.moneyLabel.string = [NSString stringWithFormat:@"%.2fG",self.tavernMoney];
}
- (void)showLessTavernMoney{
    self.tavernMoney = self.tavernMoney - 1;
    self.moneyLabel.string = [NSString stringWithFormat:@"%.2fG",self.tavernMoney];

}
- (void)showCoinOfItem{
    
    Coin *coin = [Coin spriteWithFile:@"coin.png"];
    coin.position =self.sellingItem.position;
    coin.target = self.moneyLabel;
    [self addChild:coin];
    [coin runActionCoin];

   
}

- (void)applyCoolDown:(Item *)item{
    
    CCProgressTimer *itemProgress = [CCProgressTimer progressWithSprite:item];
    
    itemProgress.position = item.position;
    itemProgress.opacity = 150;
    itemProgress.color = ccc3(255, 100, 100);
    [self addChild:itemProgress];
    
    CCProgressFromTo *to1 = [CCProgressFromTo actionWithDuration:5.0f from:0 to:100];
    //Block to re enable at end
    CCCallBlock *reEnable = [CCCallBlock actionWithBlock:^(void) {
        item.opacity = 255;
        itemProgress.color = ccc3(255, 255, 255);
        [itemProgress removeFromParent];
        //set cool down false
        [self.menuItensCoolDown replaceObjectAtIndex:[self.menuItens indexOfObject:item] withObject:@NO];

    }];
    [itemProgress runAction:[CCSequence actions:to1,reEnable,nil]];
}

- (void) returnItemToOriginalPosition:(CCSprite *)sprite{
    CCAction *goToOriginalPositionAction = [CCMoveTo actionWithDuration:0.1 position:self.selectedSpriteOriginalLocation];
    CCCallBlock *removeAction = [CCCallBlock actionWithBlock:^(void) {
        [self.selectedItemToMove removeFromParent];
        sprite.opacity = 255;
    }];
    
    NSArray * arrayActions = @[goToOriginalPositionAction,removeAction];
    [self.selectedItemToMove runAction:[CCSequence actionWithArray:arrayActions]];
}
- (IBAction)damageHealth:(id)sender{
    [self updateHealthBar];

}

- (void) update:(ccTime) time {
    
    
    if(self.numberOfClients == 0 && self.enemy.isQuited){
        [self addClient];
    }
    
    if(self.enemy.isSearchingFoodDrink){
        
        if(![self tryToFeed]){
            [self.enemy dontFeedEnemy];
        }
        else{
            [self.enemy feedEnemy];

        }
        self.numberOfClients -= 1;
    }
}

- (void)didLeaveTavern{
    if(self.enemy.isHungry){
        [self showFeedAlertWithSucces:NO];
        [self damageHealth:nil];

    }
    else{
        [self showFeedAlertWithSucces:YES];
    }
}

- (BOOL)tryToFeed{
    NSString *key = [NSString stringWithFormat:@"%i",[self.tables indexOfObject:self.enemy.target]];
    //Check if there is a item into table
    NSMutableDictionary *positions = [self.tableFullPositions objectForKey:key];
    for(NSString *dicKey in positions){
        NSUInteger value = [[positions objectForKey:dicKey] intValue];
        if(value == 1){
            //Remove Item From Table!
            [self resetItemInTable:self.enemy.target];
            return true;
        }
    }
    return false;
}

- (void)showFeedAlertWithSucces:(BOOL) sucess{
    NSString * warning = @"Aventureiro Saiu Bravo!";
    if(sucess){
        warning = @"Aventureiro Saiu Satisfeito!";
    }
    MessageAlert *label = [MessageAlert labelWithString:warning fontName:@"Marker Felt" fontSize:40];
    [label showMessageAlert];
    [self addChild: label z:1];
    
    }

- (NSUInteger) numberOfFilledPositionsAtKey:(NSString*) key{
    NSUInteger numberOfFilledPositions = 0;
    NSMutableDictionary * positions = [self.tableFullPositions objectForKey:key];
    for(NSString *key in positions){
        if([[positions objectForKey:key]intValue] == 1){
            numberOfFilledPositions += 1;
        }
    }
    return numberOfFilledPositions;
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


    for(Item *item in self.menuItens){
        if([item isKindOfClass:[Item class]]){
            if(CGRectContainsPoint(item.boundingBox,location)){
                //Not in cool down
                int index =[self.menuItens indexOfObject:item] ;
                if(![[self.menuItensCoolDown objectAtIndex:index] boolValue]){
                    
                    //check item cost
                    if(self.tavernMoney >= item.cost){
                        isMovingItem = true;
                        [self menuButtonTapped:item];
                    }
                    else{
                        item.color = ccc3(255, 100, 100);
                        self.selectedItemPosition = item.tag;
                    }
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
        self.selectedItemToMove.position = ccp(location.x, location.y);
        
        //Table1 Logic
        
        for(CCSprite * table in self.tables){
            if(CGRectContainsPoint(table.boundingBox,location)){
                NSString *key = [NSString stringWithFormat:@"%i",[self.tables indexOfObject:table]];
                if([self numberOfFilledPositionsAtKey:key] >2){
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
    Item *item = [self.menuItens objectAtIndex:self.selectedItemPosition];
    item.color = ccc3(255, 255, 255);
    if(isMovingItem){
        for(CCSprite *table in self.tables){
            [table setColor:ccc3(255, 255, 255)];
            NSString *key = [NSString stringWithFormat:@"%i",[self.tables indexOfObject:table]];
            
            //Apply cool Down // inserting item
            if(CGRectContainsPoint(table.boundingBox,self.selectedItemToMove.position) && [self numberOfFilledPositionsAtKey:key] <=2){
                
                returnToOrigin = false;
                //Make a animation to controll the inserted item
                [self insertItem:item inTable:table withOrder:key];
                break;
            }
            else{
                returnToOrigin = true;
            }
        }
        if(returnToOrigin){
            [self returnItemToOriginalPosition:item];
        }

    }

    isMovingItem = false;

}




@end
