import UIKit
import AVFoundation

class DialogViewController: UIViewController {

    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var dialogTitle: String?
    var dialogContent: String?
    var onDissmis: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        header.text = dialogTitle
        content.text = dialogContent
    }
    
    func attachTo(_ controller: UIViewController) {
        view.alpha = 0
        
        controller.addChild(self)
        controller.view.addSubview(view)
        
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.view.alpha = 1
        }
    }
    
    func deattachFromParentController() {
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.view.alpha = 0
        } completion: {  [weak self] _ in
            self?.onDissmis?()
            self?.removeFromParent()
            self?.view.removeFromSuperview()
        }
    }
    
    @IBAction func okAction(_ sender: Any) {
        deattachFromParentController()
    }
}

