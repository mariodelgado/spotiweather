//
//  KFOWMDailyForecastListModel.h
//  KFOpenWeatherMapAPI
//
//  Copyright (c) 2013 Rico Becker, KF Interactive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
#import "JSONModel.h"

@class KFOWMForecastTemperatureModel;

@protocol KFOWMWeatherModel;


/**
 *  Contains all forecast data.
 */
@interface KFOWMDailyForecastListModel : JSONModel


/**
 *  The local date and time.
 */
@property (nonatomic, strong) NSDate *dt;


/**
 *  The air pressure.
 */
@property (nonatomic, strong) NSNumber *pressure;


/**
 *  The humidity value.
 */
@property (nonatomic, strong) NSNumber *humidity;


/**
 *  The amount of rain.
 */
@property (nonatomic, strong) NSNumber<Optional> *rain;


/**
 *  The wind speed.
 */
@property (nonatomic, strong) NSNumber *windSpeed;

/**
 *  The wind gust.
 */
@property (nonatomic, strong) NSNumber<Optional> *windGust;


/**
 *  The wind direction in degrees.
 */
@property (nonatomic, strong) NSNumber *windDeg;


/**
 *  A list of `KFOWMWeatherModel`s.
 */
@property (nonatomic, strong) NSArray<KFOWMWeatherModel> *weather;


/**
 *  A collection of temperatures during the day.
 */
@property (nonatomic, strong) KFOWMForecastTemperatureModel *temperature;


@end
