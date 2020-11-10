//
//  ViewController.swift
//  WeeZeeDemo
//
//  Created by Mijo Kaliger on 31/10/2020.
//

import UIKit
import weezee
import AudioToolbox

class ViewController: UIViewController, UITextFieldDelegate {
    
    private var wzCameraViewController: WZCameraViewController!
    private var imagePicker: UIImagePickerController!
    @IBOutlet weak var numbersTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var numbersSearchingLabel: UILabel!
    @IBOutlet weak var numbersFoundLabel: UILabel!
    @IBOutlet var cameraOverlayView: UIView!
    
    private var numbers = [String]()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numbersSearchingLabel.text = ""
        numbersFoundLabel.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameTextField {
            self.numbersTextField.becomeFirstResponder();
        } else if textField == self.numbersTextField {
            if let numbersEntered = self.numbersTextField.text?.components(separatedBy: ",") {
                numbers.append(contentsOf: numbersEntered)
            }
            textField.resignFirstResponder()
            searchButton.isEnabled = true
            numbersSearchingLabel.text = self.numbersTextField.text
        }
    
        
        return true
    }
    
    @IBAction func searchButtonTouched(_ sender: Any) {
        wzCameraViewController = WZCameraViewController()
        wzCameraViewController.modalPresentationStyle = .fullScreen
        wzCameraViewController?.delegate = self
        wzCameraViewController.cameraOverlayView = self.cameraOverlayView
        self.present(wzCameraViewController, animated: true, completion: nil)
    }
    
}

extension ViewController: WZCameraViewControllerDelegate {
    func cameraViewController(_ cameraViewController: WZCameraViewController, recognizedString: String) {
        print("\(recognizedString)")
        
        if numbers.contains(recognizedString) {
            self.numbersFoundLabel.text?.append(recognizedString + ", ")
            AudioServicesPlaySystemSound(1054);
        } else {
            AudioServicesPlaySystemSound(1053);
        }
    }
}

