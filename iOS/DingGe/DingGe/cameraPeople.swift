//
//  cameraPeople.swift
//  DingGe
//
//  Created by 王浩强 on 16/3/15.
//  Copyright © 2016年 王浩强. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AssetsLibrary
import CoreMotion
var Score = 0.0
class cameraPeople: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate{
    @IBOutlet weak var cameraScoreLabel: UILabel!//打分类 显示分数
    @IBOutlet weak var cameraUIView: UIImageView!//显示图片
//    @IBOutlet var filterButtonContainer: UIView!// 滤镜容器
    @IBOutlet var cameraBackButton: UIButton!//返回按钮
    @IBOutlet var cameraRecordsButton: UIButton!//拍照按钮
//    @IBOutlet var cameraProgressView: UIProgressView!//打分进度条(暂时不用）
    @IBOutlet var cameraFilterButton: UIButton!//滤镜按钮
    @IBOutlet var cameraScorebar: UIView!
    var cameraCaptureSession:AVCaptureSession!//拍照序列
    var isFilterOpen = false;
    var cv = opencv()//cv类
    var filter:CIFilter!
    lazy var cameraCIContext: CIContext = {
        let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        let options = [kCIContextWorkingColorSpace : NSNull()]
        return CIContext(EAGLContext: eaglContext, options: options)
    }()//拍照用的
    lazy var filterNames: [String] = {
        return ["CIColorInvert","CIPhotoEffectMono","CIPhotoEffectInstant","CIPhotoEffectTransfer"]
    }()//滤镜库
    var cameraCIImage:CIImage!//拍照用的
    var counter = 0;
    var timer:NSTimer!
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    //加速度传感器
    var cmm:CMMotionManager!
    var accelerationX:CGFloat!
    var accelerationY:CGFloat!
    var accelerationZ:CGFloat!
    
