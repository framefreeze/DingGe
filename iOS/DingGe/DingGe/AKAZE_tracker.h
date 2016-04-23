//
//  AKAZE_tracker.h
//  DingGe
//
//  Created by 王浩强 on 16/4/23.
//  Copyright © 2016年 FrameFreeze. All rights reserved.
//

#ifndef AKAZE_tracker_h
#define AKAZE_tracker_h


#include  <opencv2/opencv.hpp>
#include "stats.h"

using namespace std;
using namespace cv;

//对称匹配使用类
const double akaze_thresh = 3e-4; // AKAZE detection threshold set to locate about 1000 keypoints
const double ransac_thresh = 30.0f; // RANSAC inlier threshold
const double nn_match_ratio = 0.9f; // Nearest-neighbour matching ratio
class Tracker
{
public:
    Tracker(Ptr<Feature2D> _detector, Ptr<DescriptorMatcher> _matcher) :
    detector(_detector),
    matcher(_matcher)
    {}
    
    vector<KeyPoint> setFrame(const Mat frame, vector<Point2f> bb, string title, Stats& stats);
    vector<KeyPoint> process(const Mat frame, Stats& stats);
    vector<KeyPoint> process1(const Mat frame, Stats& stats);
    Ptr<Feature2D> getDetector() {
        return detector;
    }
protected:
    Ptr<Feature2D> detector;
    Ptr<DescriptorMatcher> matcher;
    Mat first_frame, first_desc;
    vector<KeyPoint> first_kp;
    vector<KeyPoint> second_kp;
};

vector<KeyPoint> Tracker::setFrame(const Mat frame, vector<Point2f> bb, string title, Stats& stats)
{
    first_frame = frame.clone();
    //使用keypoint detector, no mask
    detector->detectAndCompute(first_frame, noArray(), first_kp, first_desc);
    cout << "left KeyPoint = " << first_kp.size();
    
    return first_kp;
}

vector<KeyPoint> Tracker::process(const Mat frame, Stats& stats) //左右对称计算
{
    Mat desc;
    detector->detectAndCompute(frame, noArray(), second_kp, desc);
    cout << " right_half KeyPoint = " << second_kp.size() << endl;
    
    if(first_desc.type()!=CV_32F) {
        first_desc.convertTo(first_desc, CV_32F);
    }
    if(desc.type()!=CV_32F) {
        desc.convertTo(desc, CV_32F);
    }
    
    vector< vector<DMatch> > matches;
    vector<KeyPoint> matched1, matched2;
    matcher->knnMatch(first_desc, desc, matches, 2);
    for(unsigned i = 0; i < matches.size(); i++) {
        if(matches[i][0].distance < nn_match_ratio * matches[i][1].distance) {
            matched1.push_back( first_kp[matches[i][0].queryIdx]);
            matched2.push_back(second_kp[matches[i][0].trainIdx]);
        }
    }
    stats.matches = (int)matched1.size();
    
    Mat inlier_mask, homography;
    if(matched1.size() >= 4) {
        homography = findHomography(Points(matched1), Points(matched2),
                                    RANSAC, ransac_thresh, inlier_mask);
    }
    
    stats.inliers = 0;
    for(unsigned i = 0; i < matched1.size(); i++) {
        if(inlier_mask.at<uchar>(i)) {
            stats.inliers++;
        }
    }
    stats.ratio = stats.inliers * 1.0 / stats.matches;
    
    return second_kp;
}

vector<KeyPoint> Tracker::process1(const Mat frame, Stats& stats)
{
    Mat desc;
    detector->detectAndCompute(frame, noArray(), second_kp, desc);
    
    if(first_desc.type()!=CV_32F) {
        first_desc.convertTo(first_desc, CV_32F);
    }
    if(desc.type()!=CV_32F) {
        desc.convertTo(desc, CV_32F);
    }
    
    vector< vector<DMatch> > matches;
    vector<KeyPoint> matched1, matched2;
    matcher->knnMatch(first_desc, desc, matches, 2);
    for(unsigned i = 0; i < matches.size(); i++) {
        if(matches[i][0].distance < nn_match_ratio * matches[i][1].distance) {
            matched1.push_back( first_kp[matches[i][0].queryIdx]);
            matched2.push_back(second_kp[matches[i][0].trainIdx]);
        }
    }
    stats.matches = (int)matched1.size();

    Mat inlier_mask, homography;
    if(matched1.size() >= 4) {
        homography = findHomography(Points(matched1), Points(matched2),
                                    RANSAC, ransac_thresh, inlier_mask);
    }
    
    stats.inliers = 0;
    for(unsigned i = 0; i < matched1.size(); i++) {
        if(inlier_mask.at<uchar>(i)) {
            stats.inliers++;
        }
    }
    stats.ratio = stats.inliers * 1.0 / stats.matches;

    return second_kp;
}


#endif /* AKAZE_tracker_h */
