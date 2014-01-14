//
//  MenuItems.m
//  RPGTavern
//
//  Created by Elton Mendes on 14/01/14.
//  Copyright (c) 2014 Elton Mendes Vieira Junior. All rights reserved.
//

#import "MenuItems.h"
#import "Item.h"

@implementation MenuItems

-(id)init{
    
    if((self = [super init])){
    
        CGRect screenRect = [[UIScreen mainScreen] bounds];

        
        //Menu Itens
        Item *menuItem1 = [[Item alloc]initWithFile:@"woodbeer2x.png"];
        menuItem1.price = 40.0;
        menuItem1.cost = 20.0;
        menuItem1.tag = 0;
        menuItem1.position = ccp(screenRect.size.height/3, screenRect.size.width-60);
        [self addPriceToItem:menuItem1];


        Item *menuItem2 = [[Item alloc]initWithFile:@"wineBottle.png"];
        menuItem2.tag = 1;
        menuItem2.price = 50.0;
        menuItem2.cost = 25.0;
        menuItem2.position = ccp(screenRect.size.height/3+30, screenRect.size.width-60);
        [self addPriceToItem:menuItem2];

        Item *menuItem3 = [[Item alloc]initWithFile:@"bread.png"];
        menuItem3.tag = 2;
        menuItem3.price = 8.0;
        menuItem3.cost = 4.0;
        menuItem3.position = ccp(screenRect.size.height/3+60, screenRect.size.width-60);
        [self addPriceToItem:menuItem3];

        Item *menuItem4 = [[Item alloc]initWithFile:@"cheese.png"];
        menuItem4.tag = 3;
        menuItem4.price = 12.0;
        menuItem4.cost = 6.0;
        menuItem4.position = ccp(screenRect.size.height/3+90, screenRect.size.width-60);
        [self addPriceToItem:menuItem4];

        Item *menuItem5 = [[Item alloc]initWithFile:@"milkBottle.png"];
        
        menuItem5.tag = 4;
        menuItem5.price = 10.0;
        menuItem5.cost = 5.0;
        menuItem5.position = ccp(screenRect.size.height/3+120, screenRect.size.width-60);
        [self addPriceToItem:menuItem5];
        
        
        self.menuItems =  @[menuItem1,menuItem2,menuItem3,menuItem4,menuItem5];
    }
    return self;

}

- (void)addPriceToItem:(Item *)item{
    CCLabelTTF *moneyLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.0fG",item.cost] fontName:@"Marker Felt" fontSize:6];
    moneyLabel.color = ccc3(255, 255, 0);
    moneyLabel.position = CGPointMake(20, 0);
    [item addChild:moneyLabel];

}

@end
