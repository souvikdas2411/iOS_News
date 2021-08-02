### Frameworks used:

[newsapi.org](newsapi.org) & [rapidapi.com](rapidapi.com) provide a free REST API for leading news sources. SwiftyJSON helps in parsing API data. RealmSwift makes caching real easy. SDWebImage helps in downloading and manipulating images.

_The Vision framework allows the users to apply computer vision algorithms to perform a variety of tasks on input images and video._

### What to expect?

<img src="https://media.geeksforgeeks.org/wp-content/uploads/20210610155916/Screenshot20210610at35843PM.png" width="250" height="200">

**Output:** 
_About
Developed this app to easily extract code snippets from youtube tutorials which do not have a git link. Watching and typing becomes a tedious task at times. Anyways the repo name suggests it all. Live proj. Some commits might produce bugs._

### Code block
_Import Vision framework._
```
import vision
```
_Add access to camera/photos so the user can click/select images for character recognition. Make sure to add the necessary permissions in info.plist_
```
@IBAction func didTapCamera(){
       presentPhotoActionSheet()
}
```
```
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
   
   func presentPhotoActionSheet() {
       let actionSheet = UIAlertController(title: NSLocalizedString("Profile Picture", comment: "") ,
                                           message: NSLocalizedString("How would you like to select a picture?", comment: ""),
                                           preferredStyle: .actionSheet)
       actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                           style: .cancel,
                                           handler: nil))
       actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""),
                                           style: .default,
                                           handler: { [weak self] _ in
                                               
                                               self?.presentCamera()
                                               
                                           }))
       actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Chose Photo", comment: ""),
                                           style: .default,
                                           handler: { [weak self] _ in
                                               
                                               self?.presentPhotoPicker()
                                               
                                           }))       
       present(actionSheet, animated: true)
   }
   
   func presentCamera() {
       let vc = UIImagePickerController()
       vc.sourceType = .camera
       vc.delegate = self
       vc.allowsEditing = true
       
       present(vc, animated: true)
   }
   
   func presentPhotoPicker() {
       let vc = UIImagePickerController()
       vc.sourceType = .photoLibrary
       vc.delegate = self
       vc.allowsEditing = true
       present(vc, animated: true)
   }
   
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       picker.dismiss(animated: true, completion: nil)
       guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
           return
       }
       act.isHidden = false
       act.startAnimating()
       self.image.image = selectedImage
       recognizeText(image: selectedImage)
   }
   
   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       picker.dismiss(animated: true, completion: nil)
   }
}
```
_Add function to recognize text from selected image._
```
    private func recognizeText(image: UIImage?){
        var textString = ""
        request = VNRecognizeTextRequest(completionHandler: {(request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {
                    print("duh")
                    continue
                }
                textString += "\n\(topCandidate.string)"
                DispatchQueue.main.async {
                    self.act.isHidden = true
                    self.act.stopAnimating()
                    self.label.text = textString
                }
            }
            
        })
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let requests = [request]
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let img = image?.cgImage else {
                print("Nay")
                return
            }
            let handle = VNImageRequestHandler(cgImage: img, options: [:])
            try?handle.perform(requests)
        }
        
    }
```
### Support or Contact

[Drop me a mail](souvikdas2411@gmail.com) and we’ll sort it out.
