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
import WatchConnectivity

var Score = 0.0
var uiimage2:UIImage!
class cameraPeople: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate, WCSessionDelegate{
    @IBOutlet weak var cameraScoreLabel: UILabel!//打分类 显示分数
    @IBOutlet weak var cameraUIView: UIImageView!//显示图片
    @IBOutlet var filterButtonContainer: UIView!// 滤镜容器
    @IBOutlet var cameraBackButton: UIButton!//返回按钮
    @IBOutlet var cameraRecordsButton: UIButton!//拍照按钮
    @IBOutlet var cameraProgressView: UIProgressView!//打分进度条(暂时不用）
    @IBOutlet var autoTakePhotoButton: UIButton!
    @IBOutlet var cameraFilterButton: UIButton!//滤镜按钮
    var cameraCaptureDevice:AVCaptureDevice!
    var cameraCaptureSession:AVCaptureSession!//拍照序列
    var isFilterOpen = false;
    var photoScore = 0 as Int
    var countframe = 0 as Int
    var cv = opencv()//cv类
    var filter:CIFilter!
    lazy var cameraCIContext: CIContext = {
        let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        let options = [kCIContextWorkingColorSpace : NSNull()]
        return CIContext(EAGLContext: eaglContext, options: options)
    }()//拍照用的
    lazy var filterNames: [String] = {
        return ["CIMedianFilter","CIPhotoEffectChrome","CIPhotoEffectInstant","CIPhotoEffectTransfer","CINoiseReduction","CIColorControls","CITemperatureAndTint","CIColorCrossPolynomial","CIColorCubeWithColorSpace"]
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
    private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    private var validSession: WCSession? {
        
        // paired - the user has to have their device paired to the watch
        // watchAppInstalled - the user must have your watch app installed
        
        // Note: if the device is paired, but your watch app is not installed
        // consider prompting the user to install it for a better experience
        
        if let session = session where session.paired && session.watchAppInstalled {
            return session
        }
        return nil
    }
    //图片存储单例类
    var CPhoto:cameraPhoto!
    override func viewDidLoad() {//界面加载完成时调用
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupCaptureSession()
        openCamera()
        cv.load_file()//加载评分文件

        cmm = CMMotionManager()
        CPhoto=cameraPhoto()
        filterButtonContainer.hidden = true
//        cameraProgressView.progress = 0.5(横向进度条暂停使用）
        cameraProgressView.transform = CGAffineTransformRotate(cameraProgressView.transform, CGFloat(-M_PI_2))
        cameraProgressView.transform = CGAffineTransformScale(cameraProgressView.transform, CGFloat(1),CGFloat(2))
//        if WCSession.isSupported(){
//            session = WCSession.defaultSession()
//            if  session.watchAppInstalled == true{
//                NSLog("wAppisInstalled")
//                session.delegate = self
//                session.activateSession()
//            }
//            let asession = session where session.paired && session.watchAppInstalled
//        }
        startSession()
        if(NSUserDefaults.standardUserDefaults().boolForKey("AutoTakePicture") as Bool == false){
            autoTakePhotoButton.setTitle("手动", forState: UIControlState.Normal)
        }
        else{
            autoTakePhotoButton.setTitle("自动", forState: UIControlState.Normal)
        }
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
    //开启watch功能
    func startSession() {
        session?.delegate = self
        session?.activateSession()
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(isFilterOpen){
            filterButtonContainer.hidden=true;
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
        filterButtonContainer.hidden=false
        isFilterOpen=true;
    }
    @IBAction func applyFilter(sender: UIButton) {//使用滤镜
        var filterName = filterNames[sender.tag]
        filter = CIFilter(name: filterName)
    }

    func setupCaptureSession(){ //初始化相机
        cameraCaptureSession = AVCaptureSession()
        cameraCaptureSession.beginConfiguration()
        
        cameraCaptureSession.sessionPreset = AVCaptureSessionPresetHigh
//        cameraCaptureSession.sessionPreset = AVCaptureSessionPreset3840x2160//慎用！！
        
        cameraCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
//        let cameraCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVCaptureSessionPresetPhoto)
        let cameraDeviceInput = try! AVCaptureDeviceInput (device: cameraCaptureDevice)
        cameraCaptureSession.removeInput(cameraDeviceInput)
        if cameraCaptureSession.canAddInput(cameraDeviceInput){
            cameraCaptureSession.addInput(cameraDeviceInput)
        }
        
        
        let cameraDataOutput = AVCaptureVideoDataOutput()
        cameraCaptureSession.removeOutput(cameraDataOutput)
        if cameraCaptureSession.canAddOutput(cameraDataOutput){
            cameraCaptureSession.addOutput(cameraDataOutput)
        }
        cameraDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: Int (kCVPixelFormatType_32BGRA)]//BGRA
        let cameraQueue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL)
        cameraDataOutput.setSampleBufferDelegate(self ,queue: cameraQueue)
        cameraCaptureSession.commitConfiguration()//??????
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.cameraCaptureSession.stopRunning()
    }
    
    func openCamera(){//启动相机
        cameraCaptureSession.startRunning()
    }
    func cameraWithPosition(postion:AVCaptureDevicePosition) -> AVCaptureDevice{
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices{
            let device = device as! AVCaptureDevice
            if device.position == AVCaptureDevicePosition.Front{
                return device
            }
        }
//        return nil
        let a:AVCaptureDevice!
        a = AVCaptureDevice()
        return a
    }
    
    @IBAction func SwitchLens(sender: AnyObject) {//切换镜头
        print(0)
//        var devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
////        var tmpDevice:AVCaptureDevice
//        for device in devices{
//            let device = device as! AVCaptureDevice
//            if device.position == AVCaptureDevicePosition.Front{
//                cameraCaptureDevice = device
//                break;
//            }
//        }
        var inputs = self.cameraCaptureSession.inputs as NSArray!
        for input in inputs{
            let input = input as! AVCaptureDeviceInput
            let device = input.device
            if(device.hasMediaType(AVMediaTypeVideo)){
                var position = self.cameraCaptureDevice.position;
                var newCamera:AVCaptureDevice
                var newInput:AVCaptureDeviceInput
                if(position == AVCaptureDevicePosition.Front){
                    newCamera = cameraWithPosition(AVCaptureDevicePosition.Back)
                }
                else{
                    newCamera = cameraWithPosition(AVCaptureDevicePosition.Front)
                }
                newInput = try! AVCaptureDeviceInput(device: newCamera)
                self.cameraCaptureSession.beginConfiguration()
                cameraCaptureSession.removeInput(input)
                cameraCaptureSession.addInput(newInput)
                cameraCaptureSession.commitConfiguration()
                break;
            }
        }
    }
    
        /*
         - (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
         {
         NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
         for ( AVCaptureDevice *device in devices )
         if ( device.position == position )
         return device;
         return nil;
         }
 
 if (position == AVCaptureDevicePositionFront)
 newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
 else
 newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
 newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
 
 // beginConfiguration ensures that pending changes are not applied immediately
 [self.session beginConfiguration];
 
 [self.session removeInput:input];
 [self.session addInput:newInput];
 
 // Changes take effect once the outermost commitConfiguration is invoked.
 [self.session commitConfiguration];
 break;
 */
    @IBAction func takePicture(sender: UIButton) {//模拟相机动作
        sender.enabled = false
        self.cameraCaptureSession.stopRunning()
        sleep(1)
        CPhoto.saveImage(self.cameraUIView.image!)
        sender.enabled = true
        self.cameraCaptureSession.startRunning()
    }
    func takePicture(){
        self.cameraCaptureSession.stopRunning()
        sleep(1)
        CPhoto.saveImage(self.cameraUIView.image!)
        self.cameraCaptureSession.startRunning()
    }

    @IBAction func switchAutoTakePicture(sender: AnyObject) {
        print(sender.currentTitle as String?!)
        if sender.currentTitle as String?! == "自动"{
            sender.setTitle("手动", forState: UIControlState.Normal)
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "AutoTakePicture")
        }
        else{
            sender.setTitle("自动", forState: UIControlState.Normal)
            NSUserDefaults.standardUserDefaults().setBool(true,forKey: "AutoTakePicture")
        }
    }
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {//视频流监测
        self.countframe = self.countframe + 1
        if self.countframe > 30000 {self.countframe = 1}
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)!
        let rnd=arc4random()%10;
        
