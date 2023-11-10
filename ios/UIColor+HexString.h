//
//  UIColor+HexString.h
//  DemoMapviewScrollView
//
//  Created by ThinhPhan on 12/18/14.
//  Copyright (c) 2014 Gennova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexString)

/*!
 *  @author Thinh Phan, 14-12-18 16:12:14
 *
 *  @ref http://stackoverflow.com/a/3805354
 *
 *  @brief  Change from hex string to UIColor
 *
 *  @param hexString string format "#abc", "#abcdef31" or "RRGGBB"
 *
 *  @return UIColor object.
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;

/*!
 *  @author Thinh Phan, 14-12-18 16:12:12
 *
 *  @brief  Convert from hex string to UIColor object.
 *
 *  @param hexString string format : #RBG, #ARGB ##RRGGBB or #AARRGGBB.
 *
 *  @return UIColor object.
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;
@end