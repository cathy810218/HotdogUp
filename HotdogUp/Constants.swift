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
let kMaxJumpHeight: Int = 260  // increased to support 2x charged jump tier
let kJumpIntensity: Int = 30
let kHotdogMoveVelocityIncrement: CGFloat = 6.0
var kNumOfStairsToUpdate: Int = 2 // lowered: ketchup appears after ~10 platforms instead of ~20

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
let kPathYIncrement: Int = 50  // increased: platforms spaced further apart, requiring charged jumps

// Hotdog physics defaults
let kHotdogDefaultMass: CGFloat = 0.18
let kHotdogPadMass: CGFloat = 0.23
// Charged jump tiers — hold duration thresholds (seconds)
let kJumpTier1Threshold: TimeInterval = 0.0    // quick tap (<0.3s): 1x jump
let kJumpTier2Threshold: TimeInterval = 0.3    // medium hold (0.3-0.6s): 1.2x jump
let kJumpTier3Threshold: TimeInterval = 0.6    // long hold (0.6s–1.0s): 1.5x jump
let kJumpTier1Multiplier: CGFloat = 1.0
let kJumpTier2Multiplier: CGFloat = 1.2
let kJumpTier3Multiplier: CGFloat = 1.5
let kMaxChargeDuration: TimeInterval = 1.0

// Reward system
let kRewardInterval: Int = 10  // every N platforms landed, award an accessory

