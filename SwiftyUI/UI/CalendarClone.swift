//
//  CalendarTimelineView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/26/25.
//

import SwiftUI

// MARK: - Model

struct Event: Identifiable {
    
    var id = UUID().uuidString
    var startDate: Date
    var endDate: Date
    var title: String
    
}

// FILTER EVENTS BY DATE

// MARK: - DUMMY_DATA

var DUMMY_DATA: [Event] {
    
    return [
        
        Event(
            startDate: dateFrom(9, 5, 2023, 4, 0),
            endDate: dateFrom(9, 5, 2023, 8, 0),
            title: "Event 1")
        ,
        Event(
            startDate: dateFrom(9, 5, 2023, 9, 0),
            endDate: dateFrom(9, 5, 2023, 10, 0),
            title: "Event 2"
        ),
        Event(
            startDate: dateFrom(9, 5, 2023, 11, 0),
            endDate: dateFrom(9, 5, 2023, 12, 0),
            title: "Event 3"
        ),
        Event(
            startDate: dateFrom(9, 5, 2023, 13, 0),
            endDate: dateFrom(9, 5, 2023, 14, 45),
            title: "Event 4"
        ),
        Event(
            startDate: dateFrom(9, 5, 2023, 15, 0),
            endDate: dateFrom(9, 5, 2023, 18, 30),
            title: "Event 5"
        ),
        
    ]
    
}

// MARK: - CalendarTimelineView

struct CalendarTimelineView: View {
    
    @State private var events: [Event]
    @State private var draggingEvent: Event?
    
    private let timelineStartHour: Int = 1
    private let timelineEndHour: Int = 24
    private let timelineInterval: CGFloat = 15
    private let hourHeight: CGFloat = 75
    
    // Header
    
    private let headerDate: Date = dateFrom(9, 5, 2023)
    
    // Alert
    
    @State private var showAlert: Bool = false
    
    private var containerHeight: CGFloat {
        return CGFloat(timelineEndHour - timelineStartHour) * hourHeight
    }
    
    init(events: [Event]) {
        self.events = events
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            header()
            timelineScrollView()
            
        }
        
    }
    
    // MARK: - VIEWS
    
    private func header() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack {
                
                Text(headerDate.formatted(.dateTime.day().month()))
                    .bold()
                
                Text(headerDate.formatted(.dateTime.year()))
                
            }
            .font(.title)
            
            Text(headerDate.formatted(.dateTime.weekday(.wide)))
            
        }
        .padding()
        
    }
    
    private func timelineScrollView() -> some View {
        
        ScrollView {
            
            ZStack(alignment: .topLeading) {
                
                hourLines
                
                if let draggingEvent = self.draggingEvent {
                    originalEventPositionView(draggingEvent)
                }
                
                eventsList()
                
            }
            .frame(
                height: self.containerHeight,
                alignment: .top
            )
            
        }
        .alert("Oh no!", isPresented: self.$showAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("You cannot intersect events!")
        }

    }
    
    private var hourLines: some View {
        
        ForEach(self.timelineStartHour...self.timelineEndHour, id: \.self) { hour in
            
            let yPosition = CGFloat(hour - self.timelineStartHour) * self.hourHeight
            
            HStack(spacing: 8) {
                
                Text("\(hour)")
                    .font(.caption)
                    .frame(width: 30, alignment: .trailing)
                
                Color.gray.frame(height: 1)
                
            }
            .offset(x: 0, y: yPosition)
            
        }
        
    }
    
    private func eventsList() -> some View {
        
        ForEach($events) { $event in
            
            DraggableEventView(
                event: event,
                timelineStartHour: self.timelineStartHour,
                timelineInterval: self.timelineInterval,
                hourHeight: self.hourHeight
            ) { draggableEvent in
                
                self.draggingEvent = draggableEvent
                
            } eventAction: { proposedEvent in
                
                handleEventDragAction(proposedEvent)
                
            }
            
        }
        
    }
    
    private func originalEventPositionView(_ event: Event) -> some View {
        
        DraggableEventView(
            event: event,
            timelineStartHour: self.timelineStartHour,
            timelineInterval: self.timelineInterval,
            hourHeight: self.hourHeight,
            draggingEvent: { _ in },
            eventAction: { _ in }
        )
        .opacity(0.6)
        
    }
    
    // MARK: - BUSINESS LOGIC
    
    private func handleEventDragAction(_ proposedEvent: Event) {
        
        let eventsWithoutSelf = self.events.filter { $0.id != proposedEvent.id }
        
        if eventsWithoutSelf.contains(where: { event in
            
            let leftRange = proposedEvent.startDate...proposedEvent.endDate
            let rightRange = event.startDate...event.endDate
            
            if leftRange.upperBound == rightRange.lowerBound ||
               leftRange.lowerBound == rightRange.upperBound {
                
                return false
                
            }
            
            return leftRange.overlaps(rightRange)
            
        }) {
            
            self.showAlert = true
            
        } else if let index = self.events.firstIndex(where: { $0.id == proposedEvent.id }) {
            self.events[index] = proposedEvent
        }
        
    }
    
}

