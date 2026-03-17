# HotdogUp

A fast-paced vertical platformer built with SpriteKit and UIKit for iOS. Guide a hotdog character upward through an endless series of platforms, dodge sauce attacks, and compete for the highest score.

## Architecture

The project follows **MVVM** with a **Coordinator** pattern and **Dependency Injection** via a singleton container.

```
App Layer          SceneDelegate → AppCoordinator → MenuViewController
                                                   ↓ (modal present)
Game Feature       GameCoordinator → GameViewController ← GameViewModel
                                     ↓
                                     GameScene (SpriteKit)
```

### Key Layers

| Layer | Responsibility | Examples |
|-------|---------------|----------|
| **App** | Lifecycle, window, navigation | `SceneDelegate`, `AppCoordinator`, `AppDelegate` |
| **Core** | Protocol abstractions & DI | `Container`, `Persistence`, `Ads`, `IAP`, `Analytics` |
| **Features** | Screen-level logic | `GameViewModel`, `GameViewController`, `StoreViewController` |
| **Controller** | SpriteKit scene & game loop | `GameScene`, `MusicPlayer`, `Constants` |
| **Model** | Game entities & data | `Hotdog`, `Path`, `Station`, `Sauce`, `GameSettings` |
| **View** | UIKit views & overlays | `PauseView`, `GameoverView`, `TutorialView`, `InterstitialAdView` |

### Design Patterns

- **MVVM** — `GameViewModel` owns game state (`PlayState` enum: `.idle`, `.playing`, `.paused`, `.gameOver`), score persistence, and IAP logic. Views bind via closable callbacks (`onPlayStateChanged`, `onScoreChanged`, `onShowAd`, etc.). No Combine dependency.
- **Coordinator** — `AppCoordinator` owns the `UIWindow` and loads the menu from `Main.storyboard`. `GameCoordinator` creates and injects the `GameViewModel` into `GameViewController`.
- **Dependency Injection** — `Container` (singleton) resolves all services: `Analytics`, `Ads`, `IAP`, `Persistence`, and `GameSettings`. All dependencies are protocol-based for testability.
- **Delegate Pattern** — `GameSceneDelegate` bridges SpriteKit → UIKit. `PauseViewDelegate`, `GameoverViewDelegate`, and `InterstitialAdViewDelegate` handle overlay interactions.

## Game Mechanics

### Charged Jump System (3-Tier)

Players tap to jump or hold to charge for higher jumps:

| Tier | Hold Duration | Multiplier | Charge Bar Color |
|------|--------------|------------|-----------------|
| Quick tap | < 0.3s | 1.0x | Green |
| Medium hold | 0.3s – 0.7s | 1.5x | Orange |
| Long hold | 0.7s – 1.0s | 2.0x | Red |

Visual feedback includes a charge bar above the hotdog and a floating tier label on release.

### Platform Spacing

Platforms have randomized vertical gaps with weighted distribution:
- **60%** close gaps (1x tap reachable)
- **25%** medium gaps (requires ~1.5x charge)
- **15%** far gaps (requires ~2x charge)

### Enemy Stations

Ketchup, wasabi, and water stations appear after ~25 platforms and escalate in difficulty. Stations animate side-to-side and shoot sauce projectiles. Sauce follows a scripted trajectory (no gravity) and triggers game over on contact with the hotdog.

### Reward System (currently disabled)

Every 10 platforms, accessories are awarded in a fixed sequence: crown, cape, sunglasses, halo, bowtie, headband. Accessories accumulate on the hotdog with pop-in animations and a celebration burst effect.

## Key SDKs & Frameworks

| Framework | Usage |
|-----------|-------|
| **SpriteKit** | Game scene, physics, collision detection, particle effects |
| **UIKit** | View controllers, overlays, Auto Layout |
| **StoreKit 2** | In-app purchases (Remove Ads $0.99) via async/await |
| **AVFoundation** | Background music playback (`MusicPlayer`) |
| **SnapKit** | Auto Layout constraints for UIKit views |
| **Flurry SDK** | Analytics framework (linked, service currently no-op) |

## Monetization

- **Interstitial House Ads** — Full-screen ad shown every 5 deaths promoting "Remove Ads for $0.99". 3-second countdown before dismissable.
- **IAP (Remove Ads)** — One-time non-consumable purchase via StoreKit 2. Product ID: `com.hotdogup.removeads`. Purchase state persisted in `UserDefaults` and verified via `Transaction.currentEntitlements`.
- **Restore Purchases** — Available on the game over screen.

## Persistence

All user preferences are centralized through the `Persistence` protocol (backed by `UserDefaults`), accessed via `GameSettings`:

| Key | Type | Purpose |
|-----|------|---------|
| `highestScore` | Int | Best score across sessions |
| `selectedCharacter` | Int | Hotdog type (mrjj/jane/han) |
| `isMusicOn` | Bool | Background music toggle |
| `isSoundEffectOn` | Bool | Sound effects toggle |
| `doNotShowTutorial` | Bool | Tutorial dismissed permanently |
| `purchased` | Bool | Ads removed via IAP |
| `deathCount` | Int | Deaths tracked for ad frequency |
| `resumeSpeed` | Float | Game speed saved on pause |

## Project Structure

```
HotdogUp/
├── App/                    # AppDelegate, SceneDelegate, AppCoordinator
├── Core/
│   ├── Ads/                # Ads protocol + NoopAdsService
│   ├── Analytics/          # Analytics protocol + NoopAnalyticsService
│   ├── DI/                 # Container (dependency injection)
│   ├── IAP/                # IAP protocol + StoreKit2Service
│   └── Persistence/        # Persistence protocol + UserDefaultsPersistence
├── Controller/
│   ├── GameScene.swift     # SpriteKit game loop, physics, input
│   ├── Constants.swift     # All tunable game parameters
│   ├── MusicPlayer.swift   # AVAudioPlayer wrapper
│   └── MenuViewController  # Main menu
├── Features/
│   ├── Game/               # GameViewModel, GameViewController, GameCoordinator
│   └── Store/              # StoreViewController (character selection)
├── Model/
│   ├── Hotdog.swift        # Player entity + accessory system
│   ├── Path.swift          # Platform entity
│   ├── Station.swift       # Enemy station entity
│   ├── Sauce.swift         # Projectile entity
│   └── GameSettings.swift  # Typed UserDefaults wrapper
├── View/
│   ├── PauseView.swift
│   ├── GameoverView.swift
│   ├── TutorialView.swift
│   ├── InterstitialAdView.swift
│   └── Main.storyboard
└── Supporting Files/
    ├── Info.plist
    ├── Assets.xcassets
    └── Audio files (.mp3, .wav)
```

## Requirements

- iOS 16.0+
- Xcode 16+
- Swift 5.9+
