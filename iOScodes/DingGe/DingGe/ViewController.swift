//
//  ViewController.swift
//  PCEv1.0.4
//
//  Created by 王浩强 on 16/3/15.
//  Copyright © 2016年 王浩强. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIScrollViewDelegate{
    //firstLauch
    var firstLaunchScrollView: UIScrollView!
    var firstLaunchPageCtrl:UIPageControl!
    @IBOutlet var firstLaunchView: UIView!
    var exitFirstLaunchButton:UIButton!
    
    @IBOutlet var indexStackView: UIStackView!
    let imgNum = 4 as Int!
    let scrollY = 20 as CGFloat!
    let pageCtrlWidth = 200 as CGFloat!
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        initFirstLaunchView()
//        firstLaunchView.hidden = true
//        firstLaunchView.hidden = true
//        indexStackView.hidden = false
        if(NSUserDefaults.standardUserDefaults().boolForKey("isFirstLaunch")as Bool!==false){
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isFirstLaunch")
            initFirstLaunchView()
            firstLaunchView.hidden = false
            indexStackView.hidden = true
        }
//         Do any additional setup after loading the view, typically from a nib.
    }
    func initFirstLaunchView() {
        firstLaunchScrollView = UIScrollView(frame: CGRectMake(0,scrollY,screenWidth,screenHeight-scrollY))
        firstLaunchScrollView.delegate = self
        firstLaunchScrollView.pagingEnabled = true
        firstLaunchScrollView.contentSize = CGSizeMake(screenWidth*CGFloat(imgNum), screenHeight-scrollY)
        
        
        firstLaunchPageCtrl = UIPageControl(frame: CGRectMake((screenWidth-pageCtrlWidth)/2,screenHeight-scrollY,screenWidth,scrollY))
        firstLaunchPageCtrl.numberOfPages = imgNum
        firstLaunchPageCtrl.currentPageIndicatorTintColor = UIColor.blueColor()
        firstLaunchPageCtrl.pageIndicatorTintColor = UIColor.brownColor()
        
        exitFirstLaunchButton = UIButton(frame: CGRectMake(screenWidth*(CGFloat(imgNum)-0.5)-100,screenHeight-50,200,20))
        exitFirstLaunchButton.backgroundColor = UIColor.grayColor()
        exitFirstLaunchButton.setTitle("back", forState: UIControlState.Normal)
        exitFirstLaunchButton.addTarget(self, action: #selector(btnclick), forControlEvents: .TouchUpInside)
        for index in 1...imgNum{
            var imgNo = "I0\(index)"
            var imgFirstLaunchImageView = UIImageView(frame: CGRectMake(screenWidth*CGFloat(index-1),scrollY,screenWidth,screenHeight-scrollY))
            imgFirstLaunchImageView.image = UIImage(named: imgNo)
            firstLaunchScrollView.addSubview(imgFirstLaunchImageView)
        }
        firstLaunchScrollView.addSubview(exitFirstLaunchButton)
        firstLaunchView.addSubview(firstLaunchScrollView)
        firstLaunchView.insertSubview(firstLaunchPageCtrl, aboveSubview: firstLaunchScrollView)
    }
    func btnclick(){
        firstLaunchView.hidden = true
        indexStackView.hidden = false
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var currentPage = NSInteger(firstLaunchScrollView.contentOffset.x / screenWidth + 0.5)
        firstLaunchPageCtrl.currentPage = currentPage
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
