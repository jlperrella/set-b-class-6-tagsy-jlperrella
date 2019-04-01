# iOS Development: API Based Apps

1. [ Introduction ](#1)
2. [ Getting Started ](#2)
3. [ Building Out Our Screens ](#3)
4. [ Connecting to the Device Photo Library ](#4)
5. [ Nested Navigation Controllers ](#5)
6. [ Getting the Selected Image ](#6)
7. [ Alamofire ](#7)
8. [ ImmagaRouter ](#8)
9. [ Asynchronous Programming ](#9)
10. [ Loading Data into the UI ](#10)
11. [ Delegation Protocols ](#11)
12. [ Showing the Image Collection ](#12)
13. [ Showing the Image Detail ](#13)
14. [ Handling Multiple Collection Views ](#14)


<a name="1"></a>
## 1) Introduction

We are building an image categorization app called Tagsy. Users will be able to select an image from their device library, upload the image to the Imagga image recognition servers to be categorized. We will get some tags and colors that describe what is in our selected photo.

<a name="2"></a>
## 2) Getting Started

We are using the Imagga image recognition API to categorize our photos. You will need to sign up for a free 'Hacker' account at [imagga.com](https://imagga.com/).

<a name="3"></a>
## 3) Building Out Our Screens

Our app is going to have 4 different screens: a screen that shows the collection of images we've had categorized, a detail screen for each image (showing tags and colors), a loading screen that shows the progress of our upload, and a screen that shows us our photo library so we can select a photo.

Create a new Single View App called Tagsy. You do not need add any Testing or CoreData stubs.

### UICollectionViewController

Collection views and controllers are very similar to table views and controllers, but collection views can have multiple cells per row (ie. a table view can only support a single-column layout).

Open up the main storyboard and delete the view controller. Open the object library and search for collection view controller. Add one to the storyboard. Make it the intitial view controller.

![](https://i.imgur.com/J9NVRje.png)

Add a new group called Controller, and to this add a new file called `ImageCollectionViewController.swift`. (`ImageCollectionViewController` is a subclass of `UICollectionViewController`).

![](https://i.imgur.com/xKGUDmH.png)
![](https://i.imgur.com/9WPAINt.png)
![](https://i.imgur.com/qlVInwK.png)

On the main storyboard, select the collection cell and give it a reuseIdentifier: imageCell.

![](https://i.imgur.com/BjAJDoR.png)

Set the size of the cell to width: 100 and height: 100.

![](https://i.imgur.com/2JiOvI3.png)


Embed your view controller in a navigation controller.

Add another view controller to the main storyboard and corresponding swift file. This one is called `ImageDetailViewController`, and it is a subclass of `UIViewController`.

![](https://i.imgur.com/QDPMdZg.png)
![](https://i.imgur.com/VCJcmpQ.png)

Name the show segue "showImageDetail".

![](https://i.imgur.com/d2sIiyj.png)


<a name="4"></a>
## 4) Connecting to the Device Photo Library

We would like to allow users to select an image from the device library.

In the main storyboard, add a bar button item to the ImageCollectionViewController. Make it a "+".

![](https://i.imgur.com/J920Ccl.png)

When we click this + button, we want to load the image picker.

Before we start to implement the code to open the image picker, we should create a struct that represents an uploaded image.

Create a group called `Model`. Add two files to this group; `UploadedImage.swift` and `ImageColor.swift`.

![](https://i.imgur.com/ULB6hsQ.png)


```swift
import UIKit

struct UploadedImage {
    var tags: [String]
    var colors: [ImageColor]
    var id: String?
    var image: UIImage
}
```

```swift
struct ImageColor {
    let red: Int
    let green: Int
    let blue: Int
    let colorName: String
}
```

Open up `ImageCollectionViewController.swift`.

Remove any unnecessary boilerplate and add the following property at the top of your file:

```swift
var uploadedImages: [UploadedImage] = []
```

Create an IBAction by control dragging from the "+" button called `tappedPlusButton`.

![](https://i.imgur.com/itPDiis.png)

Now let's add the picker. Add the following property at the top of your file.

```swift
let imagePicker = UIImagePickerController()
```

Add conformance to the UIImagePickerControllerDelegate and  UINavigationControllerDelegate protocols in the `ImageCollectionViewController` class declaration.

```swift
class ImageCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
```

In `viewDidLoad`, set the imagePicker's delegate self.

```swift
imagePicker.delegate = self
```

In the `plusButtonTapped` action, add the following:

```swift
imagePicker.sourceType = .photoLibrary
present(imagePicker, animated: true, completion: nil)
```

Open `info.plist`. Add a new key called Privacy - Camera Usage Description. Give it a String value like "We need access to your camera to get a photo to tag!".

![](https://i.imgur.com/iYK2jbf.png)

<a name="5"></a>
## 5) Nested Navigation Controllers

Create another view controller called `ImageLoaderViewController` (subclass of `UIViewController`), along with it's corresponding code file.

![](https://i.imgur.com/Wm6Im1M.png)

Embed the `ImageLoaderViewController` in a navigation controller in the same way you did for the `ImageCollectionViewController`.

![](https://i.imgur.com/SOGYuK9.png)

### Modal Segues

We would like our image loader screen to slide up from below. To achieve this we will present our `ImageLoaderViewController` modally.

Create a new segue from the `ImageCollectionViewController` to our new controller. Choose "Present Modally".

![](https://i.imgur.com/U65NU4q.png)
![](https://i.imgur.com/hWWXi7P.png)

Give the segue an identifier called "showImageLoader".

![](https://i.imgur.com/bgkWd4D.png)

We don't need a navigation bar on our `ImageLoaderViewController`, we simply need to deviate from our default navigation stack. Uncheck "Shows Navigation Bar".

![](https://i.imgur.com/LAU0xMK.png)

<a name="6"></a>
## 6) Getting the Selected Image

Open up `ImageCollectionViewController` and add the following extension.

Add the following extension:

```swift
extension ImageCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // this method is called when the user has selected an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // get the image that the user selected
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // create an UploadedImage initialized with the chosen image
            let uploaded = UploadedImage(tags: [], colors: [], id: nil, image: image)

            // add new UploadedImage to the images array
            uploadedImages.append(uploaded)

            // dismiss the image picker
            imagePicker.dismiss(animated: false, completion: nil)

            // present the imageLoaderVC
            performSegue(withIdentifier: "showImageLoader", sender: self)

            // reload the collection view with the new data
            collectionView.reloadData()
        }
    }

}
```

Try running your app. You should see the image picker when you tap the + button. If you select an image, you should see a blank view slide up.

<img src="https://i.imgur.com/AuWSu9m.png" =300x />

<a name="7"></a>
## 7) Alamofire

Let's try to upload our selected file to the Imagga API so it can be categorized.

To access this API we are going to use Alamofire, a Swift-based HTTP networking library for iOS. It gives us a simpler and more intuitive interface on top of Apple's Foundation networking stack.

We're going to be using Alamofire to perform some basic networking tasks like uploading files and requesting data from the Imagga API.

#### Exercise

Add the Alamofire and SwiftyJSON pods to your project. (5 mins)

#### Solution

```swift
# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Tagsy' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Tagsy
  pod 'Alamofire'
  pod 'SwiftyJSON'

end
```

![](https://i.imgur.com/xCswTKp.png)


<a name="8"></a>
## 8) ImaggaRouter

There are 5 different pieces of data we need to construct a well formed request to the Imagga API.

**1) Base url**

`http://api.imagga.com/v1`

**2) Our authorization token**

You can find this on your Imagga account dashboard after signing in.

**3) The http method (ie. get or post)**

Use get when we are just retrieving data (ie. reading)
Use post when we are altering or adding new data (ie. writing)

**4) The path of the endpoint we are trying to reach**

This is the location of the endpoint based on the Imagga API documentation.

**5) Any parameters that need to pass our endpoint so it can do what we want**

ie. When we get tags and colors of our photos, we will need to pass the uploaded image id as part of our request.


#### Building the Router

Add a group called `Network`. Inside, create a file called `ImaggaRouter.swift` and paste in the following code.

We are creating an enum called ImaggaAPI that conforms to the `URLRequestConvertible` protocol that we get from Alamofire. Types that conform to the `URLRequestConvertible` protocol can be used to construct well-formed URL requests.

```swift
import Alamofire

public enum ImaggaRouter: URLRequestConvertible {

    enum Constants {
        static let baseURL = "https://api.imagga.com/v1"
        static let authorizationToken = "Basic <YOUR AUTH TOKEN HERE>"
    }

    case upload
    case tags(String)
    case colors(String)

    var method: HTTPMethod {
        switch self {
        case .upload:
            return .post
        case .tags, .colors:
            return .get
        }
    }

    var path: String {
        switch self {
        case .upload:
            return "/content"
        case .tags:
            return "/tagging"
        case .colors:
            return "/colors"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .tags(let contentID):
            return ["content": contentID]
        case .colors(let contentID):
            return ["content": contentID, "extract_object_colors": 0]
        default:
            return [:]
        }
    }

    public func asURLRequest() throws -> URLRequest {
        let url = try Constants.baseURL.asURL()

        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.setValue(Constants.authorizationToken, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = TimeInterval(10000)

        return try URLEncoding.default.encode(request, with: parameters)
    }

}
```

<a name="9"></a>
## 9) Asynchronous Programming

We need to build some functions to handle the asynchronous nature of interacting with the network. For instance, if we make a get request, we can't tell how long it will take to receive the data from our call. This means we need to build functions in a special way to handle receiving. We also don't want our app to stop working while it waits for the response to come in.

To the `Network` group, add a file called `ImaggaAPI.swift`.

Paste the following code:

```swift
import UIKit
import SwiftyJSON
import Alamofire

class ImaggaAPI {
    // we use a shared singleton to access an ImaggaAPI object
    // it's called like this:
    // ImaggaAPI.shared.whateverPublicMethod()
    static public let shared = ImaggaAPI()

    // our upload method takes three arguments
    // the first is the image that we want to upload to Imagga
    // the second is a function that will be called as we receive
    // upload progress data from Alamofire
    // the third one is a completion function which will be called
    // when we have received data from the network
    // our progressCompletion and completion functions use an @escaping keyword
    // to indicate that they can be called after our function has returned
    func postUpload(image: UIImage,
                progressCompletion: @escaping (_ percent: Float) -> Void,
                completion: @escaping (_ tags: [String]?, _ colors: [ImageColor]?, _ id: String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }

        // Call Alamofire's upload method with our image data
        // The data we send to Imagga will be multipart because we are sending an image file
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                // build the multipart form data
                multipartFormData.append(imageData, withName: "imagefile", fileName: "image.jpg", mimeType: "image/jpg")
            },
            // ImaggaRouter.upload encoding result block
            with: ImaggaRouter.upload
        ) { encodingResult in
            switch encodingResult {
            // we were successful in encoding ImaggaRouter.upload
            case .success(let encodedUpload, _, _):
                // pass upload progress data to our progressCompletion function
                encodedUpload.uploadProgress { progress in
                    progressCompletion(Float(progress.fractionCompleted))
                }
                // validate our encoding result
                encodedUpload.validate()

                // send our request and access the response
                encodedUpload.responseJSON { response in
                    guard response.result.isSuccess,
                        // our request failed, print the error
                        let value = response.result.value else {
                            print("Error while uploading file: \(String(describing: response.result.error))")
                            completion(nil, nil, nil)
                            return
                    }

                    // our request was successful (200)

                    // grab the upload id from the result
                    let uploadedImageID = JSON(value)["uploaded"][0]["id"].stringValue
                    print("Image uploaded with ID: \(uploadedImageID)")

                    // call downloadTags with our upload id
                    self.getTags(imageID: uploadedImageID) { tags in

                        // we've received tags data
                        // call downloadColors with our upload id
                        self.getColors(imageID: uploadedImageID) { colors in

                            // call our completion method with the data we've received
                            completion(tags, colors, uploadedImageID)
                        }
                    }
                }
            // encoding failed
            case .failure(let error):
                print("There was an error uploading image: \(error)")
            }
        }
    }

    // getTags takes 2 arguments
    // an uploaded image id and a completion function that will be called
    // when we have received data from the Imagga API
    func getTags(imageID: String, completion: @escaping ([String]?) -> Void) {
        Alamofire
            // build the requeset
            .request(ImaggaRouter.tags(imageID))
            // send the request and receive the response
            .responseJSON { response in
                guard response.result.isSuccess,
                      let value = response.result.value else {
                    // there was an error
                    print("Error while fetching tags: \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }

                // success!
                // get the tags from the response
                let tags = JSON(value)["results"][0]["tags"].array?.map { json -> String in
                    json["tag"].stringValue
                }

                // call the completion function and pass the tags
                completion(tags)
        }
    }

    // getColors takes 2 arguments
    // an uploaded image id and a completion function that will be called
    // when we have received data from the Imagga API
    func getColors(imageID: String, completion: @escaping ([ImageColor]?) -> Void) {
        Alamofire
            // build the requeset
            .request(ImaggaRouter.colors(imageID))
            // send the request and receive the response
            .responseJSON { response in
                guard response.result.isSuccess,
                    let value = response.result.value else {
                        // theere was an error
                        print("Error while fetching colors: \(String(describing: response.result.error))")
                        completion(nil)
                        return
                }

                // success!
                // get the colors from the response
                // create a ImageColor object for each set of color data we've recieved
                let photoColors = JSON(value)["results"][0]["info"]["image_colors"].array?.map { json -> ImageColor in
                    ImageColor(red: json["r"].intValue,
                               green: json["g"].intValue,
                               blue: json["b"].intValue,
                               colorName: json["closest_palette_color"].stringValue)
                }

                // call the completion function and pass the array of ImageColor objects
                completion(photoColors)
        }
    }
}
```

<a name="10"></a>
## 10) Loading Data into the UI

Now that we have layed the groundwork to make requests and receive responses from the Imagga API, let's load this data into our screens.

Open the main storyboard.

Add a `UIImageView` to the `ImageLoaderViewController`. Add constraints so the image view is pinned to each side.

![](https://i.imgur.com/U5Kv8H0.png)

Add a `UIProgressView` to the `ImageLoaderViewController`. It should be the same level in the view hierarchy as the image view.

Pin it to the bottom (60), left (40) and right (40) hand sides.

![](https://i.imgur.com/7inBa57.png)

Set the initial progress to 0.0.

![](https://i.imgur.com/JDovL3S.png)

Open the assistant editor, navigate to the `ImageLoaderViewController` code file. Control drag to create `IBOutlet`s for the image view and progress bar.

![](https://i.imgur.com/JghjTK0.png)


<a name="11"></a>
## 11) Delegation Protocols

Our `ImageLoaderViewController` only knows how to show an image and display upload progress on it's progress bar. It doesn't understand anything about showing tags or colors etc. 

In order to pass the uploaded data we received, we need to use delegation.

Add the following code to the `ImageCollectionViewController`

```swift
protocol ImageLoaderViewControllerDelegate {
    func dismiss()
    func addUploadedImage(uploadedImage: UploadedImage)
}

// ImageCollectionViewController conforms to the protocol
// we created above, which means it needs to implement
// the dismiss() and addUploadedImage(...) methods
extension ImageCollectionViewController: ImageLoaderViewControllerDelegate {

    func dismiss() {
        guard let imageLoaderVC =  imageLoaderViewController else { return }
        imageLoaderVC.dismiss(animated: true, completion: nil)
    }

    func addUploadedImage(uploadedImage: UploadedImage) {
        // get the index of the uploaded image that matches the one
        // we received from the ImageLoaderViewController
        let index = uploadedImages.firstIndex { uploaded -> Bool in
            uploaded.image == uploadedImage.image
        }

        // if we find an index
        if let i = index {
            // save the uploaded image to our uploadedImages array
            // at the index we found
            uploadedImages[i] = uploadedImage
        }
    }

}
```

We also need to keep a reference to the `ImageLoaderViewController` object.

Add the following property at the top of your class:

```swift
var imageLoaderViewController: ImageLoaderViewController?
```

Head back to the `ImageLoaderViewController`.

It will need to have an `uploadedImage` object that we can use to hold data and it will need a delegate property of type `ImageLoaderViewControllerDelegate`

Add the following properties:

```swift
var delegate: ImageLoaderViewControllerDelegate?
var uploadedImage: UploadedImage?
```

Remove `viewDidLoad()`, and add the following:

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // set the image view image
    if let uploaded = uploadedImage {
        imageView.image = uploaded.image
    }

    // make sure the progress view is always in front of the image view
    view.sendSubviewToBack(imageView)

    uploadImage()
}

private func uploadImage() {
    guard let image = uploadedImage else { return }

    // make post request to Imagga API to upload our imagee
    ImaggaAPI.shared.postUpload(image: image.image, progressCompletion: { progress in
        // update our progress view as progress data is received
        self.progressView.progress = progress
    }) { (tags, colors, id) in
        // save our tag and color data in our UploadedImage object
        if let tags = tags {
            self.uploadedImage?.tags = tags
        }

        if let colors = colors {
            self.uploadedImage?.colors = colors
        }

        if let id = id {
            self.uploadedImage?.id = id
        }

        if let uploaded = self.uploadedImage {
            // if we have a delegate
            // call the addUploadedImage method with our UploadedImage object
            self.delegate?.addUploadedImage(uploadedImage: uploaded)
        }

        // if we have a delegate
        // tell them they can dismiss us
        self.delegate?.dismiss()
    }
}
```

Run your app and try it out! What happens?

You are probably seeing a blank screen with a progress bar when you select an image.

This is because we haven't passed the image to our `ImageLoaderViewController`.

Add the following code to the `ImageCollectionViewController` main class (remove any duplicate boilerplate methods).

```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // our segue is technically to the ImageLoaderViewController's navigation controller
    // so we need to check for that first and then access the image loader
    // through the navigation controller's topViewController property
    guard let imageLoaderNC = segue.destination as? UINavigationController,
          let imageLoaderVC = imageLoaderNC.topViewController as? ImageLoaderViewController else {
        return
    }

    // set up the ImageLoaderViewController with the data it needs
    // prior to segueing
    imageLoaderViewController = imageLoaderVC
    imageLoaderViewController?.delegate = self
    imageLoaderVC.uploadedImage = uploadedImages.last
    return
}
```

Now give your app a try!

You might notice that the image you selected looks skewed when it's shown on the image loader. To fix this, open the main storyboard and select the image view in the `ImageLoaderViewController`. Change the content mode from "Scale to Fill" to "Aspect Fill".  This will maintain the aspect ratio of the image, while at the same time filling the image view.

![](https://i.imgur.com/n0xNCwa.png)


<a name="12"></a>
## 12) Showing the Image Collection

Open our `ImageCollectionViewController` and add the following code to the main class.

```swift
override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
}


override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return uploadedImages.count
}

override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

    let imageview: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100));
    imageview.image = uploadedImages[indexPath.row].image

    cell.contentView.addSubview(imageview)

    return cell
}
```

Add the following property to the top of the class.

```swift
let reuseIdentifier = "imageCell"
```

<a name="13"></a>
## 13) Showing the Image Detail

Add the following to our `ImageCollectionViewController`:
```swift
override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectedRow = indexPath.row

    performSegue(withIdentifier: "showImageDetail", sender: self)
}
```
Along with the following property:
```swift
var selectedRow: Int = 0
```
Let's build out our `ImageDetailViewController` so it shows actual data.

Add an image view and set it's constraints so that it is pinned to the top and sides, with a height of 250. Change the content mode to "Aspect Fill".

![](https://i.imgur.com/h0hgUN3.png)

Add a colors label. Pin it to the image view (8), left (17) and right (17) sides.

![](https://i.imgur.com/FW9PNJe.png)

Add a collection view. Pin it to the colors label (8), the left (17) and right (17) sides. Set a height of 115.

![](https://i.imgur.com/vw4Tzjv.png)

Add a tags label. Pin it to the collection view (8), left (17) and right (17) sides.

![](https://i.imgur.com/nEWY0EA.png)

Add another collection view. Pin it to the tags label (8), the left (17) and right (17) sides and the bottom (8). Do not set a height constraint.

![](https://i.imgur.com/gqM0G5T.png)

Since we have 2 collection views, this can get confusing. Change the names of the collections in the view hierarchy so we can tell them apart.

![](https://i.imgur.com/Y2VtdPc.png)

Create a new file called TagCell.swift (a subclass of UICollectionViewCell).

![](https://i.imgur.com/pB7BqLL.png)

In the main storyboard, click on the collection cell inside the collection view that will hold our tags. Give it a reuse identifier of "tagCell", and set it's class to `TagCell`.

![](https://i.imgur.com/ASGtkED.png)
![](https://i.imgur.com/BG1Exh8.png)

Adjust the width of the cell (not a constraint, just in the storyboard). Add a label to the cell. Add constraints to the label to centre it both horizontally and vertically. Give your cell a background colour.

![](https://i.imgur.com/ZAd2uyw.png)

Open the assistant editor and navigate to `TagCell.swift`.  Control drag your label to create an `IBOutlet` called `textLabel`.

Click on the colors collection view cell and give it a reuse identifier of `colorCell`

![](https://i.imgur.com/gIkDZMU.png)

Your finished `ImageDetailViewController` will look something like this:

![](https://i.imgur.com/a1VXhO5.png)

Open the assistant editor and navigate to `ImageDetailViewController.swift`. Control drag to create `IBOutlet`s for the `colorsCollectionView`, `tagsCollectionView` and `imageView`.

<a name="14"></a>
## 14) Handling Multiple Collection Views

Change your class declaration to conform to `UICollectionViewDelegate, UICollectionViewDataSource`.

Add the following code to you `ImageDetailViewController` class (remove any unused boilerplate).

```swift
var uploadedImage: UploadedImage?

override func viewDidLoad() {
    super.viewDidLoad()

    colorsCollectionView.delegate = self
    tagsCollectionView.delegate = self

    colorsCollectionView.dataSource = self
    tagsCollectionView.dataSource = self
}

override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    loadDataIntoUI()
}

func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
}

func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == tagsCollectionView {
        return uploadedImage?.tags.count ?? 0
    }

    if collectionView == colorsCollectionView {
        return uploadedImage?.colors.count ?? 0
    }

    return 0
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch collectionView {
    case tagsCollectionView:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as? TagCell

        cell?.textLabel.text = uploadedImage?.tags[indexPath.row]

        return cell!
    case colorsCollectionView:
        let cell = colorsCollectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)

        if let color: ImageColor = uploadedImage?.colors[indexPath.row] {
            cell.contentView.backgroundColor = UIColor(red: CGFloat(color.red) / 255.0, green: CGFloat(color.green) / 255.0, blue: CGFloat(color.blue) / 255.0, alpha: 1.0)
        }

        return cell
    default:
        let cell = colorsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }
}

func loadDataIntoUI() {
    guard let uploaded = uploadedImage else { return }

    imageView.image = uploaded.image

    tagsCollectionView.reloadData()
    colorsCollectionView.reloadData()
}
```

Try running your app! Afteer you upload photo and select it, you'll see a detail view but no data loaded.

In `ImageCollectionViewController` replace the `prepare` method with the following.

```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // check if we are segueing to the image detail or the image loader
    // and if we are, get a reference
    guard let imageDetailVC = segue.destination as? ImageDetailViewController else {
        // our segue is technically to the ImageLoaderViewController's navigation controller
        // so we need to check for that first and then access the image loader
        // through the navigation controller's topViewController property
        guard let imageLoaderNC = segue.destination as? UINavigationController,
              let imageLoaderVC = imageLoaderNC.topViewController as? ImageLoaderViewController else {
            return
        }

        // set up the ImageLoaderViewController with the data it needs
        // prior to segueing
        imageLoaderViewController = imageLoaderVC
        imageLoaderViewController?.delegate = self
        imageLoaderVC.uploadedImage = uploadedImages.last
        return
    }

    imageDetailVC.uploadedImage = uploadedImages[selectedRow]
}
```
