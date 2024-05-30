
# In App Purchase Manager - [Apphud](https://docs.apphud.com/docs/quickstart)

## Getting Started
### 1. Install via Swift Package Manager
1.  In Xcode go to  _File_  >  _Swift Packages_  >  _Add Package Dependency..._
2.  Enter the repository URL  `https://github.com/DinoAppsDevs/InAppPurchaseManager.git`
3.  Choose the version, and click Next. Xcode will add the package dependency to your project, and you can import it.

### 2. Importing, configuring, and setting up the logging
In your `AppDelegate` class:
```swift
import InAppPurchaseManager
```
And add the following to `application(_:didFinishLaunchingWithOptions:):`
```swift
InAppPurchaseManager.start(apphudApiKey: "YOUR_API_KEY", userID: "USER_ID", debugLogs: Bool)
```

### 3.  Fetching paywalls data

The Apphud SDK allows you to remotely configure the products that will be displayed in your app. This way you don't have to hardcode the products and can dynamically change offers or run A/B tests without having to release a new version of the app.

To fetch the paywall, you have to call `.getPaywallData(identifier: PaywallID)` method:
```swift
let paywallModel: PaywallModel = await InAppPurchaseManager.getPaywallData(identifier: PaywallID)
```
PaywallID is extendable struct of typed paywall identifiers:
```swift
struct  PaywallID : RawRepresentable, Equatable, Hashable {
    static let main = PaywallID(rawValue: "main_paywall")!
    static let onboarding = PaywallID(rawValue: "onboarding_paywall")!
...
}
...getPaywallData(identifier: .onboarding)
```

PaywallModel already contains 
- Products
- Dictionary introOfferEligiblities with the availability of a trial for these products for the current user
- Remote config with some predefined properties:
- Apphud paywall model

```swift
public  struct  PaywallModel {
    public let paywallID: String { apphudPaywall.identifier }
    public let apphudPaywall: ApphudPaywall
    public let products: [Product]
    public let introOfferEligiblities: [String: Bool]
    public let config: Config?
...
}
```

### 4. Making and restoring mobile purchases

To make the purchase, you have to call `.purchase()` method:
```swift
let product = paywallModel.products.first

// Make a purchase
let result = await InAppPurchaseManager.purchase(Product)
let result = await InAppPurchaseManager.purchase(Product, isPurchasing: Binding<Bool>? = nil) // SwiftUI
```

To make the purchase, you have to call `.restorePurchases()` method:

### 5. Getting info about the user subscription status and granting access to the premium features of the app

You just have to verify that the user has an active premium status. To do this, you have to call `.getProfile()` method:
```swift
@MainActor static var isPremium: Bool

if InAppPurchaseManager.isPremium {
	...
}
```

### 6. Request user's IDFA
You have to request IDFA during first app start
```swift
AdIdsRequester.requestIDFA(completion: ((ATTrackingManager.AuthorizationStatus) -> Void))
	or
await AdIdsRequester.requestIDFA()
```
Add **Privacy - Tracking Usage Description** (`NSUserTrackingUsageDescription`) to your app's `Info.plist`


### 7.  Integrate Apphud Push Notifications
- Set Push Notifications on in  _"Capabilities"_  section of your app target

- Register for notifications:
```swift
import  UserNotifications

func  application(_  application:  UIApplication,  didFinishLaunchingWithOptions  launchOptions:  [UIApplication.LaunchOptionsKey:  Any]?)  ->  Bool  {
    ...
    registerForNotifications() // Register in didFinishLaunchingWithOptions
}

func registerForNotifications() {
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in }
    UIApplication.shared.registerForRemoteNotifications()
}

func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Apphud.submitPushNotificationsToken(token: deviceToken, callback: nil) // Send token to Apphud
}

func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    Apphud.handlePushNotification(apsInfo: response.notification.request.content.userInfo) // let Apphud handle notification
    completionHandler()
}

func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
	Apphud.handlePushNotification(apsInfo: notification.request.content.userInfo) // let Apphud handle notification
	completionHandler([.banner, .list, .badge, .sound])
}
```

### 8. Paywall Controller
For the Paywall Controller, there is a protocol called `PaywallViewController` with default methods `configure` that allow you to request the necessary data and check if the paywall can be shown at the moment
```swift
public protocol PaywallViewController: UIViewController {
    func setPaywallData(paywallModel: PaywallModel)
    func configure(paywallId: PaywallID, presentationController: UIViewController?) async throws
    func configureAndPresent(paywallId: PaywallID, presentationController: UIViewController?) async throws
}
```
 All paywall controllers should conform to this protocol or implement the same logic. 
 **Before** showing the paywall, you need:
- Check the internet connection.
- Verify that the current user does **not** have a **premium** status.
- Ensure that another paywall is not already displayed.
- Check if there is a prohibition on showing the paywall on the current screen.
- Load the paywall data and ensure that it is valid.

If an error occurs during the verification of these points, the paywall should not be displayed.

### 9. Log Paywall Shown
You must call method `paywallShown()` when paywall controller was shown (could be call in viewDidAppear) 
```swift
Apphud.paywallShown(paywallModel.apphudPaywall) 
```

And call method `paywallClosed()` when paywall controller was closed (could be call in viewDidDisappear)
```swift
Apphud.paywallClosed(paywallModel.apphudPaywall) 
```

### 10. Displaying Paywall and Products
**Все** цены, периоды и значения должны отображаться **динамически**. 
Необходимо иметь возможность в любой момент изменить продукт, его цену, период, доступность триала и продолжительность триала. Например, текст `3 days free trial, then 4.99$ per week`, при смене продукта на месячную подписку без триала, должен без новых изменений в коде стать  `9.99$ per month`
Так же необходимо проверять, есть у пользователя возможность взять триал у продукта с триалом (т.к пользователь мог взять триал и отменить подписку). И, соответственно, изменить UI так, чтобы показать пользователю, что триал ему более недоступен.

Продукты отображаем в том порядке, в котором они приходят с сервера, если нет необходимости отобразить, определенный продукт в конкретном месте (например, триальный продукт должен быть в отдельной кнопке или быть самым первым. Но если такой продукт вообще не пришел -- учитываем порядок продуктов)

Для отображения **оригинальной** цены продукта используем `Product.displayPrice`. Для **форматированной** цены (например, цена годовой подписки в месяц) используем методы из `Product+Extension` или форматируем через `PriceFormatter`

### 11. Product+Extension.swift
`Product+Extension.swift` содержит вспомогательные расширения для StoreKit 2, такие как:
- Выражение цены подписки в любом периоде (день, неделя, месяц, год)
- Локализация валюты цены 
- Форматирование отображения цены
- Локализация и разные форматы вывода периодов подписки
- Проверка существует ли триал и его продолжительность
- Генерация форматированных строк об интро офферах