// MARK: - DraggableEventView

struct DraggableEventView: View {
    
    private let event: Event
    private let timelineStartHour: Int
    private let timelineInterval: CGFloat
    private let hourHeight: CGFloat
    private let draggingEvent: (Event?) -> Void
    private let eventAction: (Event) -> Void
    
    @GestureState private var dragOffset: CGFloat = 0
    @State private var originalStartDate: Date = .distantPast
    
    init(event: Event,
         timelineStartHour: Int,
         timelineInterval: CGFloat,
         hourHeight: CGFloat,
         draggingEvent: @escaping (Event?) -> Void,
         eventAction: @escaping (Event) -> Void) {
        
        self.event = event
        self.timelineStartHour = timelineStartHour
        self.timelineInterval = timelineInterval
        self.hourHeight = hourHeight
        self.draggingEvent = draggingEvent
        self.eventAction = eventAction
        
    }
    
    var body: some View {
        
        let (displayName, yOffset, eventHeight) = getEventOffsetData(dragOffset: self.dragOffset)
        
        eventView(
            title: displayName,
            height: eventHeight
        )
        .offset(x: 40, y: yOffset + 7)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.height
                }
                .onChanged { _ in
                    
                    if originalStartDate == .distantPast {
                        self.originalStartDate = self.event.startDate
                    }
                    
                    draggingEvent(dragOffset != 0 ? self.event : nil)
                    
                }
                .onEnded { value in
                    handleDragEnd(value)
                }
            
        )
        
    }
    
    // MARK: - VIEWS
    
    private func eventView(title: String, height: CGFloat) -> some View {
        
        return VStack(alignment: .leading, spacing: 2) {
            
            Text(title)
            
            Text(event.title)
                .bold()
            
        }
        .font(.caption)
        .padding(4)
        .frame(
            height: height,
            alignment: .top
        )
        .frame(
            maxWidth: 240,
            alignment: .leading
        )
        .background {
            
            RoundedRectangle(cornerRadius: 8)
                .fill(.indigo.opacity(0.5))
            
        }
        .overlay {
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(.black.opacity(0.5), lineWidth: 2)
            
        }
        
    }
    
    // MARK: - BUSINESS LOGIC
    
    private func getEventOffsetData(dragOffset: CGFloat) -> (displayDate: String, yOffset: CGFloat, eventHeight: CGFloat) {
        
        // Date
        
        let calendar = Calendar.current
        let eventStartHour = calendar.component(.hour, from: event.startDate)
        let eventStartMinute = calendar.component(.minute, from: event.startDate)
        
        // Time
        
        let minutesSinceTimelineStart = Double((eventStartHour - self.timelineStartHour) * 60 + eventStartMinute)
        let totalMinutes = minutesSinceTimelineStart + (dragOffset * (60 / self.hourHeight))
        let yOffset = totalMinutes * (self.hourHeight / 60)
        let durationMinutes = event.endDate.timeIntervalSince(event.startDate) / 60
        let eventHeight = durationMinutes * (self.hourHeight / 60)
        
        if dragOffset == 0 {
            
            let normalStartDate = event.startDate.formatted(.dateTime.hour().minute())
            return (normalStartDate, yOffset, eventHeight)
            
        } else {
            
            let offsetInMinutes = dragOffset * (60 / self.hourHeight)
            let roundedOffsetInMinutes = (offsetInMinutes / self.timelineInterval).rounded() * self.timelineInterval
            let diff = calendar.date(byAdding: .minute, value: Int(roundedOffsetInMinutes), to: originalStartDate)?
                .formatted(.dateTime.hour().minute()) ?? ""

            return (diff, yOffset, eventHeight)
            
        }
        
    }
    
    private func handleDragEnd(_ value: DragGesture.Value) {
        
        draggingEvent(nil)
        
        let offsetInMinutes = value.translation.height * (60 / self.hourHeight)
        let roundedOffsetInMinutes = (offsetInMinutes / self.timelineInterval).rounded() * self.timelineInterval
        let durationMinutes = event.endDate.timeIntervalSince(event.startDate) / 60
        
        let newStartDate = Calendar.current.date(
            byAdding: .minute,
            value: Int(roundedOffsetInMinutes),
            to: originalStartDate
        ) ?? event.startDate
        
        let newEndDate = Calendar.current.date(
            byAdding: .minute,
            value: Int(durationMinutes),
            to: newStartDate
        ) ?? event.endDate
        
        let updatedEvent = Event(id: event.id, startDate: newStartDate, endDate: newEndDate, title: event.title)
        
        originalStartDate = .distantPast
        eventAction(updatedEvent)
        
    }
    
}

// MARK: - Helpers

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
    CalendarTimelineView(events: DUMMY_DATA)
}
