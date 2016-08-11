//
//  opencv.m
//  PCEv1.0.4
//
//  Created by 王浩强 on 16/3/15.
//  Copyright © 2016年 王浩强. All rights reserved.
//

#import "opencv.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>

#include "AKAZE_tracker.h"

using namespace std;
using namespace cv;
int fuck = 0;
Mat hist;
cv::Rect trackWindow = cv::Rect(0,0,1,1);

double distance(cv::Point vec1,cv::Point vec2){
    double a,b,dis;
    a = fabs(vec1.x - vec2.x);
    b = fabs(vec1.y - vec2.y);
    dis = sqrt(a*a + b*b);
    return dis;
}

//ios使用opencv用的类，实现图像处理的对应功能
@interface opencv()
{
    cv::CascadeClassifier faceDetector;
    cv::Ptr<cv::ml::KNearest> knn_third;
    cv::Ptr<cv::ml::KNearest> knn_mid;
    cv::Rect selection;
    
}
@end

@implementation opencv
-(id)init
{
    if(self=[super init])
    {
        if_track = 0;
    }
    return self;
}
-(bool) If_track{
    if(if_track == 0)
        return false;
    else
        return true;
}
-(void) change_selection:(CGPoint)point{
    if(point.y-51 < 0 ) return;
    
    float x,y;
    x = 2.88*point.x;
    y = 2.88*(point.y-51);
    
//    if( if_track == 0 ){
        self->selection = cv::Rect(x-10,y-10,20,20);
        if_track = -1;
//    }
}
-(UIImage*) full_white:(UIImage *)img{
    cv::Mat image;
    UIImageToMat(img, image);
    Mat tmp(image.rows,image.cols,CV_8UC3,Scalar::all(255));
    return MatToUIImage(tmp);
}
-(UIImage*) uiimage_resize:(UIImage *)img{
    cv::Mat image;
    UIImageToMat(img, image);
    
    image = image(cv::Rect(0,0,1080,1508));
    return MatToUIImage(image);
}
-(UIImage*)track_object:(UIImage *)img{
    cv::Mat image;
    UIImageToMat(img, image);
    //参数
    int vmin = 10, vmax = 250, smin = 30;
    int hsize = 16;
    float hranges[] = {0,180}; //色调对应区间如何选取
    const float* phranges = hranges;
    
    cv::Mat hsv, hue, mask, backproj;
//    image = image(cv::Rect(0,0,1080,1508));
    img = MatToUIImage(image);
//    circle(image, cv::Point(self->selection.x+10, self->selection.y+10),10,Scalar(0,0,255), 5, LINE_AA);
    cvtColor(image, hsv, COLOR_BGR2HSV);
    if ( if_track != 0 ){
//    if ( if_track == 10 ){//测试
        int _vmin = vmin, _vmax = vmax;

        inRange(hsv, Scalar(0, smin, MIN(_vmin,_vmax)),
                Scalar(180, 256, MAX(_vmin, _vmax)), mask);//去除较弱光线的影响
        
        int ch[] = {0, 0};
        hue.create(hsv.size(), hsv.depth());
        mixChannels(&hsv, 1, &hue, 1, ch, 1);//取出明度通道，为什么不是mask通道
        
        //处理图片，第一次跟踪
        if(if_track < 0){
            trackWindow = self->selection & cv::Rect(0,0,image.cols,image.rows);
            Mat roi(hue, trackWindow), maskroi(mask, trackWindow);
            calcHist(&roi, 1, 0, maskroi, hist, 1, &hsize, &phranges);//计算直方图，输出到hist
            normalize(hist, hist, 0, 255, NORM_MINMAX);//进行平均化
            if_track = 1;
        }
        
        calcBackProject(&hue, 1, 0, hist, backproj, &phranges);
        backproj &= mask;
        RotatedRect trackBox = CamShift(backproj, trackWindow,
                                        TermCriteria( TermCriteria::EPS | TermCriteria::COUNT, 10, 1 ));
        
        if( trackWindow.area() <= 1 )
        {
            int cols = backproj.cols, rows = backproj.rows, r = (MIN(cols, rows) + 5)/6;
            trackWindow = cv::Rect(trackWindow.x - r, trackWindow.y - r,
                                   trackWindow.x + r, trackWindow.y + r) & cv::Rect(0, 0, cols, rows);
        }
        
        //ellipse( image, trackBox, Scalar(0,0,255), 5, LINE_AA );
        Point2f rect_points[4]; trackBox.points( rect_points );
        for( int j = 0; j < 4; j++ )
            line( image, rect_points[j], rect_points[(j+1)%4], Scalar(255,255,255), 3, 8 );
        //rectangle( image, trackWindow, Scalar(0,255,0), 2, LINE_AA);
        //rectangle( backproj, trackWindow, Scalar(0,255,0), 2, LINE_AA);
        //return MatToUIImage(backproj);
    }
    
    return MatToUIImage(image);
}

