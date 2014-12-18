//
//  DataViewController.m
//  lab2
//
//  Created by mac on 11/24/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import "DataViewController.h"

@interface DataViewController ()

@end

@implementation DataViewController
CLLocationManager *locationManager;
CLLocation *currentLocation;


- (void)viewDidLoad
{
    sleep(5);
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

#pragma mark CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations objectAtIndex:0];
//    [locationManager stopUpdatingLocation];
    NSLog(@"Detected Location : %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
                       [self displayLocation:placemark];
                       [self displayForecastByLocation:currentLocation];
                       
                   }];
}
-(void)displayLocation:(CLPlacemark *)placemark{
    self.responseData = @"";
    [self.locationLabel setText:[NSString stringWithFormat: @"Valstybė: %@", placemark.country]];
    [self.locationLabel2 setText:[NSString stringWithFormat: @"Miestas: %@", placemark.locality]];
    [self.locationLabel3 setText:[NSString stringWithFormat: @"Gatvė: %@", placemark.thoroughfare]];

}

-(void)displayForecastByLocation:(CLLocation *)placemark{
    NSString *urlCall = [[NSString alloc] initWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=1&mode=json&units=metric", placemark.coordinate.latitude, placemark.coordinate.longitude];
    
    NSURL *url = [NSURL URLWithString:urlCall];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];   
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    NSString *string = self.responseData;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\"day\":.*,\"min" options:NSRegularExpressionCaseInsensitive error:&error];
    [regex enumerateMatchesInString:string
                            options:0
                              range:NSMakeRange(0, string.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         NSLog(@"Match at [%d, %d]", result.range.location, result.range.length);
         NSString *putLabel = [string substringWithRange:NSMakeRange (result.range.location+6, result.range.length-11)];
         [self.temperLabel setText:[[NSString alloc] initWithFormat:@"%@ C", putLabel]];
         
     }];
    

    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"\"description\":.*,\"icon" options:NSRegularExpressionCaseInsensitive error:&error];
    [regex2 enumerateMatchesInString:string
                            options:0
                              range:NSMakeRange(0, string.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         NSLog(@"Match at [%d, %d]", result.range.location, result.range.length);
         NSString *putLabel = [string substringWithRange:NSMakeRange (result.range.location+15, result.range.length-22)];
         [self.descLabel setText:[[NSString alloc] initWithFormat:@"Detaliau: %@", putLabel]];
         
     }];
    
    NSRegularExpression *regex3 = [NSRegularExpression regularExpressionWithPattern:@"\"main\":.*,\"desc" options:NSRegularExpressionCaseInsensitive error:&error];
    [regex3 enumerateMatchesInString:string
                             options:0
                               range:NSMakeRange(0, string.length)
                          usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
                  NSString *putLabel = [string substringWithRange:NSMakeRange (result.range.location+8, result.range.length-15)];
         
         NSLog(@"%@", putLabel);
         if([putLabel isEqualToString:@"Clear"]){
             self.image.image = [UIImage imageNamed:@"sunny.jpg"];
         }
         
         if([putLabel isEqualToString:@"Rain"]){
             self.image.image = [UIImage imageNamed:@"raing.png"];
         }
         
         if([putLabel isEqualToString:@"Clouds"]){
             self.image.image = [UIImage imageNamed:@"cloud.png"];
         }
//         self.image.image = [UIImage imageNamed:@"sunny.jpg"];
         //[self.descLabel setText:[[NSString alloc] initWithFormat:@"Detaliau: %@", putLabel]];
         
     }];
    
    self.responseData = @"";
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.responseData = [[NSString alloc] initWithFormat:@"%@ %@", self.responseData, result];
    [self.temperLabel setText:@"37 C"];
    //NSLog(self.responseData);
    
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject description];
}

@end
