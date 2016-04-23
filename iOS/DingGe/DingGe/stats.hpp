#ifndef STATS_H
#define STATS_H

#include "opencv2/opencv.hpp"

struct Stats
{
    int matches;
    int inliers;
    double ratio;
    int keypoints;

    Stats() : matches(0),
        inliers(0),
        ratio(0),
        keypoints(0)
    {}

    Stats& operator+=(const Stats& op) {
        matches += op.matches;
        inliers += op.inliers;
        ratio += op.ratio;
        keypoints += op.keypoints;
        return *this;
    }
    Stats& operator/=(int num)
    {
        matches /= num;
        inliers /= num;
        ratio /= num;
        keypoints /= num;
        return *this;
    }
};

std::vector<cv::Point2f> Points(std::vector<cv::KeyPoint> keypoints)
{
    std::vector<cv::Point2f> res;
    for(unsigned i = 0; i < keypoints.size(); i++) {
        res.push_back(keypoints[i].pt);
    }
    return res;
}

#endif // STATS_H
