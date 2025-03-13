//
//  CalendarTimelineView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/26/25.
//

import SwiftUI

struct Event: Identifiable {
    var id = UUID().uuidString
    var startDate: Date
    var endDate: Date
    var title: String
}

struct CalendarTimelineView: View {
    @State private var events: [Event] = [
        Event(startDate: dateFrom(9,5,2023,7,0),  endDate: dateFrom(9,5,2023,8,0),  title: "Event 1"),
        Event(startDate: dateFrom(9,5,2023,9,0),  endDate: dateFrom(9,5,2023,10,0), title: "Event 2"),
        Event(startDate: dateFrom(9,5,2023,11,0), endDate: dateFrom(9,5,2023,12,0), title: "Event 3"),
        Event(startDate: dateFrom(9,5,2023,13,0), endDate: dateFrom(9,5,2023,14,45), title: "Event 4"),
        Event(startDate: dateFrom(9,5,2023,15,0), endDate: dateFrom(9,5,2023,18,30), title: "Event 5"),
    ]
    
    @State private var draggingEvent: Event?
    
    let date: Date = dateFrom(9, 5, 2023)
    let timelineStartHour = 1
    let timelineEndHour = 24
    let hourHeight: CGFloat = 75
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(date.formatted(.dateTime.day().month()))
                        .bold()
                    Text(date.formatted(.dateTime.year()))
                }
                .font(.title)
                
                Text(date.formatted(.dateTime.weekday(.wide)))
            }
            .padding()
            
            // Scrollable timeline
            ScrollView {
                ZStack(alignment: .topLeading) {
                    
                    // Hour lines + hour labels
                    ForEach(timelineStartHour...timelineEndHour, id: \.self) { hour in
                        let yPos = CGFloat(hour - timelineStartHour) * hourHeight
                        
                        HStack(spacing: 8) {
                            Text("\(hour)")
                                .font(.caption)
                                .frame(width: 30, alignment: .trailing)
                            Color.gray
                                .frame(height: 1)
                        }
                        .offset(x: 0, y: yPos)
                    }
                    

                    if let draggingEvent {
                        
                        DraggableEventView(
                            event: .constant(draggingEvent),
                            timelineStartHour: timelineStartHour,
                            hourHeight: hourHeight,
                            draggingEvent: { _, _ in},
                            eventAction: { _ in })
                        .opacity(0.6)
                        
                    }

                    // Draggable events
                    ForEach($events) { $event in
                        
                        DraggableEventView(
                            event: $event,
                            timelineStartHour: timelineStartHour,
                            hourHeight: hourHeight
                        ) { draggableEvent, offset in
                            
                            self.draggingEvent = offset != 0 ? draggableEvent : nil
                            
                        } eventAction: { proposedEvent in
                            
                            // Look for overlap
                            
                            let eventsWithoutSelf = self.events.filter({ $0.id != proposedEvent.id})
                            let firstEvent = eventsWithoutSelf.first { event in
                                
                                let leftRange = proposedEvent.startDate...proposedEvent.endDate
                                let rightRange = event.startDate...event.endDate
                                
                                if leftRange.upperBound == rightRange.lowerBound || leftRange.lowerBound == rightRange.upperBound {
                                    
                                    return false
                                    
                                } else {
                                    
                                    return leftRange.overlaps(rightRange)
                                    
                                }
                                
                            }
                            
                            if let firstEvent {
                               
                                print("INTERSECTS")
                                
                            } else {
                                
                                let index = self.events.firstIndex(where: { $0.id == proposedEvent.id }) ?? -1
                                self.events[index] = proposedEvent
                                
                            }
                            
                        }
                    }
                }
                .frame(
                    height: CGFloat(timelineEndHour - timelineStartHour) * hourHeight,
                    alignment: .top
                )
            }
        }
        .padding(.top, 0)
        .padding(.bottom, 0)
    }
}

struct DraggableEventView: View {
    @Binding var event: Event
    let timelineStartHour: Int
    let hourHeight: CGFloat
    let draggingEvent: (Event?, CGFloat) -> Void
    let eventAction: (Event) -> Void
    
