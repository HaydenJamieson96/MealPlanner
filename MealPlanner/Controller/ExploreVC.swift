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

    /**
        The IBAction for signing out. When this is called we remove the users key from the KeychainWrapper store to prevent further auto sign-in.
        We then try to sign them out of Firebase Authentication services and navigate them back to LoginVC.
     */
    @IBAction func signOutTapped(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("ID removed from keychain")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
        print(Auth.auth().currentUser as Any)
    }
    
    /**
        The IBAction for searching for a recipe. Safely unwraps the users search text, handling if they try to search on an empty string.
        We unhide and start our spinner to show the user operations are taking place.
        We call our DataService recipe request on a background thread to prevent and UI locking, passing in the users search text as the queryText argument, e.g. Chicken - search for all Chicken recipes. We use the completion handler success temp variable to stop animating our spinner and hide it as the web request has been succesful
        Note: Our table view reloading is done via the DataService via our Notification.
     */
    @IBAction func searchBtnTapped(_ sender: Any) {
        guard let queryText = searchField.text, searchField.text != "" else {
            showError(withTitle: "Input Error", andMessage: "Please enter text to query the recipes database.")
            return
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .background).async {
            DataService.shared.fetchRecipeWithQuery(queryText: queryText) { (success) in
                if success {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }
        }
        
    }
    
    /**
        The selector that is called when our VC observes a notification has been triggered and needs to reload the UI.
     
        - Parameter:
            - The notification to observe
     */
    @objc
    func recipesLoaded(_ notif: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /**
        The IBAction for recording the users voice to query the API using speech-to-text instead of manual input.
        We check if the audioEngine is running, stopping it if it is and disabling our record button.
        Otherwise we call our record function which passes the speech into the search field, allowing us to fire our web request using the text within the search field, i.e. the users speech.
    */
    @IBAction func microphoneTapped(_ sender: Any) {
        if audioEngine.isRunning {
            
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
            
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneBtn.isEnabled = false
            // start recording button title
            
           
            
        } else {
            startRecording()
            // stop recording btn title
            
            
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
        
        //let updateCell = tableView.cellForRow(at: indexPath)
       // if updateCell != nil {
        cell.configureCell(withRecipe: DataService.shared.recipeArray[indexPath.row])
        //}
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
    
    /**
        Handle the authorization status of the users device as we are working with sensitive data and require permission.
     */
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
    
    /**
        This function wraps our entire recording stack, it encompasses using our SpeechRecognizer, our Request and Task. The flow of the function is as followed;
     
        - Check if the recognition task is already running, cancelling it and nilling it if so.
        - Create an AVAudioSession instance to prepare for audio recording. We set the Category of the session as recording, the Mode as measurement and we set the session to be active. Setting these properties may throw an exception hence I have wrapped them in a try catch clause.
        - Instantiate a Recognition Request via a Request Object, to later pass the audio data to the Apple servers.
        - Grab our audio engine (your device) as a variable, note that AudioEngine uses a Singleton and the inputNode is never nil (non-optional).
        - Check if the request object is instantitated and not nil
        - Report partial results of the speech recognition as the user speaks.
        - Start the recognition task. The completion handler is called every time the recognition engine has received input, has refined its current recognition, or has been cancelled or stopped. It will return a final transcript.
        - We set up a bool to determine if the recognition is the final recognition.
        - If we have a result from our task, set the searchField text to the results best transcript, if the result is the final result then set our bool flag.
        - If there is no error or the result is final, stop the audio engine input, stop the recognition request and task, enable the microphone.
        - Add audio input to the recognition request. Note it is ok to add audio input after starting the recognition task, the speech framework will start recognizing it as soon as audio input has been added.
        - Prepare and start the audio engine.
     */
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
   
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session properties were unable to be set")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in

            var isFinal = false
            
            if result != nil {
                self.searchField.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.microphoneBtn.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
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


