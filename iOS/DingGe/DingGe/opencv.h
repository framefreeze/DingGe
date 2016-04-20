//
//  opencv.h
//  PCEv1.0.4
//
//  Created by 王浩强 on 16/3/15.
//  Copyright © 2016年 王浩强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface opencv : NSObject
{
    int if_track;
}//opencv

-(void) change_selection:(CGPoint)point;
-(UIImage*)facedetc:(UIImage*)img;//人脸检测（以停用
-(UIImage*)track_object:(UIImage*)img;
-(UIImage*)full_white:(UIImage*)img;
-(void)load_file;//文件加载
-(double)get_score:(UIImage*)image;//三分线打分
-(double)get_score_mid:(UIImage*)image;//对称打分
-(double)get_score_after_track:(UIImage*)image;
-(void)loadfacedetc;//加载人脸检测（以停用
@end
