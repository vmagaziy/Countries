# Countries
Sample iOS application to get information about countries of the world.

## Build instructions

Update submodules to get country flags by executing the following commands:

```
git submodule init
git submodule update
```

## Min spec

Supposed to be running on iOS 8 and later.

## Summary

Information about countries are retrieved from [here](https://restcountries.eu/rest/v2/all) and stored in the persistent storage driven by [CoreData](https://developer.apple.com/reference/coredata).

Necessary updates are abstracted by `RTCountriesDataProvider` and stored in the background context and saved the view context in butch generating corresponding changes needed to refresh UI. The provider uses `NSURLSession` to obtain data and process it in the background not to block UI.

`NSFetchedResultsController` is used to generate corresponding UI updates in the table view and filter the list of countries.

The UI is not bound to a predefined form factor of device, but the [Master-Detail Interface](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CocoaBindings/Tasks/masterdetail.html) is used to present the list of countries and information about them.

Story boards are used for defining relationship between view controllers and `NSLocalizedString` is used for localisations.

[Pull to refresh](https://en.wikipedia.org/wiki/Pull-to-refresh) is used to update information about countries.

## Whats next

- Test Harness: not currently implemented for the sake of simplicity, but network calls can be stubbed using the [**OHHTTPStubs**](https://github.com/AliSoftware/OHHTTPStubs) framework and at lest data provider can be verified
- Information about country names is not localised, so it has to be worked out properly for corresponding internationalisation, moreover current implementation of grouping and filtering has to be adjusted
- Country flags are currently static resources increasing the bundle size, information about countries contains links to corresponding SVG assets. Since it's not possible to render SVG on iOS without external libraries it was decided not to use them, but having them downloaded and rendered is really big win as country flags are formed from simple primitives, so SVG files are lightweight, and their rendered versions could be cached and reused.
- At the moment not all available information about countries is presented, so it has to be expanded.
