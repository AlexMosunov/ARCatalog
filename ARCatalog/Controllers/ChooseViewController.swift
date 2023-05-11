//
//  ChooseViewController.swift
//  ARCatalog
//
//  Created by User on 20.02.2023.
//

import UIKit

class ChooseViewController: UIViewController {
    
    let dataSource = ChooseVCModel()
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

}

extension ChooseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OptionCell.indentifier, for: indexPath) as? OptionCell
        let model = dataSource.options[indexPath.item]
        cell?.update(model: model)
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { //TODO: refactor
        switch indexPath.row {
        case 0:
            if let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ARFurnitureViewController") as? ARFurnitureViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 1:
            if let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ARDiceViewController") as? ARDiceViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 2:
            if let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ARImageRecognitionVC") as? ARImageRecognitionVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 3:
            if let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ARObjectRecognitionVC") as? ARObjectRecognitionVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 4:
            if let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ARFaceRecognitionVC") as? ARFaceRecognitionVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
    }
    
}

extension ChooseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 150, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
    }
}
