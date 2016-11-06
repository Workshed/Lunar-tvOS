# Lunar-tvOS
A project for the Apple TV showcasing the amazing photography from the Apollo missions. This project pulls photos from [Flickr](https://www.flickr.com/photos/projectapolloarchive/albums)

The compiled application is published on Apples [App Store](https://itunes.apple.com/us/app/lunar-photos-from-apollo-missions/id1051637087?mt=8)

## Running the project

Prerequisite: You will need an API key from Flickr, this is available [here](https://www.flickr.com/services/apps/create/)

1. From the root of the project install the cocoapods by running the following command:

    ```
    pod install
    ```

2. With the cocoapods successfully installed open the workspace file (Apollo.xcworkspace) and add your API key and secret to AppDelegate.m

    ```
    NSString *apiKey = @"YOUR KEY";
    NSString *secret = @"YOUR SECRET";
    ```

3. Build and run
