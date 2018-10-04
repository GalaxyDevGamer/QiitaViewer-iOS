//
//  TagView.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/14.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class TagView: UIViewController, UITableViewDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noTagView: UIView!
    
    let disposeBag = DisposeBag()
    
    let viewModel = TagViewModel()
    var dataSource: RxTableViewSectionedAnimatedDataSource<SectionOfTag>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfTag>(configureCell: { (ds: TableViewSectionedDataSource<SectionOfTag>, tableView: UITableView, indexPath: IndexPath, model: TagStruct) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "tags", for: indexPath)
            cell.textLabel?.text = model.name
            return cell
        })
        dataSource.canEditRowAtIndexPath = { tableView, indexPath in true}
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(TagStruct.self)).bind { indexPath, tag in
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.navigationController?.pushViewController(ViewProvider.get.tagArticleView(name: tag.name), animated: true)
            }.disposed(by: disposeBag)
        tableView.rx.itemDeleted.subscribe(onNext: { indexPath in
            self.viewModel.deleteTag(index: indexPath.row)
        }).disposed(by: disposeBag)
        viewModel.tagNotifier.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        viewModel.isTagAvailable.bind(to: noTagView.rx.isHidden).disposed(by: disposeBag)
        viewModel.loadTags()
        let add = UIButton(type: UIButton.ButtonType.custom)
        add.setImage(UIImage(named: "Add24pt"), for: UIControl.State.normal)
        add.rx.tap.subscribe(onNext: { (_) in
            self.addTag()
        }).disposed(by: disposeBag)
        let right = UIBarButtonItem(customView: add)
        self.navigationItem.rightBarButtonItem = right
        self.navigationController?.navigationBar.barTintColor = UIColor.green
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tags.count
    }
    
    func addTag() {
        let alert = UIAlertController(title: "Add Tag", message: "Enter name", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Tag Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            if let fields = alert.textFields {
                for name in fields {
                    if self.viewModel.isTagExists(name: name.text!) {
                        let alert = UIAlertController(title: "Error", message: "This name is already added", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    self.viewModel.addTag(name: name.text!)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