    /// Temporary drag offset (in points) while user is dragging
    @GestureState private var dragOffset: CGFloat = 0
    /// We store the event’s original start date when the drag begins
    @State private var originalStartDate: Date = .distantPast
    
    var body: some View {
        // Current time math
        let calendar = Calendar.current
        let eventStartHour = calendar.component(.hour, from: event.startDate)
        let eventStartMinute = calendar.component(.minute, from: event.startDate)
        
        // Total minutes from the timeline start hour
        let minutesSinceTimelineStart = Double((eventStartHour - timelineStartHour) * 60 + eventStartMinute)
        
        // Convert the *live* drag offset into minutes
        // (dragOffset is in points;  hourHeight points = 60 minutes)
        let totalMinutes = minutesSinceTimelineStart + (dragOffset * (60 / hourHeight))
        
        // Final y offset in points
        let yOffset = totalMinutes * (hourHeight / 60)
        
        // Event height in points
        let durationMinutes = event.endDate.timeIntervalSince(event.startDate) / 60
        let eventHeight = durationMinutes * (hourHeight / 60)
        
        VStack(alignment: .leading, spacing: 2) {
            
            // startDate + offset
            let normalStartDate = event.startDate.formatted(.dateTime.hour().minute())
            var offsetDate: String {
                
                // Convert final drag distance to minutes
                let offsetInMinutes = dragOffset * (60 / hourHeight)
                // Round to the nearest 15 minutes
                let roundedOffsetInMinutes = (offsetInMinutes / 15).rounded() * 15 // TODO: - rule

                // Update the event’s start date by that many minutes
                let newStartDate: String = calendar.date(
                    byAdding: .minute,
                    value: Int(roundedOffsetInMinutes),
                    to: originalStartDate
                )?.formatted(.dateTime.hour().minute()) ?? ""
                
                return newStartDate
                
            }
            
            let offsetDateIfNeeded = dragOffset != 0 ? offsetDate : normalStartDate
            
            Text(offsetDateIfNeeded)
            Text(event.title).bold()
        }
        .font(.caption)
        .padding(4)
        .frame(height: eventHeight, alignment: .top)
        .frame(maxWidth: 240, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.teal.opacity(0.5))
        )
        .offset(x: 40, y: yOffset + 7)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    // Update the live drag offset in points
                    state = value.translation.height
                }
                .onChanged { _ in
                    // Capture the event's start date only once, at the beginning
                    if originalStartDate == .distantPast {
                        originalStartDate = event.startDate
                    }
                    
                    draggingEvent(event, dragOffset)
                }
                .onEnded { value in
                    
                    draggingEvent(nil, 0)
                    
                    // Convert final drag distance to minutes
                    let offsetInMinutes = value.translation.height * (60 / hourHeight)
                    // Round to the nearest 15 minutes
                    let roundedOffsetInMinutes = (offsetInMinutes / 15).rounded() * 15 // TODO: - rule

                    // Update the event’s start date by that many minutes
                    let newStartDate = calendar.date(
                        byAdding: .minute,
                        value: Int(roundedOffsetInMinutes),
                        to: originalStartDate
                    ) ?? event.startDate

                    // Keep the same duration
                    let newEndDate = calendar.date(
                        byAdding: .minute,
                        value: Int(durationMinutes),
                        to: newStartDate
                    )
                    
                    // Check for overlap with another event
                    

                    // Commit changes
//                    event.startDate = newStartDate
//                    event.endDate = newEndDate ?? event.endDate
                    
                    let newFakeEvent = Event(
                        id: event.id,
                        startDate: newStartDate,
                        endDate: newEndDate!,
                        title: event.title
                    )

                    // Reset for next drag
                    originalStartDate = .distantPast
                    eventAction(newFakeEvent)
                    
                }
            
        )
        
    }
    
}

/// Helper to create Date objects easily
func dateFrom(_ day: Int,
              _ month: Int,
              _ year: Int,
              _ hour: Int = 0,
              _ minute: Int = 0) -> Date {
    
    var comps = DateComponents()
    comps.year = year
    comps.month = month
    comps.day = day
    comps.hour = hour
    comps.minute = minute
    
    return Calendar.current.date(from: comps) ?? Date()
    
}

#Preview {
    CalendarTimelineView()
}