-(void)loadfacedetc{
    NSString* cascadePath = [[NSBundle mainBundle]pathForResource:@"SupportingFiles/Filehaarcascade_frontalface_alt2" ofType:@"xml"];
    faceDetector.load([cascadePath UTF8String]);
}

-(void)load_file{
    NSString* cascadePath = [[NSBundle mainBundle]pathForResource:@"SupportingFiles/haarcascade_frontalface_alt2" ofType:@"xml"];
    faceDetector.load([cascadePath UTF8String]);
    NSString* knnPath = [[NSBundle mainBundle]pathForResource:@"SupportingFiles/third_KNN_New" ofType:@"xml"];
    knn_third = cv::Algorithm::load<cv::ml::KNearest>([knnPath UTF8String]);
    NSString* knn_midPath = [[NSBundle mainBundle]pathForResource:@"SupportingFiles/mid_KNN_AKAZE" ofType:@"xml"];
    knn_mid = cv::Algorithm::load<cv::ml::KNearest>([knn_midPath UTF8String]);
    //    svm = cv::Algorithm::load<cv::ml::SVM>("third_svm.xml");
    //    logistic = cv::Algorithm::load<cv::ml::LogisticRegression>("third_logistic.xml");
    //    naive_bayes = cv::Algorithm::load<cv::ml::NormalBayesClassifier>("third_NBC.xml");
}

-(double) get_score:(UIImage*)image{
    double score;
    cv::Mat test_data;
    UIImageToMat(image, test_data);
    cv::Mat gray(test_data.rows/2, test_data.cols/2, CV_32FC1);
    cvtColor(test_data,test_data,CV_BGR2GRAY);
    cv::resize(test_data, gray, gray.size());
    std::vector<cv::Rect>faces;
    faceDetector.detectMultiScale(gray, faces, 1.1,2,0|CV_HAAR_SCALE_IMAGE,cv::Size(30,30));
    cv::Rect face;
    if(faces.size() > 1){
        printf("Get face %d", fuck++);
        
        face = faces[0];
    }
    else
        return 20.0+[self get_score_mid:image];
    
    cv::Mat getRespon(1,4,CV_32FC1);
    //   getRespon.at<float>(0) = 1.0;
    getRespon.at<float>(0) = (float)(face.width*face.height)/(gray.cols*gray.rows);
    
    double width,height;
    width = gray.rows;
    height = gray.cols;
    cv::Point pos((face.x+face.width)/2, (face.y+face.height)/2);
    vector<cv::Point> intersection;
    intersection.push_back(cv::Point(width*0.667,height*0.667));
    intersection.push_back(cv::Point(width*0.667,height*0.333));
    intersection.push_back(cv::Point(width*0.333,height*0.667));
    intersection.push_back(cv::Point(width*0.333,height*0.333));
    
    double minDis_inter = 100000;
    for(int i = 0;i<intersection.size();i++){
        //if(minDis < distance:pos :intersection[i])
        if(minDis_inter > distance(pos, intersection[i])){
            minDis_inter = distance(pos ,intersection[i]);
        }
    }
    
    double minDis_line = fabs(width*0.667 - pos.x);
    if(minDis_line > fabs(width*0.333 - pos.x)){
        minDis_line = fabs(width*0.333 - pos.x);
    }
    
    if(minDis_line > fabs(height*0.333 - pos.y)){
        minDis_line = fabs(height*0.333 - pos.y);
    }
    if(minDis_line > fabs(width*0.667 - pos.y)){
        minDis_line = fabs(width*0.667 - pos.y);
    }
    getRespon.at<float>(1) = (minDis_inter)/sqrt(width*width + height*height);
    getRespon.at<float>(2) = (minDis_line)/sqrt(width*width + height*height);
    getRespon.at<float>(3) = 0;
    
    score = knn_third->predict(getRespon);
    printf("third score: %lf\n",score);
    return score;
    
}

