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
### tells us whether the image was loaded, hit an error, or hasn't finished yet. It uses the
### `AsyncImage(url:content:)` constructor.

```swift
AsyncImage(url: URL(string: "https://hws.dev/img/logo.png")) { phase in
    if let image = phase.image {
        image
            .resizable()
            .scaledToFit()
    } else if phase.error != nil {
        Text("There was an error loading the image.")
    } else {
        ProgressView()
    }
}
```
### That will show an image if it can, an error message if the download failed for any reason, or a spinning
### activity indicator while the download is still in progress.

## Validating and Disabling Forms

### We know that SwiftUI's `Form` view lets us store user input in a very convenient way, but sometimes it's
### important to go a step further - to *check* that input to make sure it's valid before we proceed.

### We have a modifier just for that purpose: `disabled()`. This takes a condition to check, and if that
### condition is true, then whatever it is attached to will no longer respond to user input - buttons can't
### be tapped, sliders can't be dragged, and so on.

### To demonstrate this, here's a form that accepts a username and email address:

```swift
Form {
    Section {
        TextField("username", text: $username)
        TextField("email", text: $email)
    }
    
    Section {
        Button("Create Account") {
            print("Creating account")
        }
    }
}
```

### In the example above, we don't want the user to create an account unless both fields have been filled in; so,
### we can disable the form section containing the "Create Account" button by adding the `disabled()` modifier
### like the following:

```swift
Form {
    Section {
        TextField("username", text: $username)
        TextField("email", text: $email)
    }
    
    Section {
        Button("Create Account") {
            print("Creating account")
        }
    }
    .disabled(username.isEmpty || email.isEmpty)
}
```

### That above means that the section is disabled if `username` is empty or `email` is empty.

### Most of the time you might find that's worth spinning out your conditions into a separate computed property,
### such as this:

```swift
var disableForm: Bool {
    username.count < 5 || email.count < 5
}
```

## Adding `Codable` Conformance to an `@Observable` Class

### We know that if all the properties of a type conform to the `Codable` protocol, then the type itself can
### conform to the `Codable` protocol with no extra work - Swift will synthesize the code required to archive
### (encode) and unarchive (decode) our type as needed.
### However, things get a little bit trickier when working with classes that use the `@Observable` macro because
### of the way that Swift rewrites our code.

### To see the problem in action, we could make a simple observable class that has a single property called
### `name`.

```swift
@Observable
class User: Codable {
    var name: String = "Steves"
}
```

### Now, we could write a little SwiftUI code that encodes an instance of our class when a button is pressed.

```swift
import SwiftUI

@Observable
class User: Codable {
    var name = "Steve"
}

struct SecondTestView: View {
    var body: some View {
        Button("Encode User", action: encodeSteve)
    }
    
    func encodeSteve() {
        let data = try! JSONEncoder().encode(User())
        let str = String(decoding: data, as: UTF8.self)
        print(str)
    }
}

#Preview {
    SecondTestView()
}
```

### What you'll see is unexpected: `{"_$observationRegistrar":{},"_name":"Steve"}`. Our `name` property is
### now `_name`, and there's also an observation registrar instance in the JSON.

### Remember that the `@Observable` macro is quietly rewriting our class so that it can be monitored by SwiftUI,
### and, in our encoding and decoding action, that rewriting is leaking - we can see it happening, which might cause
### all sorts of problems. For example, if we are trying to send a `name` value to a server, it might have no idea
### what to do with the `_name`, for example.

### To fix this, we need to tell Swift exactly how it should encode and decode our data. This is done by nesting
### an enum inside the `Codable` class called `CodingKeys`. Also, the enum needs to inherit from the `String` struct,
### since we want the `_name` case to have a raw value of type `String`: we want to tell Swift that, during the
### encoding, the `_name` property - which is rewritten from `name` because of the `Observable` macro as a way for 
### SwiftUI to monitor changes in the type's properties - should be archived as `name`. Also, to have Swift
### recognize that each case in the enum is a coding key (a key for encoding and decoding), we have `CodingKeys`
### conform to the `CodingKey` protocol.

### Inside the enum, you need to write one case for each property you want to save, along with a raw value
### containing the name you want to give it. In our case, that means saying that `_name` - the underlying storage
### for our name property due to the `Observable` macro - should be written out as the string "name", without
### an underscore:

