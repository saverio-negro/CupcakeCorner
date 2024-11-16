#  Loading an Image from a Remote Server

### When using `AsyncImage(url:)`, SwiftUI does know nothing about the image
### until our code is run and the image downloaded, and
### it's not able to size is appropriately ahead of time.

```swift
AsyncImage(url: URL(string: "https://hws.dev/img/logo.png"))
```

### As it is now, since the picture was created to be 1200 pixels high,
### with `AsyncImage(url:)`, SwiftUI loads that image as if it were designed
### to be shown at 1200 pixels high - it will be much bigger than our screen,
### and it will look a bit blurry too.
### We could fix this by telling SwiftUI, ahead of time, that we are trying
### to load a 3x scale image.

```swift
AsyncImage(url: URL(string: "https://hws.dev/img/logo.png"), scale: 3)
```

### There's one particular aspect, though. That entails the fact that, if we were to try to
### apply the `resizable()` and `scaledToFit()` modifiers, that won't work:

```swift
AsyncImage(url: URL(string: "https://hws.dev/img/logo.png"), scale: 3)
    .resizable()
    .scaledToFit()
```

### That's because, those modifiers don't apply directly to the `Image` view we are getting back
### from `AsyncImage(url:)` - they can't because SwiftUI can't know how to apply them until it has
### actually fetched the image data.

### Instead, we are actually applying those modifiers to a wrapper around the image, which is the
### `AsyncImage` view. That will ultimately contain our finished image, but it also contains a placeholder
### that gets used while the image is loading. 

### In order to adjust the image that SwiftUI downloads from the internet and that is wrapped around the
### `AsyncImage view, we need to use a different constructor of `AsyncImage`, which is the
### `AsyncImage(url:content:placeholder:)` initializer.

```swift
AsyncImage(url: URL()content:placeholder:)
```

### If we wanted *complete* control over the remote image, there's a third way we can create `AsyncImage`, which
### tells us whether the image was loaded, hit an error, or hasn't finished yet.

