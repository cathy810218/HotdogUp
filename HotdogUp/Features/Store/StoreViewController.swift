//
//  StoreViewController.swift
//  HotdogUp
//
//  Created by Cathy Oun on 8/19/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import UIKit
import SnapKit

class StoreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var doneBtn: UIButton!
    var priceCTABtn = UIButton()
    var characterImageView = UIImageView()
    var characterImages: [UIImage?] = []
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateCellsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let item = UserDefaults.standard.integer(forKey: "UserDefaultsSelectCharacterKey")
        print(item)
        let indexPath = IndexPath(item: item, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 70)
        collectionView.allowsMultipleSelection = false
        collectionView.allowsSelection = true
        collectionView.backgroundColor = UIColor.clear
//        createCTAButton()
        let img = UIImage(named: "mrjj")!
        let img2 = UIImage(named: "jane")!
        let img3 = UIImage(named: "han")!
        characterImages = [img, img2, img3]
    }
    
    func createCTAButton() {
        priceCTABtn = UIButton(type: .custom)
        let img = UIImage(named: "free")!
        let ratio = img.size.height / img.size.width
        priceCTABtn.setBackgroundImage(img, for: .normal)
        self.view.addSubview(priceCTABtn)
        priceCTABtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.width.equalTo(150.0)
            make.height.equalTo(150.0 * ratio)
            make.bottom.equalTo(characterImageView.snp.top).offset(-10)
        }
    }
    
    func updateCellsLayout()  {

        let centerX = collectionView.contentOffset.x + (collectionView.frame.size.width)/2
        
        for cell in collectionView.visibleCells {
            var offsetX = centerX - cell.center.x
            if offsetX < 0 {
                offsetX *= -1
            }
            if offsetX > 0 {
                let offsetPercentage = offsetX / view.bounds.width
                let rotation = 1 - offsetPercentage
                cell.transform = CGAffineTransform(rotationAngle: rotation - 45)
            }
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characterImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as! CharacterCell
        cell.imageView.image = characterImages[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize: CGSize = collectionView.bounds.size
        cellSize.height *= UIDevice.current.userInterfaceIdiom == .pad ? 0.9 : 0.8
        print(collectionView.bounds.size)
        cellSize.width *= 0.75
        return cellSize
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCellsLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UserDefaults.standard.set(indexPath.item, forKey: "UserDefaultsSelectCharacterKey")
    }
}
