//
//  GameViewController.swift
//  Eggy
//
//  Created by Norman Sander on 16.05.15.
//  Copyright (c) 2015 Norman Sander. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit


class GameViewController: UIViewController {

    @IBOutlet weak var skView: SCNView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    var currentAngle: Float = 0.0
    var top: SCNNode = SCNNode()
    var seconds: Double = 0
    var prevSeconds: Double = 0
    var endDate: NSDate?
    var timer: NSTimer?
    var finished: Bool = true
    var soundManager: SoundManager?
    
    override func viewDidLoad() {
        // Register sounds
        self.soundManager = SoundManager.sharedInstance
        self.soundManager?.register("tick", loops: -1)
//        self.soundManager?.register("tick2")
//        self.soundManager?.register("alarm")
        
        super.viewDidLoad()
        let scene = SCNScene(named: "art.scnassets/egg")!
        let cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        self.top = scene.rootNode.childNodeWithName("Top", recursively: true)!
        let bottom = scene.rootNode.childNodeWithName("Bottom", recursively: true)!
        
        let scnView = self.skView
        scnView.scene = scene
        
#if DEBUG
        scnView.showsStatistics = true
#endif
        scnView.backgroundColor = UIColor.whiteColor()
        
        // Add gesture recognizer
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "panGesture:")
        scnView.addGestureRecognizer(panRecognizer)
        
        self.updateLabel()
        self.button.setTitle("Start", forState: UIControlState.Normal)
        self.button.setTitle("Stop", forState: UIControlState.Selected)
        self.button.layer.cornerRadius = 8.0
        self.button.enabled = false
        self.button.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
        self.button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        updateButtonBg()
    }
    
    func startTimer() {
        if self.seconds == 0 {
            return
        }
        self.button.selected = true
        self.endDate = NSDate().dateByAddingTimeInterval(self.seconds)
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        self.finished = false
        self.soundManager!.play("tick")
        self.updateButtonBg()
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.finished = true
        self.button.selected = false
        self.soundManager!.stop("tick")
        self.updateButtonBg()
    }
    
    func ring() {
        stopTimer()
        self.button.enabled = false
        self.soundManager!.play("alarm")
        self.updateButtonBg()
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func panGesture(sender: UIPanGestureRecognizer) {
        self.stopTimer()
        self.updateButtonBg()
        self.button.enabled = true
        let translation = sender.translationInView(sender.view!)
        var angle: Float
        
        if sender.state == UIGestureRecognizerState.Changed {
            angle = (Float)(translation.x)*(Float)(M_PI)/180.0
            angle += self.currentAngle
            
            if angle > 0 {
                angle = 0
            }
            self.seconds = 60 * Double(round((-angle * 3600)/((Float)(M_PI)*2) / 60))
            self.updateLabel()
            self.top.rotation =  SCNVector4Make(0, 1, 0, angle)
            if self.seconds != self.seconds {
                self.soundManager!.play("tick2")
            }
            self.prevSeconds = self.seconds
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            if !self.finished && self.seconds > 0 {
                self.startTimer()
            }
            if seconds == 0 {
                self.ring()
            }
            self.setRotation(self.seconds)
        }
    }
    
    func update() {
        self.seconds = self.endDate!.timeIntervalSinceNow
        println(self.seconds)
        self.setRotation(self.seconds)
        self.updateLabel()
        
        if self.seconds <= 0 {
            self.seconds = 0
            self.ring()
        }
    }
    
    func setRotation(seconds: Double) {
        let newAngle = (Float(-self.seconds)*(Float)(M_PI)*2)/3600
        self.top.rotation =  SCNVector4Make(0, 1, 0, newAngle)
        self.currentAngle = newAngle
    }
    
    func updateLabel() {
        let seconds: Int = Int(self.seconds % 60)
        let minutes: Int = Int((self.seconds / 60) % 60)
        let hours: Int = Int(self.seconds / 3600)
        
        if(hours > 0){
            label.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        else{
            label.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func updateButtonBg() {
        if !self.button.enabled {
            self.button.backgroundColor =  UIColor.clearColor()
            self.button.layer.borderWidth = 1.0
            return
        }
        self.button.layer.borderWidth = 0
        if self.finished {
            self.button.backgroundColor =  UIColor(red: 70/255, green: 178/255, blue: 157/255, alpha: 1)
        }
        else {
            self.button.backgroundColor =  UIColor(red: 222/255, green: 73/255, blue: 73/255, alpha: 1)
        }
    }
    
    @IBAction func btnPressed(sender: UIButton) {
        self.timer?.invalidate()
        if self.finished {
            self.startTimer()
        }
        else {
            self.stopTimer()
        }
    }
}
