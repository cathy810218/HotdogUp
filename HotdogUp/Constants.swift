//
//  Constants.swift
//  HotdogUp
//
//  Created by Cathy Oun on 7/31/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import UIKit
import SpriteKit

let kMinJumpHeight: Int = Int(UIScreen.main.bounds.size.height / 5.0)
let kMaxJumpHeight: Int = 180
let kJumpIntensity: Int = 30
let kHotdogMoveVelocityIncrement: CGFloat = 6.0
var kNumOfStairsToUpdate: Int = 4 // multiply by 5 = stairs when update

let kGameSpeed: CGFloat = 1.3
let kSpeedIncrement: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 0.08 : 0.11
let kLevel: Int = 10

// UI constants
let kScoreFontName = "MarkerFelt-Wide"
let kScoreFontSize: CGFloat = 50.0
let kScoreTopOffset: CGFloat = 60.0

// Path/layout tuning
let kPathGapMultiplier: CGFloat = 1.65
let kPathMaxAttempts = 10
let kPathYIncrement: Int = 30

// Hotdog physics defaults
let kHotdogDefaultMass: CGFloat = 0.18
let kHotdogPadMass: CGFloat = 0.23