-(double)get_score_mid:(UIImage *)image{
    double scores,mean_kp;
    int kp1,kp2;
    
    vector<Point2f> bb;
    Ptr<AKAZE> akaze = AKAZE::create();
    Ptr<DescriptorMatcher> matcher = DescriptorMatcher::create("FlannBased");
    Stats stats1;
    
    
    cv::Mat test_image,left_half,right_half;
    UIImageToMat(image, test_image);
    cv::resize(test_image, test_image, cv::Size(test_image.cols/2, test_image.rows/2));
    
    //prepare left and right half
    left_half  = test_image(cv::Rect(0,0,test_image.cols/2,test_image.rows));
    right_half = test_image(cv::Rect(test_image.cols/2-1,0,test_image.cols/2-1,test_image.rows));
    flip(right_half,right_half,1);
    //prepare
    bb.push_back(Point2f(0,0));
    bb.push_back(Point2f(left_half.cols,0));
    bb.push_back(Point2f(left_half.cols,left_half.rows));
    bb.push_back(Point2f(0,left_half.rows));
    
    Mat data(1, 3, CV_32F);
    akaze->clear();
    akaze->setThreshold(akaze_thresh);
    Tracker akaze_tracker(akaze, matcher);
    kp1 = (int)(akaze_tracker.setFrame(left_half, bb, "AKAZE", stats1)).size();
    kp2 = (int)(akaze_tracker.process(right_half, stats1)).size();
    mean_kp = (kp1 + kp2)/2;
    
    data.at<float>(0,0) = fabs(kp2-mean_kp)/mean_kp;
    data.at<float>(0,1) = ((double)stats1.matches)/mean_kp;
    data.at<float>(0,2) = stats1.inliers * 1.0 /mean_kp;

    cout << data << endl;
    scores = knn_mid->predict(data);
    printf("mid score: %lf\n",scores);
    return scores;
}

//追踪后三分线打分
-(double)get_score_after_track:(UIImage *)image{
    double score,score1;
    Mat test_data,gray;
    UIImageToMat(image, test_data);
    cvtColor(test_data,gray,CV_BGR2GRAY);
    //if(trackWindow.area() < 4){
//        return 20.01 + [self get_score_mid:image];
    //}
    score1 = [self get_score_mid:image];
    
    
    cv::Mat getRespon(1,4,CV_32FC1);
    //   getRespon.at<float>(0) = 1.0;
    getRespon.at<float>(0) = (float)(trackWindow.width*trackWindow.height)/(gray.cols*gray.rows);
    
    double width,height;
    width = gray.rows;
    height = gray.cols;
    cv::Point pos((trackWindow.x+trackWindow.width)/2, (trackWindow.y+trackWindow.height)/2);
    vector<cv::Point_<double>> intersection;
    intersection.push_back(cv::Point_<double>(width*0.667,height*0.667));
    intersection.push_back(cv::Point_<double>(width*0.667,height*0.333));
    intersection.push_back(cv::Point_<double>(width*0.333,height*0.667));
    intersection.push_back(cv::Point_<double>(width*0.333,height*0.333));
    
    double minDis_inter = 100000;
    for(int i = 0;i<intersection.size();i++){
        //if(minDis < distance:pos :intersection[i])
        if(minDis_inter > distance(pos, intersection[i])){
            minDis_inter = distance(pos ,intersection[i]);
        }
    }
    
    double minDis_line = fabs(width*0.667 - pos.x);
    if(minDis_line > fabs(width*0.333 - pos.x)){
        minDis_line = fabs(width*0.333 - pos.x);
    }
    
    if(minDis_line > fabs(height*0.333 - pos.y)){
        minDis_line = fabs(height*0.333 - pos.y);
    }
    if(minDis_line > fabs(width*0.667 - pos.y)){
        minDis_line = fabs(width*0.667 - pos.y);
    }
    getRespon.at<float>(1) = (minDis_inter)/sqrt(width*width + height*height);
    getRespon.at<float>(2) = (minDis_line)/sqrt(width*width + height*height);
    cout << getRespon.at<float>(1) << ", " << getRespon.at<float>(2)<< endl;
    getRespon.at<float>(3) = 0;
    
    score = knn_third->predict(getRespon);
    printf("third score: %lf\n",score);
    if ((score) > score1)
        return score;
    else
        return 20.0+score1;
}

//人脸追踪
-(UIImage*)facedetc:(UIImage*)img{
    
    cv::Mat faceImage,tmp;
    UIImageToMat(img, faceImage);
    cv::Mat gray(faceImage.rows/2, faceImage.cols/2, CV_32FC1);
    cvtColor(faceImage,tmp,CV_BGR2GRAY);
    cv::resize(tmp, gray, gray.size());
    cv::resize(faceImage, faceImage, gray.size());
    faceImage.copyTo(gray);
    
    std::vector<cv::Rect>faces;
    faceDetector.detectMultiScale(gray, faces, 1.1,2,0|CV_HAAR_SCALE_IMAGE,cv::Size(30,30));
    for(unsigned int i= 0;i < faces.size();i++)
    {
        const cv::Rect& face = faces[i];
        cv::Point tl(face.x,face.y);
        cv::Point br = tl + cv::Point(face.width,face.height);
        
        // 四方形的画法
        cv::Scalar magenta = cv::Scalar(255, 0, 255);
        cv::rectangle(faceImage, tl, br, magenta, 4, 8, 0);
    }
    cv::resize(faceImage, faceImage, tmp.size());
    return MatToUIImage(faceImage);
}

@end
