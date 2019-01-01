//
//  ARViewController.swift
//  MappAR
//
//  Created by Jeremy Raven on 21/09/18.
//  Copyright © 2018 Jeremy Raven. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import SceneKit
import MapboxSceneKit
import CoreLocation


class ARViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var lockedButtonState: UIButton!
    
    private var hud :MBProgressHUD!
    var ARcoordinatesArray: [CLLocationCoordinate2D]? = []
    private var newAngleY :Float = 0.0
    private var currentAngleY :Float = 0.0
    private var localTranslatePosition :CGPoint!
    var minLat: Double! = 0.0000000
    var minLong: Double! = 0.0000000
    var maxLat: Double! = 0.0000000
    var maxLong: Double! = 0.0000000
    let scaleMult: Float = 1.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.sceneView.autoenablesDefaultLighting = true
        
        self.hud = MBProgressHUD.showAdded(to: self.sceneView, animated: true)
        self.hud.label.text = "Detecting Plane..."
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Set locked button image
        let image = UIImage(named: "UnlockedImage")
        lockedButtonState.setImage(image, for: UIControl.State.normal)
        lockedButtonState.isSelected = false
        
        handleCoordinatesArray()
        registerGestureRecognizers()
    }
    
    // Prepare coordinate array for TerrainNode
    private func handleCoordinatesArray() {
        
        if !ARcoordinatesArray!.isEmpty {
            
            minLat = ARcoordinatesArray![0].latitude
            minLong = ARcoordinatesArray![0].longitude

            maxLat = ARcoordinatesArray![1].latitude
            maxLong = ARcoordinatesArray![1].longitude
            
            // Organise min/max values
            if minLat > maxLat {
                let hold = minLat
                minLat = maxLat
                maxLat = hold
            } else { }
            
            if minLong > maxLong {
                let hold = minLong
                minLong = maxLong
                maxLong = hold
            } else { }
        }
    }
    
    // Set state of locked button
    @IBAction func setLockButtonState(_ sender: UIButton) {
        
        if lockedButtonState.isSelected == false {
            let image = UIImage(named: "LockedImage")
            lockedButtonState.setImage(image, for: UIControl.State.selected)
            lockedButtonState.isSelected = true
        }
        
        else if lockedButtonState.isSelected {
            let image = UIImage(named: "UnlockedImage")
            lockedButtonState.setImage(image, for: UIControl.State.normal)
            lockedButtonState.isSelected = false
        }
        
    }
    
    //MARK: Create terrain node
    private func addTerrainNode(from hitResult :ARHitTestResult) {
        
        let terrainNode = TerrainNode(minLat: minLat, maxLat: maxLat, minLon: minLong, maxLon: maxLong)
        terrainNode.name = "terrain"
        let scale = Float(0.333 * hitResult.distance) / terrainNode.boundingSphere.radius
        terrainNode.transform = SCNMatrix4MakeScale(scale, scale * scaleMult, scale)
        terrainNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        // set the material
        terrainNode.geometry?.materials = defaultMaterials()
        
        // Remove any existing terrain node and add another one to the scene
        self.sceneView.scene.rootNode.childNodes.filter({ $0.name == "terrain" }).forEach({ $0.removeFromParentNode() })
        self.sceneView.scene.rootNode.addChildNode(terrainNode)
        
        // Fetch terrain height and texture
        terrainNode.fetchTerrainAndTexture(minWallHeight: 50.0,
                                    enableDynamicShadows: true,
                                            textureStyle: "mapbox/satellite-v9",
                                          heightProgress: nil,
                                        heightCompletion: { fetchError in
                                                if let fetchError = fetchError { NSLog("Terrain load failed: \(fetchError.localizedDescription)")
                                                } else {
                                                    NSLog("Terrain load complete")
                                                }
                                            },
                                        textureProgress: nil) { image, fetchError in
                                                if let fetchError = fetchError {
                                                    NSLog("Texture load failed: \(fetchError.localizedDescription)")}
                                                if image != nil {
                                                    NSLog("Texture load complete")
                                                    
                                                    // Add texture to node diffuse
                                                    terrainNode.geometry?.materials[4].diffuse.contents = image
                                                }
                                            }
        
    }
    
    // Base Material for terrain
    private func defaultMaterials() -> [SCNMaterial] {
        let groundImage = SCNMaterial()
        groundImage.diffuse.contents = UIColor.darkGray
        groundImage.name = "Ground texture"
        
        let sideMaterial = SCNMaterial()
        sideMaterial.diffuse.contents = UIColor.darkGray
        //TODO: Some kind of bug with the normals for sides where not having them double-sided has them not show up
        sideMaterial.isDoubleSided = true
        sideMaterial.name = "Side"
        
        let bottomMaterial = SCNMaterial()
        bottomMaterial.diffuse.contents = UIColor.black
        bottomMaterial.name = "Bottom"
        
        return [sideMaterial, sideMaterial, sideMaterial, sideMaterial, groundImage, bottomMaterial]
    }
    
    //MARK: Gestures
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned))
        self.sceneView.addGestureRecognizer(panGestureRecognizer)

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector
            (longPressed))
         self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
        
    }
    
    // Long Pressed - Drag node
    @objc func longPressed(recognizer :UILongPressGestureRecognizer) {
        
        if lockedButtonState.isSelected == false {
            guard let sceneView = recognizer.view as? ARSCNView else { return }
            let touch = recognizer.location(in: sceneView)
            let hitTestResults = self.sceneView.hitTest(touch, options: nil)

            if let hitTest = hitTestResults.first {
                let terrainNode = hitTest.node

                if recognizer.state == .began {
                        localTranslatePosition = touch
                    
                } else if recognizer.state == .changed {

                            let deltaX = Float(touch.x - self.localTranslatePosition.x)/700
                            let deltaY = Float(touch.y - self.localTranslatePosition.y)/700

                            terrainNode.localTranslate(by: SCNVector3(deltaX,0.0,deltaY))
                            self.localTranslatePosition = touch

                }

            }
            
        }

    }
    
    // Panned gesture - Rotate node
    @objc func panned(recognizer :UIPanGestureRecognizer) {

        if lockedButtonState.isSelected == false {
            if recognizer.state == .changed {

                guard let sceneView = recognizer.view as? ARSCNView else {
                    return
                }

                let touch = recognizer.location(in: sceneView)
                let translation = recognizer.translation(in: sceneView)
                let hitTestResults = self.sceneView.hitTest(touch, options: nil)

                if let hitTest = hitTestResults.first {

                    let terrainNode = hitTest.node
                    self.newAngleY = Float(translation.x) * (Float) (Double.pi)/180
                    self.newAngleY += self.currentAngleY
                    terrainNode.eulerAngles.y = self.newAngleY

                }

            } else if recognizer.state == .ended {
                self.currentAngleY = self.newAngleY
            }
        }
    }

    // Pinched gesture - Scale node
    @objc func pinched(recognizer :UIPinchGestureRecognizer) {
        
        if lockedButtonState.isSelected == false {
            if recognizer.state == .changed {
                
                guard let sceneView = recognizer.view as? ARSCNView else {
                    return
                }
                
                let touch = recognizer.location(in: sceneView)
                let hitTestResults = self.sceneView.hitTest(touch, options: nil)
                
                if let hitTest = hitTestResults.first {
                    
                    let terrainNode = hitTest.node
                    let pinchScaleX = Float(recognizer.scale) * terrainNode.scale.x
                    let pinchScaleY = Float(recognizer.scale) * terrainNode.scale.y
                    let pinchScaleZ = Float(recognizer.scale) * terrainNode.scale.z
                    terrainNode.scale = SCNVector3(pinchScaleX,pinchScaleY,pinchScaleZ)
                    
                    recognizer.scale = 1
                    
                }
            }
        }
    }
    
    // Tapped gesture - Add node
    @objc func tapped(recognizer :UIGestureRecognizer) {
        
        if lockedButtonState.isSelected == false {
            let sceneView = recognizer.view as! ARSCNView
            let touch = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(touch, types: .existingPlane)
        
            if !hitTestResults.isEmpty {
                
                let hitTestResult = hitTestResults.first!
                addTerrainNode(from: hitTestResult)
            }
        }
    }
    
    //MARK: HUD progress handler
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor is ARPlaneAnchor {
            
            DispatchQueue.main.async {
                
                self.hud.label.text = "Plane Detected"
                self.hud.hide(animated: true, afterDelay: 1.0)
            }
        }
        
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
//
//
//    }
    
    //MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Check View Controller desination
        if segue.destination is TableViewController {
            
            let vcTV = segue.destination as? TableViewController
            if !ARcoordinatesArray!.isEmpty {
                vcTV?.favCoordinatesArray = ARcoordinatesArray!
            } else {return}
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
}