```swift
@Observable
class User: Codable {
    
    enum CodingKeys: String, CodingKey {
        case _name = "name"
    }

    var name = "Steve"
}

struct ContentView: View {
    var body: some View {
        Button("Encode User", action: encodeUser)
        
        func encodeUser() {
            let data = try! JSONEncoder.encode(User())
            let str = String(decoding: data, as: UTF8.self)
            print(str)
        }
    }
}
``` 

### As far as the code above, you'll see that the encoded JSON has the property `name` property named
### correctly - without underscore - and there's also no observation registrar.

### This coding key mapping works both ways: when `Codable` (Decodable) sees `name` in some JSON, it will be
### automatically saved as the `_name` property, and that's very useful if you are dealing with an `@Observable`
### class.

## Taking Basic Order Details

### ** Data Model: "Order" Class **

### The first step in this project will be to create an ordering screen that takes the basic details of an order:
### how many cupcakes they want, what kind they want, and whether there are any special customizations.

### Before we get into the UI, we need to start by defining the data model. Previously we have mixed structs and
### classes to get the right result, but here we are going to take a different solution: we are going to have
### a single class that stores all our data, which will be passed from screen to screen. This means all screens in
### our app will share the same data, which will work really well as you'll see.

### For now, this class won't need many properties:

### - The type of cakes, plus a static array of all possible options (`type` and `types`).
### - How many cakes the user wants to order (`quantity`).
### - Whether the user wants to make special requests, which will show or hide extra options in our UI.
### - Whether the user wants extra frosting on their cakes.
### - Whether the user wants to add sprinkles on their cakes.

### Each of those needs to update the UI when changed, which means we need to make sure the class uses
### the `@Observable` macro.

### The following is the `Order` class for our data model:

```swift
@Observable
class Order {
    
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]
    
    var type = 0
    var quantity = 3
    
    var specialRequestEnabled = false
    var extraFrosting = false
    var addSprinkles = false
}
```

### We can now create a single instance of that `Order` class inside `ContentView` by adding this property:

```swift
@State private var order = Order()
```
### That's the only place that the order will be created - every other screens in our app will be passed
### that property (`Order` instance/object) so they all work with the same data.

### ** Working on the UI **

### As far as the UI, we are going to build it for the `ContentView` screen in three sections, starting with
### a cupcake type and quantity. All the sections will be wrapped inside a form, which is itself inside a
### navigation stack so we can set a title.

### * First Section *

### This first section will show:

### - A picker letting users choose from Vanilla, Strawberry, Chocolate, Rainbow cakes.
### - A stepper with the range 3 through 20 to choose the amount.

### There's a small speed bump here: our cupcake topping list (`types`) is an array of strings, but we are
### storing the user's selection as an integer (`type`) - how can we match the two?
### One easy solution is to use the `indices` property of the array, which gives us a position of each item
### in the array, and that means we can use its return value as an array index.

### Keep in mind that this is a bad idea for mutable arrays because the order of the items in the array can change
### at any time, but here our array won't ever change so it's safe.

### The second section holds three toggle switches bound to `specialRequestEnabled`, `extraFrosting`, and
### `addSprinkles` respectively. However, the second and third switches should only be visible when the first
### one is enabled, so we'll wrap them in a condition.

```swift
// Inside `ContentView`
var extraInfoView: some View {
    Group {
        Toggle("Add extra frosting", isOn: $order.extraFrosting)
        Toggle("Add extra sprinkles", isOn: $order.addSprinkles)
    }
}

// Inside `Form`
Section {
    Toggle("Any special requests?", isOn: $order.specialRequestEnabled)
    if order.specialRequestEnabled {
        extraInfoView
    }
}
```
### However, there's a bug in the code above, and it's one of our own making: if we *enable* special requests then
### enable one or both of our "extra frosting" and "extra sprinkles," then *disable* the special requests, our
### previous special request selection (either or both "extra frosting" and "extra sprinkles") stays active.
### This means that if we re-enable special requests, the previous special requests are still active.

