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
let kMaxJumpHeight: Int = 200  // increased to support 2x charged jump tier
let kHotdogMoveVelocityIncrement: CGFloat = 6.0
var kNumOfStairsToUpdate: Int = 2 // sauce stations appear after ~15 platforms

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

// Vertical gap between platforms (randomized per platform)
// Close: reachable with 1x tap jump (most common)
// Medium: requires ~1.5x charged jump
// Far: requires ~2x charged jump (rare)
let kPathYGapClose: Int = 30       // 1x tap: kMinJumpHeight + 30
let kPathYGapMedium: Int = 50      // 1.5x charge: kMinJumpHeight + 50
let kPathYGapFar: Int = 80         // 2x charge: kMinJumpHeight + 80

// Hotdog physics defaults
let kHotdogDefaultMass: CGFloat = 0.3
let kHotdogPadMass: CGFloat = 0.23
// Charged jump tiers — hold duration thresholds (seconds)
let kJumpTier1Threshold: TimeInterval = 0.0    // quick tap (<0.3s): 1x jump
let kJumpTier2Threshold: TimeInterval = 0.25    // medium hold (0.25s): 1.5x jump
let kJumpTier3Threshold: TimeInterval = 0.6    // long hold (0.6s–1.0s): 2x jump
let kJumpTier1Multiplier: CGFloat = 1.4
let kJumpTier2Multiplier: CGFloat = 1.6
let kJumpTier3Multiplier: CGFloat = 1.8
let kMaxChargeDuration: TimeInterval = 1.0

// Reward system
let kRewardInterval: Int = 10  // every N platforms landed, award an accessory

// Sauce hit effect
let kSauceMassIncrease: CGFloat = 0.01   // extra mass per sauce hit
let kSauceEffectDuration: TimeInterval = 2.0  // seconds before effect wears off

