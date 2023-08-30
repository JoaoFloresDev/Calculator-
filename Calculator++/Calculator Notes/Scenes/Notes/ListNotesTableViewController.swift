//MIT License
//
//Copyright (c) 2017 Nikhil Singh
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.


import UIKit
import CoreData
import GoogleMobileAds

class ListNotesTableViewController: UITableViewController, GADBannerViewDelegate {
    var bannerView: GADBannerView!
    
    var notes = [Note]() {
        didSet {
            tableView.reloadData()
        }
    }
    
//    MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setup()
        notes = CoreDataHelper.retrieveNote()
        tableView.backgroundView  = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        let placeholderView = CustomStackedView(
            title: Text.emptyNotesTitle.localized(),
            subtitle: Text.emptyNotesSubtitle.localized(),
            image: UIImage(named: "emptyNotesIcon")
        )
        placeholderView.frame = CGRect(x: 0, y: (UIScreen.main.bounds.height / 2) - (UIScreen.main.bounds.width * 0.4), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.8)
        tableView.backgroundView?.addSubview(placeholderView)
        
        setupAds()
        buttonEdit.title = Text.edit.localized()
        self.title = Text.notes.localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkPurchase()
    }
    
//    MARK: - Ads
    func checkPurchase() {
        if(RazeFaceProducts.store.isProductPurchased("NoAds.Calc") || (UserDefaults.standard.object(forKey: "NoAds.Calc") != nil)) {
                bannerView?.removeFromSuperview()
        }
    }
    
    func setupAds() {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["bc9b21ec199465e69782ace1e97f5b79"]
        
        bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-8858389345934911/5265350806"
        bannerView.rootViewController = self
        
        bannerView.load(GADRequest())
        bannerView.delegate = self
        checkPurchase()
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
        ])
    }
    
    // 1
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(notes.isEmpty) {
            tableView.backgroundView?.isHidden = false
        }
        else {
            tableView.backgroundView?.isHidden = true
        }
        return notes.count
    }
    
    // 2
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "listNotesTableViewCell", for: indexPath) as? ListNotesTableViewCell {
            let row = indexPath.row
            let note = notes[row]
            cell.noteTitleLabel.text = note.title
            cell.contentLabel.text = note.content
            cell.noteModificationTimeLabel.text = note.modificationTime?.convertToString()
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
    @IBOutlet weak var buttonEdit: UIBarButtonItem!
    @IBAction func showDeleteButton(_ sender: Any) {
        
        if(self.isEditing) {
            self.setEditing(false, animated: true)
            buttonEdit.title = Text.edit.localized()
            self.rateApp()
        } else {
            self.setEditing(true, animated: true)
            buttonEdit.title = Text.done.localized()
        }
    }
    
    func rateApp() {
        if #available(iOS 10.3, *) {

            SKStoreReviewController.requestReview()
        }
    }
    
    @IBAction func unwindToListNotesViewController(_ segue: UIStoryboardSegue) {
        self.notes = CoreDataHelper.retrieveNote()
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //notes.remove(at: indexPath.row)
            CoreDataHelper.deleteNote(note: notes[indexPath.row])
            notes = CoreDataHelper.retrieveNote()
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "displayNote" {
                print("Table view cell tapped")
                if let indexPath = tableView.indexPathForSelectedRow {
                    let note = notes[indexPath.row]
                    let displayNoteViewController = segue.destination as! DisplayNoteViewController
                    displayNoteViewController.note = note
                }
            } else if identifier == "addNote" {
                print("+ button tapped")
            }
        }
    }
}