### This kind of problem isn't hard to work around if every layer of your code is aware of it - if the app,
### your server, your database, and so on are all programmed to ignore the values of `extraFrosting` and
### `addSprinkles` when `specialRequestEnabled` is set to false. However, a better idea - a *safer* idea -
### is to make sure that both `extraFrosting` and `addSprinkles` are reset to false when `specialRequestEnabled`
### is set to false.

### We can make this happen by adding a `didSet` property observer to `specialRequestEnabled`:

```swift
// Inside `Order` class
var specialRequestEnabled: Bool  = false {
    didSet {
        if !specialRequestEnabled {
            extraFrosting = false
            addSprinkles = false
        }
    }
}
```

## Adding a Second View (`AddressView`) to Navigate to

### Our third section is just going to have a `NavigationLink` pointing to the next screen.
### We can add a second screen very quickly: we are going to create a new view 
### SwiftUI view called `AddressView`, and give it an `order` property:

```swift
import SwiftUI

struct AddressView: View {
    
    var order: Order
    
    var body: some View {
        Text("You chose ^[\(order.quantity) \(Order.types[order.type]) cupcake](inflect: true).")
    }
}

#Preview {
    AddressView(order: Order())
}
```

### In the `ContentView`, we can add the final section for our form. This will create a `NavigationLink` that
### points to an `AddressView`, passing in the current `order` object.

## Checking for a Valid Address

### The second step is to let the user enter their address into a form, but as part of that, we are going to
### perform some validation on the inputted data - we only want to proceed to the third step if their address
### looks good.

### We can accomplish this by adding a `Form` view to the `AddressView` struct we made previously, which will
### contain four text fields: 

### - name
### - street address
### - city
### - zip

### We can then add a `NavigationLink` to move them to the next screen, which is where the user will see their
### final price and can check out. 

### To perform those above-mentioned steps, we are going to first create a `CheckoutView`, which is where the
### `AddressView` will push to once the user is ready. This just avoids us having to put a placeholder in now
### then remember to come back later.

### The following is the `CheckoutView`. It is going to have an `order` property as well:

```swift
import SwiftUI

struct CheckoutView: View {
    
    var order: Order
    
    var body: some View {
        Text("Hello")
    }
}

#Preview {
    CheckoutView(order: Order())
}
```

### Let's now implement our `AddressView`. As we mentioned, the `AddressView` needs to have
### a form with four text fields bound to four properties from our `Order` object. Also, it is
### going to have a `NavigationLink` passing control off to our `Checkout` view:

