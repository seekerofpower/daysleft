//
//  ComplicationsDataSource.swift
//  daysleft
//
//  Created by John Pollard on 12/10/2015.
//  Copyright © 2015 Brave Location Software. All rights reserved.
//

import Foundation
import WatchKit
import ClockKit

class ComplicationsDataSource : NSObject, CLKComplicationDataSource {
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let entry = self.createTimeLineEntry(complication.family, date:Date())
        handler(entry)
    }
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        // Update at the start of tomorrow
        let model = modelData()
        let nextUpdate = model.StartOfDay(model.AddDays(Date(), daysToAdd: 1))
        
        print("Setting next extension update to be at \(nextUpdate)")
        
        handler(nextUpdate)
    }
    
    func getLocalizableSampleTemplate(for complication: CLKComplication,
                                      withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let appTintColor = UIColor(red: 203/255, green: 237/255, blue: 142/255, alpha: 1.0)

        switch complication.family {
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "--")
            template.fillFraction = 0.7
            template.ringStyle = CLKComplicationRingStyle.open
            handler(template)
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "--")
            template.fillFraction = 0.7
            template.ringStyle = CLKComplicationRingStyle.open
            handler(template)
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "--")
            template.fillFraction = 0.7
            template.ringStyle = CLKComplicationRingStyle.open
            handler(template)
        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: "--")
            handler(template)
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: "--")
            handler(template)
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeRingText()
            template.textProvider = CLKSimpleTextProvider(text: "--")
            template.fillFraction = 0.7
            template.ringStyle = CLKComplicationRingStyle.open
            handler(template)
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "Christmas")
            template.body1TextProvider = CLKSimpleTextProvider(text: "30 days")
            template.body2TextProvider = CLKSimpleTextProvider(text: "10% done")
            handler(template)
        case .graphicBezel:
            if #available(watchOS 5,*) {
                let template = CLKComplicationTemplateGraphicBezelCircularText()
                template.tintColor = appTintColor
                
                template.textProvider = CLKSimpleTextProvider(text: "20 days until Christmas")
                
                let gaugeProvider = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()
                gaugeProvider.centerTextProvider = CLKSimpleTextProvider(text: String("20"))
                gaugeProvider.bottomTextProvider = CLKSimpleTextProvider(text: String(format: "%d%%", 10))
                
                let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: 0.1)
                gaugeProvider.gaugeProvider = gauge
                template.circularTemplate = gaugeProvider
                
                handler(template)
            }
            break
        case .graphicCorner:
            if #available(watchOS 5,*) {
                let template = CLKComplicationTemplateGraphicCornerGaugeText()
                template.outerTextProvider = CLKSimpleTextProvider(text: "20 days")
                
                let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: 0.1)
                template.gaugeProvider = gauge
                
                template.tintColor = appTintColor
                handler(template)
            }
            break
        case .graphicCircular:
            if #available(watchOS 5,*) {
                let template = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()
                template.centerTextProvider = CLKSimpleTextProvider(text: "20")
                template.bottomTextProvider = CLKSimpleTextProvider(text: String(format: "%d%%", 10))
                
                let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: 0.1)
                template.gaugeProvider = gauge
                
                template.tintColor = appTintColor
                handler(template)
            }
            break
        case .graphicRectangular:
            if #available(watchOS 5,*) {
                let template = CLKComplicationTemplateGraphicRectangularStandardBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: "Christmas")
                template.body1TextProvider = CLKSimpleTextProvider(text: "20 days")
                template.body2TextProvider = CLKSimpleTextProvider(text: String(format: "%d%% done", 0.1))
                template.tintColor = appTintColor
                
                handler(template)
            }
            break
        default:
            handler(nil)
        }
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Show the complication on the lock screen
        handler(CLKComplicationPrivacyBehavior.hideOnLockScreen)
    }
    
    // --- Timeline functions ---

    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        print("Getting timeline: \(limit) before \(date)")

        var entries: [CLKComplicationTimelineEntry] = [];
        
        for i in (1...limit).reversed() {
            // Calculate the entry i * 5 mins ago (in chronological order)
            let previousDate = date.addingTimeInterval(-1*60*5*Double(i))
            let entry = self.createTimeLineEntry(complication.family, date:previousDate);
            if (entry != nil) {
                entries.append(entry!)
            }
        }

        handler(entries)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        print("Getting timeline: \(limit) before \(date)")

        var entries: [CLKComplicationTimelineEntry] = [];
        
        for i in 1...limit {
            // Calculate the entry i x 5 mins ahead
            let previousDate = date.addingTimeInterval(60*5*Double(i))
            let entry = self.createTimeLineEntry(complication.family, date:previousDate);
            if (entry != nil) {
                entries.append(entry!)
            }
        }
        
        handler(entries)
    }
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([CLKComplicationTimeTravelDirections.backward, CLKComplicationTimeTravelDirections.forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(modelData().start as Date)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(modelData().end as Date)
    }
    
    func getTimelineAnimationBehavior(for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineAnimationBehavior) -> Void) {
            handler(CLKComplicationTimelineAnimationBehavior.always)
    }
    
    // Internal helper methods
    fileprivate func modelData() -> WatchDaysLeftModel {
        let appDelegate = WKExtension.shared().delegate as! ExtensionDelegate
        return appDelegate.model
    }
    
    fileprivate func createTimeLineEntry(_ family: CLKComplicationFamily, date: Date) -> CLKComplicationTimelineEntry? {

        let model = modelData()
        let currentDaysLeft: Int = model.DaysLeft(date)
        let percentageDone: Float = Float(model.DaysGone(date)) / Float(model.DaysLength)
        let displayPercentageDone: Int = (Int) (percentageDone * 100)
        let appTintColor = UIColor(red: 203/255, green: 237/255, blue: 142/255, alpha: 1.0)
        
        var entry : CLKComplicationTimelineEntry?

        switch family {
            case .circularSmall:
                let template = CLKComplicationTemplateCircularSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                template.fillFraction = percentageDone
                template.ringStyle = CLKComplicationRingStyle.open
                template.tintColor = appTintColor
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .modularSmall:
                let template = CLKComplicationTemplateModularSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                template.fillFraction = percentageDone
                template.ringStyle = CLKComplicationRingStyle.open
                template.tintColor = appTintColor
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .utilitarianSmall:
                let template = CLKComplicationTemplateUtilitarianSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                template.fillFraction = percentageDone
                template.ringStyle = CLKComplicationRingStyle.open
                template.tintColor = appTintColor
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .utilitarianSmallFlat:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                template.tintColor = appTintColor
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .utilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                template.tintColor = appTintColor
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .extraLarge:
                let template = CLKComplicationTemplateExtraLargeRingText()
                template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                template.fillFraction = percentageDone
                template.ringStyle = CLKComplicationRingStyle.open
                template.tintColor = appTintColor
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .modularLarge:
                let template = CLKComplicationTemplateModularLargeStandardBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: model.title)
                template.body1TextProvider = CLKSimpleTextProvider(text: String(format: "%d days", currentDaysLeft))
                template.body2TextProvider = CLKSimpleTextProvider(text: String(format: "%d%% done", displayPercentageDone))
                template.tintColor = appTintColor
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .graphicBezel:
                if #available(watchOS 5,*) {
                    let template = CLKComplicationTemplateGraphicBezelCircularText()
                    template.tintColor = appTintColor
                    
                    let longDesc = String(format: "%d %@ until %@", currentDaysLeft, model.weekdaysOnly ? "weekdays" : "days", model.title)
                    template.textProvider = CLKSimpleTextProvider(text: longDesc)
                    
                    let gaugeProvider = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()
                    gaugeProvider.centerTextProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                    gaugeProvider.bottomTextProvider = CLKSimpleTextProvider(text: String(format: "%d%%", displayPercentageDone))
                    
                    let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: percentageDone)
                    gaugeProvider.gaugeProvider = gauge
                    template.circularTemplate = gaugeProvider
                    
                    entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
                }
                break
            case .graphicCorner:
                if #available(watchOS 5,*) {
                    let template = CLKComplicationTemplateGraphicCornerGaugeText()
                    let daysDesc = String(format: "%d days", currentDaysLeft)
                    template.outerTextProvider = CLKSimpleTextProvider(text: daysDesc)
                    
                    let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: percentageDone)
                    template.gaugeProvider = gauge

                    template.tintColor = appTintColor
                    entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
                }
                break
            case .graphicCircular:
                if #available(watchOS 5,*) {
                    let template = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()
                    template.centerTextProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                    template.bottomTextProvider = CLKSimpleTextProvider(text: String(format: "%d%%", displayPercentageDone))
                    
                    let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: percentageDone)
                    template.gaugeProvider = gauge
                    
                    template.tintColor = appTintColor
                    entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
                }
                break
            case .graphicRectangular:
                if #available(watchOS 5,*) {
                    let template = CLKComplicationTemplateGraphicRectangularStandardBody()
                    template.headerTextProvider = CLKSimpleTextProvider(text: model.title)
                    template.body1TextProvider = CLKSimpleTextProvider(text: String(format: "%d days", currentDaysLeft))
                    template.body2TextProvider = CLKSimpleTextProvider(text: String(format: "%d%% done", displayPercentageDone))
                    template.tintColor = appTintColor
                    
                    entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
                }
                break
            default:
                break
        }
        
        return(entry)
    }
}