        var tmp_score = 0.0,tmp_score2 = 0.0
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
        uiimage2 = UIImage(CGImage: cgImage)
        var uiimage:UIImage!
        
        self.cameraCIImage = outputImage
        uiimage = uiimage2
        //uiimage2 = uiimage
        uiimage2 = self.cv.track_object(uiimage)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),{
            dispatch_async(dispatch_get_main_queue(),{
                self.cameraUIView.image = uiimage2
                
            })
            if self.cv.If_track() && (self.countframe % 20 == 0){
                Score = self.cv.get_score_after_track(uiimage2);
                //self.cameraUIView.image = uiimage
                
            }
            dispatch_async(dispatch_get_main_queue(), {//并行线程的回收
                if Score >= 20.0 {
                    tmp_score = 100*log10(10*(Score-20)+1);
                    tmp_score = floor(tmp_score)
                    tmp_score2 = floor(tmp_score/5)*5
//                    if self.session.watchAppInstalled == true{
//                        try! self.session.updateApplicationContext(["Score":tmp_score2]);
//                    }

                    self.cameraScoreLabel.text="对称: \(tmp_score2)"
                }
                else if Score == 0.0{
                    self.cameraScoreLabel.text="Score:"
                }
                else{
                    tmp_score = 100*log10(10*Score+1);
                    //tmp_score = 100*(Score);
                    tmp_score = floor(tmp_score)
                    tmp_score2 = floor(tmp_score/5)*5
//                    if self.session.watchAppInstalled == true{
//                        try! self.session!.updateApplicationContext(["Score":tmp_score2]);
//                    }

                    self.cameraScoreLabel.text="三分线: \(tmp_score2)"
                    
                }
                if(NSUserDefaults.standardUserDefaults().boolForKey("AutoTakePicture") as Bool == true) && tmp_score >= 90{
                   if arc4random()%20 == 10 {
                        self.CPhoto.saveImage(self.cameraUIView.image!)
                        uiimage2 = self.cv.full_white(uiimage);
                    }
                }
                
                /******横向进度条变竖******/
                self.cameraProgressView.setProgress(Float(tmp_score/100), animated: true)
                if tmp_score >= 50{
                    //print(CGFloat(5 * ( 100-Score )))
                    self.cameraProgressView.progressTintColor = UIColor(red: CGFloat(((232-23)/50*(100-tmp_score)+23)/255), green: CGFloat(((184-161)/50*(100-tmp_score)+161)/255), blue: CGFloat(((99-154)/50*(100-tmp_score)+154)/255), alpha: 1)
                }
                else{
                    self.cameraProgressView.progressTintColor = UIColor(red: CGFloat(((224-232)/50*(50-tmp_score)+232)/255), green: CGFloat(((90-184)/50*(50-tmp_score)+184)/255), blue: CGFloat(((109-99)/50*(50-tmp_score)+99)/255), alpha: 1)
                }
                
            })
        })
        
    }
    
}
//extension cameraPeople{
//    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
//        cameraScoreLabel.text = "success"
//        var takePhoto = applicationContext["a"] as! Bool
//        if takePhoto {
//            takePicture()
//        }
//    }
////    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
////        cameraScoreLabel.text = "success"
////    }
//}