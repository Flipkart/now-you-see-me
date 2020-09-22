<h1 align="center">
 <img src="https://raw.githubusercontent.com/Flipkart/now-you-see-me/master/NowYouSeeMe.png" width="200" alt="Logo"/> 
 <br/>
 <br/>
 Now You See Me
</h1>

[![Build Status](https://api.travis-ci.org/Flipkart/now-you-see-me.svg?branch=master)](https://travis-ci.org/github/Flipkart/now-you-see-me)
[![Version](https://img.shields.io/cocoapods/v/NowYouSeeMe?color=blue)](http://cocoapods.org/pods/NowYouSeeMe)
[![Platform](https://img.shields.io/cocoapods/p/NowYouSeeMe)](http://cocoapods.org/pods/NowYouSeeMe)
[![Swift](https://img.shields.io/badge/swift-5-orange)](https://developer.apple.com/swift/)
[![Docs](https://raw.githubusercontent.com/Flipkart/now-you-see-me/gh-pages/badge.svg)](https://flipkart.github.io/now-you-see-me/index.html)
[![License](https://img.shields.io/cocoapods/l/NowYouSeeMe?color=purple)](http://cocoapods.org/pods/NowYouSeeMe)
<br/>
<br/>
NowYouSeeMe is a view tracking framework written in Swift that can be attached to an instance of UIView or any of its subclasses with a single API written on UIView. Views can also add custom viewability conditions and listeners.

## Ideology:

* 60 fps (all calculations on background thread)
* No trackable wrappers on views
* Viewability rules injected by view
* Viewability callbacks back to the view (on main thread)
* Simple and easy to use APIs

## Usage

To enable the framework you need to call the following method before the UI is created:

~~~swift
NowYou.seeMe()  // didFinishLaunchingWithOptions is a good place to initialise the framework
~~~

### View

Gone are the days, when you had to create custom view subclasses for tracking viewability.  

Tracking a view is now as simple as:

~~~swift
view.trackView()  // can be UIView or any of its subclasses
~~~

You will also need to call trackView on the parent UIViewController's view for managing viewcontroller lifecycle based viewability callbacks

~~~swift
override func viewDidLoad() {
    super.viewDidLoad()
    self.view.trackView()
}
~~~

### ScrollView

In case you want to track viewability of <i>children of scrollView, you must also call ```trackView()``` on scrollView</i>.

~~~swift
scrollView.trackView()  // can be UIScrollView, UITableView, UICollectionView, or any other scrollable view
~~~

This enables tracking on ```contentOffset``` of scrollView, to calculate correct visibility of children.

### Recyclable View

In case you want to track viewability of <i>children of a recyclable view, you must also call ```trackView()``` on the recyclable view</i>.

~~~swift
cell.trackView()  // can be UITableViewCell, UICollectionViewCell, or any other recyclable view
~~~

## Listener

No point tracking view if you can can't listen to the changes. 

You can provide a ```ViewabilityListener``` for the view in ```trackView()``` call to listen to ```viewStarted(:)``` and ```viewEnded(:)``` events.  

~~~swift
class CustomListener: ViewabilityListener {
    // view has entered the view port (visibility percentage > 0)
    func viewStarted(_ view: UIView) {
        view.backgroundColor = .green
    }

    // complete view has exited the viewport (visibility percentage == 0)
    func viewEnded(_ view: UIView) {
        view.backgroundColor = .red
    }
}

view.trackView(CustomListener())  // listener attached to the view
~~~

## Conditions

Want more control over viewability callbacks?  

You can provide your custom ```ViewCondition```'s for the view in ```trackView()``` call.  

~~~swift
class CustomCondition: ViewCondition {
    func evaluate(for state: ScrollState, viewPercentage: Float) {
        // custom evaluation here based on scroll state and visible view percentage
    }
}

view.trackView(conditions: [CustomCondition()])  // view condition added to the view
~~~

### Default Conditions

A few default view conditions are exposed to save you from calculations.

* [```ScrollIdleCondition```](https://flipkart.github.io/now-you-see-me/Classes/ScrollIdleCondition.html).
* [```ViewabilityCondition```](https://flipkart.github.io/now-you-see-me/Classes/ViewabilityCondition.html). 
* [```TrackingCondition```](https://flipkart.github.io/now-you-see-me/Classes/TrackingCondition.html). 

## API Documentation

The full documentation for NowYouSeeMe is [available here](https://flipkart.github.io/now-you-see-me/index.html).

More information can be found in the [Wiki section](https://github.com/Flipkart/now-you-see-me/wiki).

## Installation

To integrate NowYouSeeMe into your Xcode project using CocoaPods, specify it in your ```Podfile```:

```ruby
pod 'NowYouSeeMe'
```

Then, run the following command:

```bash
$ pod install
```

## Dependencies
* [FCChatHeads](https://github.com/flipkart-incubator/fk-ios-chatheads)

## Requirements
* iOS 10.0+
* Swift 5

---

[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=flipkart/now-you-see-me)](http://clayallsopp.github.io/readme-score/?url=flipkart/now-you-see-me)