    //图片存储单例类
    var CPhoto:cameraPhoto!
    override func viewDidLoad() {//界面加载完成时调用
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupCaptureSession()
        openCamera()
        cv.load_file()//加载评分文件
        timer = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: Selector("updateCounter"), userInfo:nil, repeats:true);
        //计时器，需要再看
        cmm = CMMotionManager()
        CPhoto=cameraPhoto()
//        filterButtonContainer.hidden = true
//        cameraProgressView.progress = 0.5(横向进度条暂停使用）
    }
    
    override func viewWillAppear(animated: Bool) {
        cmm.accelerometerUpdateInterval = 2
        let _:CMAccelerometerData!
        let _:NSError!
        if cmm.accelerometerAvailable{
            cmm.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: {accelerometerData,error in
                let acceleration = accelerometerData!.acceleration
                self.accelerationX = CGFloat(acceleration.x)
                self.accelerationY = CGFloat(acceleration.y)
                self.accelerationZ = CGFloat(acceleration.z)
//                print("x:\(self.accelerationX) ")
//                print("y:\(self.accelerationY) ")
//                print("z:\(self.accelerationZ) ")
            })
        }
        else{
            print("un")
        }
        filter=CIFilter(name: "CIPhotoEffectTransfer")
    }
    override func viewWillDisappear(animated: Bool) {
        if cmm.accelerometerActive{
            cmm.stopAccelerometerUpdates()
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(isFilterOpen){
//            filterButtonContainer.hidden=true;
            isFilterOpen=false;
        }
        else{
            let point = touches.first?.locationInView(self.view)
            print(point)
            self.cv.change_selection(point!)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    @IBAction func switchFilters(sender: AnyObject) {
//    }
    @IBAction func openFilters(sender: AnyObject) {
//        filterButtonContainer.hidden=false
        isFilterOpen=true;
    }
    @IBAction func applyFilter(sender: UIButton) {//使用滤镜
        var filterName = filterNames[sender.tag]
        filter = CIFilter(name: filterName)
    }
    func updateCounter(){//更新计时器
        counter += 1
    }
    func setupCaptureSession(){ //初始化相机
        cameraCaptureSession = AVCaptureSession()
        cameraCaptureSession.beginConfiguration()
        
        cameraCaptureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let cameraCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let cameraDeviceInput = try! AVCaptureDeviceInput (device: cameraCaptureDevice)
        if cameraCaptureSession.canAddInput(cameraDeviceInput){
            cameraCaptureSession.addInput(cameraDeviceInput)
        }
        
        
        let cameraDataOutput = AVCaptureVideoDataOutput()
        if cameraCaptureSession.canAddOutput(cameraDataOutput){
            cameraCaptureSession.addOutput(cameraDataOutput)
        }
        cameraDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: Int (kCVPixelFormatType_32BGRA)]//BGRA
        let cameraQueue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL)
        cameraDataOutput.setSampleBufferDelegate(self ,queue: cameraQueue)
        cameraCaptureSession.commitConfiguration()//??????
    }
    func openCamera(){//启动相机
        cameraCaptureSession.startRunning()
    }
    @IBAction func takePicture(sender: UIButton) {//模拟相机动作
        sender.enabled = false
        self.cameraCaptureSession.stopRunning()
        sleep(1)
        CPhoto.saveImage(self.cameraUIView.image!)
        sender.enabled = true
        self.cameraCaptureSession.startRunning()
    }
    func  captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {//视频流监测
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)!
        let rnd=arc4random()%10;
        
        var outputImage = CIImage(CVPixelBuffer: imageBuffer)
        let orientation = UIDevice.currentDevice().orientation
        var t:CGAffineTransform!
        if orientation == UIDeviceOrientation.Portrait{//旋转
            t = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
        }else if orientation == UIDeviceOrientation.PortraitUpsideDown {
            t = CGAffineTransformMakeRotation(CGFloat(M_PI / 2.0))
        } else if (orientation == UIDeviceOrientation.LandscapeRight) {
            t = CGAffineTransformMakeRotation(CGFloat(M_PI))
        } else {
            t = CGAffineTransformMakeRotation(0)
        }
        outputImage = outputImage.imageByApplyingTransform(t);
        
        if filter != nil {
            filter.setValue(outputImage, forKey: kCIInputImageKey)
            outputImage = filter.outputImage!
        }
        
        let cgImage = self.cameraCIContext.createCGImage(outputImage, fromRect: outputImage.extent)
        var uiimage = UIImage(CGImage: cgImage)
        
        self.cameraCIImage = outputImage
        dispatch_sync(dispatch_get_main_queue(), {//并行线程的回收
            Score = self.cv.get_score_after_track(uiimage);
            uiimage = self.cv.track_object(uiimage)
            
            if Score >= 10.0 {
                Score = 40*(Score-20)+Double(rnd);
                self.cameraScoreLabel.text="mid Score: \(Score)"
            }
            else{
                Score *= 30
                Score += Double(rnd);
                //Score += arc4random()%10;
                self.cameraScoreLabel.text="third Score: \(Score)"
                
            }
            if Score >= 99 {
                if arc4random()%20 == 10 {
                    self.CPhoto.saveImage(self.cameraUIView.image!)
                    uiimage = self.cv.full_white(uiimage);
                }
            }
            self.cameraUIView.image = uiimage
            
            /******横向进度条（暂时不用）******/
//            self.cameraProgressView.setProgress(Float(Score/100), animated: true)
//            if Score >= 50{
//                //print(CGFloat(5 * ( 100-Score )))
//                self.cameraProgressView.progressTintColor = UIColor(red: CGFloat(5*(100-Score)/255), green: 1, blue: 0.5, alpha: 1)
//            }
//            else{
//                self.cameraProgressView.progressTintColor = UIColor(red: 1, green: CGFloat((255-5*(50-Score))/255), blue: 0.5, alpha: 1)
//            }
        })
    }
}
