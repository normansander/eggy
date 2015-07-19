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

    var currentAngle: Float = 0.0
    var top: SCNNode = SCNNode()
    var seconds: Double = 0
    var label: UILabel = UILabel(frame: CGRectMake(0, 0, 200, 21))
    var endDate: NSDate?
    var timer: NSTimer?
    var finished: Bool = true
    var button: UIButton = UIButton(frame: CGRectMake(0, 0, 200, 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = SCNScene(named: "art.scnassets/egg")!
        let cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        self.top = scene.rootNode.childNodeWithName("Top", recursively: true)!
        let bottom = scene.rootNode.childNodeWithName("Bottom", recursively: true)!
        
        let scnView = self.view as! SCNView
        scnView.scene = scene
        
#if DEBUG
        scnView.showsStatistics = true
#endif
        scnView.backgroundColor = UIColor.whiteColor()
        
        // add gesture recognizer
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "panGesture:")
        scnView.addGestureRecognizer(panRecognizer)
        
        // add label
        label.center = CGPointMake(self.view.frame.width/2, 30)
        label.textAlignment = NSTextAlignment.Center
        label.text = "0"
        self.view.addSubview(label)
        
        // add button
        self.button.center = CGPointMake(self.view.frame.width/2, self.view.frame.height-60)
        self.button.setTitle("Start", forState: UIControlState.Normal)
        self.button.setTitle("Stop", forState: UIControlState.Selected)
        self.button.layer.backgroundColor = UIColor.greenColor().CGColor
        self.button.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    func startTimer() {
        if self.seconds == 0 {
            return
        }
        self.finished = false
        self.endDate = NSDate().dateByAddingTimeInterval(self.seconds)
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.finished = true
        self.timer?.invalidate()
    }
    
    func buttonPressed(sender: UIButton!) {
        self.timer?.invalidate()
        if self.finished {
            self.startTimer()
        }
        else {
            self.stopTimer()
        }
        sender.selected = !self.finished
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
        self.timer?.invalidate()
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
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            if !self.finished && self.seconds > 0 {
                self.startTimer()
            }
            self.setRotation(self.seconds)
        }
    }
    
    func update() {
        self.seconds = self.endDate!.timeIntervalSinceNow
        self.setRotation(self.seconds)
        self.updateLabel()
        
        if self.seconds == 0 {
            self.timer?.invalidate()
            self.finished = true
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
}
