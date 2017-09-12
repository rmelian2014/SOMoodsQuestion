//
//  ViewController.swift
//  MoodSwings
//
//  Created by Sandeep Hasrajani on 6/3/17.
//  Copyright © 2017 Sandeep Hasrajani. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class MoodsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var logOut: UIButton!
    @IBOutlet weak var moodsCollectionView: UICollectionView!
    var jsonArray: [[Any]]!
    var moodTitleToSend = ""
    var collectionViewSet = false
    
    func setCollectionView() {
        let collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        collectionViewLayout.itemSize = CGSize(width: 180, height: 180)

        moodsCollectionView.collectionViewLayout = collectionViewLayout
        let customYPosition = self.view.frame.origin.y + logOut.frame.height + collectionViewLayout.sectionInset.top
        let customFrame = CGRect.init(x: self.view.frame.origin.x, y: customYPosition, width: self.view.frame.width, height: self.view.frame.height)
        moodsCollectionView.frame = customFrame
        moodsCollectionView.dataSource = self
        moodsCollectionView.delegate = self
        moodsCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        moodsCollectionView.backgroundColor = UIColor.white
        self.collectionViewSet = true
    }
    
    func getMoods() {
        self.moodTitleToSend = ""
        let sharedSession = URLSession.shared
        let url = URL(string: "http://www.wokeuponeday.com/Moods_Test.php")
        let urlRequest = URLRequest(url: url!)
        let urlTask = sharedSession.dataTask(with: urlRequest) { (moods, _, _) in
            DispatchQueue.main.async {
                if let moods = moods {
                    do {
                        if let jsonData = try JSONSerialization.jsonObject(with: moods, options: []) as? [[Any]] {
                            self.jsonArray = jsonData
                            if self.collectionViewSet == false {
                                self.setCollectionView()
                            }
                            self.jsonArray.append(["Shuffle"])
                            self.moodsCollectionView.reloadData()
                        }
                    } catch {
                        print("Issues parsing JSON")
                    }
                }
            }
        }
        urlTask.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getMoods()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutSocial(_ sender: Any) {
        let logInManager = FBSDKLoginManager.init()
        logInManager.logOut()
        FBSDKAccessToken.setCurrent(nil)
        self.dismiss(animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let jsonArray = self.jsonArray else {
            print("data didn't come in")
            return 0
        }
        return jsonArray.count
    }
    
    func buildCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.orange
        let cellLabel = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        if let cellLabelText = self.jsonArray[indexPath.row][0] as? String {
            cellLabel.text = cellLabelText
            cellLabel.textAlignment = .center
        }
        for view in cell.subviews {
            view.removeFromSuperview()
        }
        cell.addSubview(cellLabel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.buildCell(collectionView: collectionView, indexPath: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "resultsTransition") {
            let resultsViewController = segue.destination as! ResultsViewController
            resultsViewController.moodTitleHolder = self.moodTitleToSend
        }
    }
    
    func findDuplicates(collection: Array<Any>) -> Array<Int> {
        var duplicates: Dictionary<Int, String> = [:]
        for outterIndex in 0...collection.count - 1 {
            for innerIndex in (0...collection.count - 1) {
                if (outterIndex < innerIndex && collection[outterIndex] as! String == collection[innerIndex] as! String) {
                    duplicates[innerIndex] = collection[innerIndex] as? String
                    break
                }
            }
        }
        return  Array(duplicates.keys)
    }
    
    @IBAction func reorderMoods(_ sender: Any) {
        self.shuffleMoodPositions(collectionView: self.moodsCollectionView)
    }
    
    func shuffleCollection(collection: Array<Any>) -> Array<Any> {
        var shuffledCollection: Array<Any> = collection
        for index in 0...collection.count - 1 {
            let randomIndex = Int(arc4random_uniform(UInt32(collection.count)))
            shuffledCollection[index] = collection[randomIndex]
        }
        
        while (self.findDuplicates(collection: shuffledCollection).count > 0) {
            for index in 0...collection.count - 1 {
                let randomIndex = Int(arc4random_uniform(UInt32(collection.count)))
                shuffledCollection[index] = collection[randomIndex]
            }
        }
        return shuffledCollection
    }
    
    func shuffleMoodPositions(collectionView: UICollectionView) {
        var shuffledJsonArray = [[Any]]()
        let filteredArray = self.jsonArray.joined().filter {$0 as! String != "Shuffle"}
        let shuffledData = self.shuffleCollection(collection: filteredArray)
        for index in 0...shuffledData.count - 1 {
            shuffledJsonArray.append([shuffledData[index]])
        }
        self.jsonArray = shuffledJsonArray
        self.jsonArray.append(["Shuffle"])
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            for view in cell.subviews {
                if view is UILabel {
                    let label = view as! UILabel
                    let labelText = label.text!
                    if labelText != "Shuffle" {
                        self.moodTitleToSend = labelText
                        self.performSegue(withIdentifier: "resultsTransition", sender: self)
                    } else {
                        self.getMoods()
                    }
                }
            }
        }
    }
}

