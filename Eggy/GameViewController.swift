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
    var _seconds: Int = 0
    var label: UILabel = UILabel(frame: CGRectMake(0, 0, 200, 21));
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/egg")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        
        // retrieve the egg node
        top = scene.rootNode.childNodeWithName("Top", recursively: true)!
        let bottom = scene.rootNode.childNodeWithName("Bottom", recursively: true)!
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // scnView.showsStatistics = true
        
        // configure the view
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
        let button: UIButton = UIButton(frame: CGRectMake(0, 0, 200, 40))
        button.center = CGPointMake(self.view.frame.width/2, self.view.frame.height-60)
        button.setTitle("Start", forState: UIControlState.Normal)
        button.layer.backgroundColor = UIColor.greenColor().CGColor
        button.addTarget(self, action: "startPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
        
    }
    
    func startPressed(sender: UIButton!) {
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
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
        let translation = sender.translationInView(sender.view!)
        var newAngle: Float
        
        if(sender.state == UIGestureRecognizerState.Changed) {
            newAngle = (Float)(translation.x)*(Float)(M_PI)/180.0
            newAngle += currentAngle
            
            if (newAngle > 0) {
                newAngle = 0
            }
            
            _seconds = 60 * Int(round((-newAngle * 3600)/((Float)(M_PI)*2) / 60))
            
            self.updateLabel()
            
            top.rotation =  SCNVector4Make(0, 1, 0, newAngle)
        } else if(sender.state == UIGestureRecognizerState.Ended) {

            newAngle = (Float(-_seconds)*(Float)(M_PI)*2)/3600
            
            top.rotation =  SCNVector4Make(0, 1, 0, newAngle)
            
//            let velocity = sender.velocityInView(sender.view!)
            
            
//            if(newAngle > 0){
//                newAngle = 0
//               top.runAction(SCNAction.rotateToX(0, y: 0, z: 0, duration: 0.3))
//            }
            
            currentAngle = newAngle
        }
    }
    
    func update() {
        _seconds--
        
    }
    
    func updateLabel() {
        
        let seconds: Int = _seconds % 60;
        let minutes: Int = (_seconds / 60) % 60;
        let hours: Int = _seconds / 3600;
        
        if(hours > 0){
            label.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        else{
            label.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
