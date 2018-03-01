//
//  ExploreVC.swift
//  MealPlanner
//
//  Created by Hayden Jamieson on 07/02/2018.
//  Copyright © 2018 Hayden Jamieson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import DZNEmptyDataSet
import Speech

class ExploreVC: UIViewController {

    // Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var microphoneBtn: UIButton!
    
    // Variables
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        speechRecognizer?.delegate = self
        self.hideKeyboardWhenTappedAround()
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicator.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(recipesLoaded(_:)), name: NOTIF_RECIPES_LOADED, object: nil)
        microphoneBtn.isEnabled = false
        requestSpeechAuthorization()
    }

    @IBAction func signOutTapped(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("ID removed from keychain")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
        print(Auth.auth().currentUser as Any)
    }
    
    @IBAction func searchBtnTapped(_ sender: Any) {
        guard let queryText = searchField.text, searchField.text != "" else {
            showError(withTitle: "Input Error", andMessage: "Please enter text to query the recipes database.")
            return
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .background).async {
            DataService.shared.fetchRecipeWithQuery(queryText: queryText) { (success) in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
        
    }
    
    @objc
    func recipesLoaded(_ notif: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func microphoneTapped(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneBtn.isEnabled = false
            // start recording button title
        } else {
            startRecording()
            // stop recording btn title
            
            if let queryText = searchField.text, searchField.text != "" {
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                DispatchQueue.global(qos: .background).async {
                    DataService.shared.fetchRecipeWithQuery(queryText: queryText) { (success) in
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }
                }
            }
        }
    }
    
    @IBAction func filterTapped(_ sender: Any) {
    }
    
    
}

// MARK: Table view DS & Delegate

extension ExploreVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataService.shared.recipeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as? RecipeCell else { return UITableViewCell() }
        cell.configureCell(withRecipe: DataService.shared.recipeArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Fade
        cell.alpha = 0
        UIView.animate(withDuration: 0.33) {
            cell.alpha = 1
        }
 
        
        /*Frame
        cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, -cell.frame.width, 1, 1)

        UIView.animate(withDuration: 0.33) {
          cell.layer.transform = CATransform3DIdentity
         }
         */
        
        
        /* Curl
        cell.layer.transform = CATransform3DScale(CATransform3DIdentity, -1, 1, 1)
        
        UIView.animate(withDuration: 0.4) {
          cell.layer.transform = CATransform3DIdentity
        }
         */
    }
    
    
}

// MARK: TextField delegate

extension ExploreVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.letters
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}

// MARK: EmptyDataSet DS & Delegate

extension ExploreVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let myAttributes = [ NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.4996827841, green: 0.3257399201, blue: 0.2722818255, alpha: 1) , NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 20)!] as [NSAttributedStringKey : Any]
        return NSAttributedString(string: "No Recipes", attributes: myAttributes)
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}

// MARK: Speech Recognition

extension ExploreVC: SFSpeechRecognizerDelegate {
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.microphoneBtn.isEnabled = true
                
                case .denied:
                    self.microphoneBtn.isEnabled = false
                    print("User denied access to speech recognition")
                
                case .restricted:
                    self.microphoneBtn.isEnabled = false
                    print("Speech recognition restricted on this device")

                case .notDetermined:
                    self.microphoneBtn.isEnabled = false
                    print("Speech recognition not yet authorized")
                }
            }
        }
    }
    
    func startRecording() {
        // Check if recognition task is running, if so cancel task and recognition
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Create avaudiosession to preapre for audio recording, set category of the sessioon as recording, mode as measurement and active
        // Note that setting these properties may throw an exception so you must wrap in a try catch clause
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session properties were unable to be set")
        }
        
        // Instantiate a recognition request, create request object to later pass audio data to apple servers
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // Grab audio engine (your device) as variable
        let inputNode = audioEngine.inputNode
        
        // Check if request object is instantiated and not nil
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        // Report partial results of speech recog as user speaks
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition by calling recog task. Completion handler called every time the recognition engine has received input, has refined its current recognition, or has been canceled or stopped, will return a final transcript
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            // bool to determine if recognition is final
            var isFinal = false
            
            // If we have a result, set the text view text to results best transcript, if the result is the final result trigger our flag
            if result != nil {
                self.searchField.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            // If there is no error or result is final, stop audio engine input. stop recog request and task, enable micrphone btn
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.microphoneBtn.isEnabled = true
            }
        })
        
        // add audio input to recog request, note it is ok to add audio input after starting recog task. Speech framework will start recognizing as soon as an audio input has been added
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        // preperae and start audioengine
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("AudioEngine could not start")
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneBtn.isEnabled = true
        } else {
            microphoneBtn.isEnabled = false
        }
    }
    
    
}


