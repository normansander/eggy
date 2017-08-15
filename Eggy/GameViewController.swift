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

    var currentAngle: Float = 0.0
    var top: SCNNode = SCNNode()
    var seconds: Double = 0
    var prevSeconds: Double = 0
    var endDate: Date?
    var timer: Timer?
    var finished: Bool = true
    var soundManager: SoundManager?

    override func viewDidLoad() {
        self.label.font = UIFont(name: "Futura-CondensedMedium", size: 25)

        // Register sounds
        self.soundManager = SoundManager.shared
        self.soundManager?.register("tick", loops: -1)
        self.soundManager?.register("tick2")
        self.soundManager?.register("alarm")

        super.viewDidLoad()

        // 3D setup
        let scene = SCNScene(named: "art.scnassets/egg")!
        let cameraNode = SCNNode()
        //        let lightNode = SCNNode()

        // Cam
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        scene.rootNode.addChildNode(cameraNode)

        // Light
        //        TODO
        //        lightNode.light = SCNLight()
        //        lightNode.position = SCNVector3(x: 0, y: 0, z: 4)
        //        scene.rootNode.addChildNode(lightNode)

        // Define parts of object
        self.top = scene.rootNode.childNode(withName: "Top", recursively: true)!
        scene.rootNode.childNode(withName: "Bottom", recursively: true)

        let scnView = self.skView
        scnView?.scene = scene

        #if DEBUG
            scnView.showsStatistics = true
            Helper.printFonts()
        #endif
        scnView?.backgroundColor = UIColor.white

        // Add gesture recognizer
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.panGesture(_:)))
        scnView?.addGestureRecognizer(panRecognizer)

        self.updateLabel()

        self.button.titleLabel?.font = UIFont(name: "Futura-CondensedMedium", size: 25)
        self.button.setTitle("Start", for: UIControlState())
        self.button.setTitle("Stop", for: UIControlState.selected)
        self.button.layer.cornerRadius = 8.0
        self.button.isEnabled = false
        self.button.layer.borderColor = UIColor.lightGray.cgColor
        self.button.setTitleColor(UIColor.gray, for: UIControlState.disabled)
        self.button.setTitleColor(UIColor.white, for: UIControlState())
        self.button.setTitleColor(UIColor.white, for: UIControlState.selected)
        updateButtonBg()
    }

    func startTimer() {
        if self.seconds == 0 {
            return
        }
        self.button.isSelected = true
        self.endDate = Date().addingTimeInterval(self.seconds)
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameViewController.update), userInfo: nil, repeats: true)
        self.finished = false
        self.soundManager!.play("tick")
        self.updateButtonBg()
    }

    func stopTimer() {
        self.timer?.invalidate()
        self.finished = true
        self.button.isSelected = false
        self.soundManager!.stop("tick")
        self.updateButtonBg()
    }

    func ring() {
        if !self.finished {
            stopTimer()
            self.button.isEnabled = false
            self.soundManager!.play("alarm")
            self.updateButtonBg()
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    func panGesture(_ sender: UIPanGestureRecognizer) {
        self.stopTimer()
        self.updateButtonBg()
        self.button.isEnabled = true
        let translation = sender.translation(in: sender.view!)
        var angle: Float

        if sender.state == UIGestureRecognizerState.changed {
            angle = (Float)(translation.x) * (Float)(Double.pi) / 180.0
            angle += self.currentAngle

            if angle > 0 {
                angle = 0
            }

            self.seconds = 60 * Double(round((-angle * 3600) / ((Float)(Double.pi) * 2) / 60))
            self.updateLabel()
            self.top.rotation = SCNVector4Make(0, 1, 0, angle)

            print(self.seconds)

            if (self.seconds != self.prevSeconds) {
                self.soundManager!.play("tick2")
            }

            self.prevSeconds = self.seconds
        } else if sender.state == UIGestureRecognizerState.ended {
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
        self.seconds = round(self.endDate!.timeIntervalSinceNow)
        print(self.seconds)
        self.setRotation(self.seconds)
        self.updateLabel()

        if self.seconds <= 0 {
            self.seconds = 0
            self.ring()
        }
    }

    func setRotation(_ seconds: Double) {
        let newAngle = (Float(-self.seconds) * (Float)(Double.pi) * 2) / 3600
        self.top.rotation = SCNVector4Make(0, 1, 0, newAngle)
        self.currentAngle = newAngle
    }

    func updateLabel() {
        let seconds: Int = Int(self.seconds.truncatingRemainder(dividingBy: 60))
        let minutes: Int = Int((self.seconds / 60).truncatingRemainder(dividingBy: 60))
        let hours: Int = Int(self.seconds / 3600)

        if(hours > 0) {
            label.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            label.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }

    func updateButtonBg() {
        if !self.button.isEnabled {
            self.button.backgroundColor = UIColor.clear
            self.button.layer.borderWidth = 1.0
            return
        }
        self.button.layer.borderWidth = 0
        if self.finished {
            self.button.backgroundColor = UIColor(red: 70 / 255, green: 178 / 255, blue: 157 / 255, alpha: 1)
        } else {
            self.button.backgroundColor = UIColor(red: 222 / 255, green: 73 / 255, blue: 73 / 255, alpha: 1)
        }
    }

    @IBAction func btnPressed(_ sender: UIButton) {
        self.timer?.invalidate()
        if self.finished {
            self.startTimer()
        } else {
            self.stopTimer()
        }
    }
}
