//
//  ImageGalleryTableViewController.swift
//  imageGallery
//
//  Created by 1C on 11/07/2022.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {

    // MARK: - Public API
    var gallerys: [[ImageGallery]]!
    
    // MARK: - Outlets
    @IBAction func addRow(_ sender: UIBarButtonItem) {
        addNewRow()
    }
      
    @IBAction func save(_ sender: Any) {
        gallerysJson = gallerys
    }
    
    // MARK: - View controller life cycle
        
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
             
        if let gallerysLoad = gallerysJson {
            gallerys = gallerysLoad
        } else {
            gallerys = [[ImageGallery(title: "Gallery 1", images: [])]]
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if splitViewController?.preferredDisplayMode != .oneOverSecondary {
            splitViewController?.preferredDisplayMode = .oneOverSecondary
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gallerysJson = gallerys
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if lastSelectedIndexPath != nil {
            tableView.selectRow(at: lastSelectedIndexPath!,
                                animated: false,
                                scrollPosition: .none)
        } else {
            selectRow(at: IndexPath(row: 0, section: 0))
        }
              
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return gallerys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        gallerys[section].count
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isRecentlyDeletedRow(at: indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentlyDeletedRow", for: indexPath)

            cell.textLabel?.text = gallerys[indexPath.section][indexPath.item].name
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "GallerysRow", for: indexPath)

            if let imageGalleryCell = cell as? ImageGalleryTableViewCell {
                imageGalleryCell.textField.text = gallerys[indexPath.section][indexPath.item].name
                
                imageGalleryCell.resignHandler = { [weak self, unowned imageGalleryCell] in
                    if let galleryName = imageGalleryCell.textField.text {
                        self?.gallerys[indexPath.section][indexPath.item].name = galleryName
                        self?.tableView.reloadData()
                        self?.selectRow(at: indexPath)
                    }
                }
                
            }
            
            return cell
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Recently deleted"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if isRecentlyDeletedRow(at: indexPath) {
                
                if isLastRowInSection(at: indexPath) {
                    deleteFromModelAndClearSection(at: indexPath)
                } else {
                    deleteFromModelAndRemoveRow(at: indexPath)
                }
                
            } else {
                
                moveBetweenSection(from: indexPath.section,
                                       to: indexPath.section + 1,
                                       for: indexPath)
                
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if isRecentlyDeletedRow(at: indexPath) {
            let contextualAction = UIContextualAction(style: .normal,
                                                      title: "Undo",
                                                      handler: {[weak self] action,view,result in
                                                        self?.moveBetweenSection(from: indexPath.section,
                                                                           to: 0,
                                                                           for: indexPath)
                                                      })
            contextualAction.backgroundColor = .blue
            
            return UISwipeActionsConfiguration(actions: [contextualAction])
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedIndexPath = indexPath
        performSegue(withIdentifier: "ShowSelectedGallery", sender: indexPath)
    }
        
    // MARK: - Navigation

//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//
//        switch identifier {
//        case "ShowSelectedGallery":
//            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
//                if isRecentlyDeletedRow(at: indexPath) {
//                    return false
//                } else {
//                    return true
//                }
//            } else {
//                return false
//            }
//        default:
//            return false
//        }
//    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case "ShowSelectedGallery":
                if let indexPath = sender as? IndexPath {
                    if !isRecentlyDeletedRow(at: indexPath) {
                        
                        if let imageGalleryVC = segue.destination.content {
                            imageGalleryVC.imageGallery = gallerys[indexPath.section][indexPath.row]
                            imageGalleryVC.title = gallerys[indexPath.section][indexPath.row].name
                        }
                        
                    } else {
                        
                        if let imageGalleryVC = segue.destination.content {
                            
                            let leftSide = "Recently deleted("
                            let midSide = gallerys[indexPath.section][indexPath.row].name
                            let rightSide = ")"
                            
                            imageGalleryVC.imageGallery = nil
                            imageGalleryVC.title = [leftSide,midSide,rightSide].joined(separator: " ")
                            
                            imageGalleryVC.view.backgroundColor = .gray
                            imageGalleryVC.view.isUserInteractionEnabled = false
                            
                        }
                        
                    }
                }
            default:
                break
            }
        }
    }

    //MARK: - Private implementation
    
    private var userDeafault = UserDefaults.standard
    
    private var gallerysJson: [[ImageGallery]]? {
        get{
            if let jsonData = userDeafault.object(forKey: "SavedGallerys") as? Data {
                if let gallerysEncoding = try? JSONDecoder().decode([[ImageGallery]].self, from: jsonData) {
                    return gallerysEncoding
                }
            }
            return nil
        }
        set{
            if newValue != nil {
                if let jsonData = try? JSONEncoder().encode(gallerys) {
                    userDeafault.setValue(jsonData, forKey: "SavedGallerys")
                }
            }
        }
    }
    
    private var lastSelectedIndexPath: IndexPath?
    
    private func selectRow(at indexPath: IndexPath, after timeDelay: TimeInterval = 0.5) {
        
        Timer.scheduledTimer(withTimeInterval: timeDelay, repeats: false) {[weak self] timer in
            self?.tableView.selectRow(at: indexPath,
                                animated: true,
                                scrollPosition: .none)
//            if indexPath != self?.tableView.indexPathForSelectedRow {
            self?.tableView(self!.tableView, didSelectRowAt: indexPath)
//            }
        }

    }
    
    private func moveBetweenSection(from sectionOut: Int, to sectionIn: Int, for indexPath: IndexPath) {
                
        tableView.performBatchUpdates({
            let imageModel = gallerys[sectionOut].remove(at: indexPath.row)
            
            if gallerys.count == 1 {
                
                gallerys.append([])
                tableView.insertSections(IndexSet.init(integer: sectionIn),
                                         with: .fade)
                
            }
                               
            let destinationIndexPath = IndexPath(row: gallerys[sectionIn].count,
                                                 section: sectionIn)
            
            gallerys[sectionIn].insert(imageModel, at: destinationIndexPath.row)

//            tableView.moveRow(at: indexPath, to: destinationIndexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.insertRows(at: [destinationIndexPath], with: .fade)
        }, completion: { finish in
            self.selectRow(at: IndexPath(row: self.gallerys[sectionIn].count - 1,
                                    section: sectionIn))
        })
         
        if gallerys[recentlyDeletedSection!].count == 0 {
            tableView.performBatchUpdates {
                tableView.deleteSections(IndexSet.init([recentlyDeletedSection!]),
                                         with: .fade)
                gallerys.remove(at: recentlyDeletedSection!)
            }
        }
    }
    
    private func deleteFromModelAndRemoveRow(at indexPath: IndexPath) {
        tableView.performBatchUpdates {
            gallerys[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath],
                                 with: .fade)
        }
    }
    
    private func deleteFromModelAndClearSection(at indexPath: IndexPath) {
        tableView.performBatchUpdates {
            gallerys.remove(at: indexPath.section)
            tableView.deleteSections(IndexSet.init([indexPath.section]),
                                     with: .fade)
        }
    }
    
    private func addNewRow() {
        tableView.performBatchUpdates {
            
            gallerys[mainSection].append(ImageGallery(title: "Untitled".madeUnique(withRespectTo: getAllNamesOfGalleryes()),
                                                      images: []))
            let indexPath = IndexPath(row: gallerys[mainSection].count - 1, section: mainSection)
            tableView.insertRows(at: [indexPath], with: .fade)
            selectRow(at: indexPath)
        }

    }
    
    private func getAllNamesOfGalleryes() -> [String] {
      
        var names = gallerys[mainSection].map {
            $0.name
        }
        
        if let deleteSection = recentlyDeletedSection {
            names += gallerys[deleteSection].map {
                $0.name
            }
        }
                
        return names
        
    }
    
    private func isLastRowInSection(at indexPath: IndexPath) -> Bool {
        return gallerys[indexPath.section].count == 1
    }
    
    private var mainSection: Int {return 0}
    private var recentlyDeletedSection: Int? {return gallerys.count > 1 ? 1 : nil}
    
    private func isRecentlyDeletedRow(at indexPath: IndexPath) -> Bool {
    
        return indexPath.section == 1
    
    }

}

extension UIViewController {
    var content: imageGalleryViewController? {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController as? imageGalleryViewController ?? nil
        } else {
            return nil
        }
        
    }
}