```swift
struct AddressView: View {
    
    @Bindable var order: Order
    
    var body: some View {
        Form {
            Section("Name") {
                TextField("Enter your name", text: $order.name)
            }
            
            Section("Street Address") {
                TextField("Enter your street address", text: $order.streetAddress)
            }
            
            Section("City") {
                TextField("Enter your city", text: $order.city)
            }
            
            Section("Zip") {
                TextField("Enter your zip", text: $order.zip)
            }
                          
            Section {
                NavigationLink("Check out", destination: CheckoutView(order: order))
            }
        }
        .navigationTitle("Delivery Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

### The code above passes our `Order` object one level deeper, to `CheckoutView`, which means we now have
### three views pointing to the same data.

### The code will throw up a lot of errors, but it takes one small change to fix them - add the `@Binding`
### property wrapper to the `order` variable.

```swift
@Bindable var order: Order
```

### Previously, we have seen how Xcode lets us bind to local `@State` properties, even when those properties
### are classes using the `@Observable` macros. The binding works because the `@State` property wrapper
### automatically creates two-way bindings for us, which we access through the `$` syntax - `$name`, `$age`,
### etc.

### We haven't used the `@State` property wrapper in `AddressView` because we aren't creating a class local
### to that view; instead, we are just receiving it from elsewhere. This means that SwiftUI doesn't have access
### to the same two-way bindings we'd normally use, which is a problem.

### Now, we *know* this class uses the `@Observable` macro, which means that SwiftUI is able to watch that
### data for changes. However, what is missing here is the possibility to have a premade two-way binding system
### - which we can access to via the `$` syntax - that either gets or sets any of that `@Observable` `Order` class
### properties. So, what the `@Bindable` property wrapper does is create the missing bindings for us - it produces
### the two-way bindings that are able to work with the `@Observable` macro, *without* having to use `@State`
### to create local data. In other words, `@Bindable` is a property wrapper that supports creating bindings to
### the mutable properties of the observable objects.

### Why all this matters?

### You'll notice that, if you enter some data in the first screen, enter some data on the second screen, then
### try to navigate back to the beginning then forward to the end.

### What you should see is that all the data you entered stays saved no matter what screen you are on. Yes, this
### is the natural side effect of using a class for our data, but it's an instant feature in our app without having
### to do any work - if we had used local state properties on `AddressView`, then any address details we had entered
### would disappear if we moved back to the original view.

### Validating Data

### Now that `AddressView` works, it's time to stop the user progressing to checkout unless some condition is
### satisfied. What condition? Well, that's down to us to decide. Although we could write length checks for each
### of our four text fields, this often trips people up - some names are only four or five letters, so if you try to
### add length validation you might accidentally exclude people.

### So, instead, we are just going to check whether the `name`, `streetAddress`, `city`, and `zip` properties of our
### order aren't empty. 
### We are going to add the following computed property in the `Order` class to compute that specific validation:

```swift
// In the `Order` class
var isValidAddress: Bool {
    if name.isEmpty || streetAddress.isEmpty || city.isEmpty || zip.isEmpty {
        return false
    }
    return true
}
```

### We can now use that condition above in conjunction with the `disabled()` modifier, which will have the view
### stop responding to any user interaction if the condition is true.

### We are going to check the `isValidAddress` computed property, and if it resolves to `false` we want to disable
### the form section containing the `NavigationLink`, because we need the user to fill in their delivery details
### first.

```swift
// Form section in `AddressView`
Section {
    NavigationLink("Check out", destination: CheckoutView(order: order))
}
.disabled(!isValidAddress)
```

## Preparing for Checkout

### The final screen in our app is `CheckoutView`, and it's really a tale of two halves.

- The first half: Basic user interface - we are going to create a `ScrollView` with an image, the total price
  of their order, and a "Place Order" button to kick off the networking.

- The second half: Encoding `Order` class to JSON, send it over the internet, and getting a response.

### First Half

### For the image, we are going to use a cupcake image that we are going to load remotely with `AsyncImage`. 

### As for the order cost, we are going to implement the pricing in our `Order` class, which is responsible for
### holding the data (Model).

### The pricing we are going to use is as follows:

### - There's a base cost of $2 per cupcake.

### - We'll add a little to the cost for more complicated cupcakes.

### - Extra frosting will cost $1 per cake.

### - Adding sprinkles will be another 50 cents per cake.

### We can wrap up all the logic in a computed property for `Order` like this.

```swift
@Observable
Order {
    var cost: Decimal {
    
        // $2 per cake
        var cost = Decimal(quantity) * 2.0
        
        // complicated cakes cost more
        cost += Decimal(type) / 2
        
        // $1/cake for extra frosting
        if extraFrosting {
            cost += Decimal(quantity)
        }
        
        // $0.50/cake for sprinkles
        if addSprinkles {
            cost += Decimal(quantity) / 2
        }
        
        return cost
    }
}
```

### The actual view itself is straightforward, we are going to use a `VStack` inside a vertical `ScrollView`, then
### our image, the cost text, and a button to place the order.

```swift
struct CheckoutView: View {
    
    var order: Order
    
    var body: some View {
        ScrollView {
            VStack {
                
                // Load remote image
                AsyncImage(url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg"), scale: 3) { image in
                    
                    image
                        .resizable()
                        .scaledToFit()
                    
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233)
                
                // Total order cost
                Text("Your total is \(order.cost, format: .currency(code: "USD"))")
                
                // Button to place order
                Button("Place order", action: {})
                    .padding()
            }
            .navigationTitle("Check out")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
```

### Using scroll views is a great way to make sure your layouts work great no matter what Dynamic Type size the
### user has enabled, but it creates a small annoyance: when our views fit just fine on a single screen, they still
### bounce a little when the user moves up and down on them.

### The solution to that is using the `scrollBounceBehavior(:_)` modifier. This modifier helps us disable that
### bounce when there is nothing to scroll. 

### When we use `scrollBounceBehavior(.basedOnSize)`, we get a nice scroll bouncing when we actually have scrolling
### content, otherwise scroll view acts like it isn't even there.


