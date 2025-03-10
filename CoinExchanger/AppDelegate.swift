//
//  AppDelegate.swift
//  CoinExchanger
//
//  Created by Edson Rottava on 02/09/21.
//

import UIKit

let DEBUG = false

let userPrefs = UserDefaults()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navigationController: UINavigationController?
    fileprivate var loadFonts: [String] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupApp(with: launchOptions)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return validateURL(url)
    }
}

private extension AppDelegate {
    // MARK: Setup
    func setupApp(with lauchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        loadAllFonts()
        validadeUserDefaults()
        
        navigationController = RegularNavigationController(ConverterController())
        
        validateOptions(lauchOptions)
        prepareNavController()
        
        debug()
    }
    
    // MARK: Add font
    /// Load font if not already
    func addFont(_ name: String) {
        if (loadFonts.contains(name)) {
            return
        } else {
            loadFonts.append(name)
            registerFontWithFilenameString(name)
        }
    }
    
    // MARK: Load custom fonts
    func loadAllFonts() {
        // Load default framework fonts
        addFont("Moderat-Black-Italic")
        addFont("Moderat-Black")
        addFont("Moderat-Bold-Italic")
        addFont("Moderat-Bold")
        addFont("Moderat-Light-Italic")
        addFont("Moderat-Light")
        addFont("Moderat-Medium-Italic")
        addFont("Moderat-Medium")
        addFont("Moderat-Regular-Italic")
        addFont("Moderat-Regular")
        addFont("Moderat-Thin-Italic")
        addFont("Moderat-Thin")
    }
    
    // MARK: Prepare NavController
    func prepareNavController() {
        navigationController?.navigationBar.backgroundColor = Asset.Colors.primary.color
        //navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]
        navigationController?.setNavigationBarHidden(true, animated: true)
        //navigationController?.view.backgroundColor = Asset.Colors.primary.color
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    // MARK: Register font
    /// Add support to @Param font with .TTF extension
    func registerFontWithFilenameString(_ filenameString: String) {
        guard let pathForResourceString = Bundle.main.path(forResource: filenameString, ofType: "ttf") else { return }
        guard let fontData = NSData(contentsOfFile: pathForResourceString) else { return }
        guard let dataProvider = CGDataProvider(data: fontData) else { return }
        guard let fontRef = CGFont(dataProvider) else { return }
        var errorRef: Unmanaged<CFError>? = nil
        
        if (CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) == false) {
            print("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }
    
    // MARK: Validate Options (Deep Link)
    func validateOptions(_ options: [UIApplication.LaunchOptionsKey: Any]?) {
    }
    
    // MARK: Validate Url (Deep Link)
    func validateURL(_ url: URL) -> Bool {
        return false
    }
    
    // MARK: UserDefaults
    func validadeUserDefaults() {
        if(userPrefs.date.isEmpty) { userPrefs.date = "04/09/2021" }
        if(userPrefs.origin.isEmpty) { userPrefs.origin = Constants.code }
        if(userPrefs.target.isEmpty) { userPrefs.target = Constants.code }
        if(!userPrefs.reset) { prepareFirstLoad() }
    }
    
    func prepareFirstLoad() {
        do {
            guard let coinsBundlePath = Bundle.main.path(forResource: "coins", ofType: "json") else { return }
            guard let coinsJsonData = try String(contentsOfFile: coinsBundlePath).data(using: .utf8) else { return }
            let coins = try JSONDecoder().decode(GetCoinsResponse.self, from: coinsJsonData)
            Storage.store(coins, to: .caches, as: Constants.coinFile)
            
            guard let ratesBundlePath = Bundle.main.path(forResource: "rates", ofType: "json") else { return }
            guard let ratesJsonData = try String(contentsOfFile: ratesBundlePath).data(using: .utf8) else { return }
            let rates = try JSONDecoder().decode(GetRatesResponse.self, from: ratesJsonData)
            Storage.store(rates, to: .caches, as: Constants.quoteFile)
            
            userPrefs.reset = true
        } catch let jsonError {
            print("Erro: \(jsonError.localizedDescription)")
        }
    }
    
    func debug() {
        if (DEBUG) {
            print("DEBUG IS ON!")
        }
    }
}

