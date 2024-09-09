////
////  FlapperSean.swift
////  SwiftyUI
////
////  Created by Sako Hovaguimian on 8/27/24.
////
//
//import SwiftUI
//import SwiftUI
//
////struct FlapperSean: View {
////    @State private var birdPosition = CGPoint(x: 100, y: 300)
////    @State private var birdVelocity: CGFloat = 0
////    @State private var obstacles: [CGRect] = []
////    @State private var score = 0
////    @State private var gameTimer: Timer?
////    @State private var isGameOver = false
////    @State private var passedObstacles: Set<Int> = []
////
////    let birdSize: CGFloat = 50
////    let obstacleWidth: CGFloat = 70
////    let gapHeight: CGFloat = 200
////    let gravity: CGFloat = 0.35
////    let jumpStrength: CGFloat = -8
////
////    var body: some View {
////        GeometryReader { geometry in
////            ZStack {
////                // Background
////                Color.blue.opacity(0.3).edgesIgnoringSafeArea(.all)
////
////                // Bird
////                Image(systemName: "bird.fill")
////                    .resizable()
////                    .foregroundColor(.yellow)
////                    .frame(width: birdSize, height: birdSize)
////                    .position(birdPosition)
////
////                // Obstacles
////                ForEach(obstacles.indices, id: \.self) { index in
////                    Path { path in
////                        path.addRect(obstacles[index])
////                    }
////                    .fill(Color.green)
////                }
////
////                // Score
////                Text("Score: \(score)")
////                    .font(.largeTitle)
////                    .foregroundColor(.white)
////                    .padding()
////                    .background(Color.black.opacity(0.5))
////                    .cornerRadius(10)
////                    .position(x: geometry.size.width / 2, y: 50)
////
////                if isGameOver {
////                    VStack {
////                        Text("Game Over")
////                            .font(.largeTitle)
////                            .foregroundColor(.red)
////                        Button("Restart") {
////                            restartGame()
////                        }
////                        .padding()
////                        .background(Color.blue)
////                        .foregroundColor(.white)
////                        .cornerRadius(10)
////                    }
////                }
////            }
////            .gesture(
////                TapGesture()
////                    .onEnded { _ in
////                        if !isGameOver {
////                            jump()
////                        }
////                    }
////            )
////            .onAppear {
////                startGame(in: geometry.size)
////            }
////        }
////    }
////
////    func startGame(in size: CGSize) {
////        birdPosition = CGPoint(x: 100, y: size.height / 2)
////        birdVelocity = 0
////        obstacles = []
////        score = 0
////        isGameOver = false
////        passedObstacles.removeAll()
////
////        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
////            updateGame(in: size)
////        }
////    }
////
////    func updateGame(in size: CGSize) {
////        // Update bird position
////        birdVelocity += gravity
////        birdVelocity = min(max(birdVelocity, -10), 10)
////        birdPosition.y += birdVelocity
////
////        // Add new obstacles
////        if obstacles.isEmpty || obstacles.last!.maxX < size.width - 200 {
////            addObstacle(in: size)
////        }
////
////        // Move obstacles and remove off-screen ones
////        for i in obstacles.indices.reversed() {
////            obstacles[i] = obstacles[i].offsetBy(dx: -2, dy: 0)
////            
////            // Remove obstacles that are off-screen
////            if obstacles[i].maxX < 0 {
////                obstacles.remove(at: i)
////            }
////        }
////
////        // Check for collisions
////        if checkCollision(in: size) {
////            gameOver()
////        }
////
////        // Update score
////        updateScore()
////    }
////
////    func addObstacle(in size: CGSize) {
////        let safeAreaTop = UIApplication.shared.windows.first!.safeAreaInsets.top + 44
////        let gapPosition = CGFloat.random(in: (size.height / 2)...(size.height - 100 - gapHeight))
////        let topObstacle = CGRect(x: size.width, y: safeAreaTop, width: obstacleWidth, height: gapPosition - safeAreaTop)
////        let bottomObstacle = CGRect(x: size.width, y: gapPosition + gapHeight, width: obstacleWidth, height: size.height - gapPosition - gapHeight)
////        obstacles.append(contentsOf: [topObstacle, bottomObstacle])
////    }
////
////    func jump() {
////        birdVelocity = jumpStrength
////    }
////
////    func checkCollision(in size: CGSize) -> Bool {
////        let birdRect = CGRect(x: birdPosition.x - birdSize/2, y: birdPosition.y - birdSize/2, width: birdSize, height: birdSize)
////
////        // Check if bird is out of bounds
////        if birdRect.minY <= 0 || birdRect.maxY >= size.height {
////            return true
////        }
////
////        // Check collision with obstacles
////        for obstacle in obstacles {
////            if birdRect.intersects(obstacle) {
////                return true
////            }
////        }
////
////        return false
////    }
////
////    func updateScore() {
////        for (index, obstacle) in obstacles.enumerated() {
////            // Check if the bird has passed the obstacle and it's not already scored
////            if obstacle.maxX < birdPosition.x && !passedObstacles.contains(index) {
////                passedObstacles.insert(index)
////                score += 1
////                break  // Only increment score once per update
////            }
////        }
////    }
////
////    func gameOver() {
////        gameTimer?.invalidate()
////        isGameOver = true
////    }
////
////    func restartGame() {
////        guard let size = UIApplication.shared.windows.first?.bounds.size else { return }
////        startGame(in: size)
////    }
////}
////
////
////import SwiftUI
////
////struct CardGame: View {
////    @StateObject private var gameViewModel = GameViewModel()
////    
////    var body: some View {
////        VStack {
////            HStack {
////                VStack {
////                    Text("User")
////                    Text("\(gameViewModel.userWins) / 5")
////                }
////                Spacer()
////                VStack {
////                    Text("CPU")
////                    Text("\(gameViewModel.cpuWins) / 5")
////                }
////            }
////            .padding()
////            
////            Spacer()
////            
////            // 3x4 Grid for Player Cards
////            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
////                ForEach(gameViewModel.playerCards) { card in
////                    CardView(
////                        card: card,
////                        isFaceUp: gameViewModel.selectedPlayerCard?.id == card.id || card.isRevealed,
////                        showIndicator: gameViewModel.selectedCPUCard?.id == card.id,
////                        action: {
////                            gameViewModel.playCard(card: card)
////                        }
////                    )
////                    .opacity(gameViewModel.selectedPlayerCard?.id == card.id || card.isRevealed ? 1 : 0.6)
////                    .disabled(card.isRevealed || gameViewModel.isProcessingTurn)
////                }
////            }
////            
////            Spacer()
////            
////            Text("Tap a card to play")
////                .font(.headline)
////                .padding()
////            
////            Spacer()
////        }
////        .overlay(
////            CollisionOverlayView(
////                showCollision: gameViewModel.showCollision,
////                playerCard: gameViewModel.selectedPlayerCard,
////                cpuCard: gameViewModel.selectedCPUCard
////            )
////        )
////        .onAppear {
////            gameViewModel.startGame()
////        }
////        .alert(item: $gameViewModel.gameOverMessage) { message in
////            Alert(
////                title: Text("Game Over"),
////                message: Text(message.text),
////                dismissButton: .default(Text("Play Again"), action: {
////                    gameViewModel.resetGame()
////                })
////            )
////        }
////    }
////}
////
////struct CardView: View {
////    let card: Card
////    let isFaceUp: Bool
////    let showIndicator: Bool
////    let action: () -> Void
////    
////    @State private var isFlipped = false
////    
////    var body: some View {
////        ZStack {
////            Rectangle()
////                .fill(isFaceUp ? Color.white : Color.gray)
////                .frame(width: 80, height: 120)
////                .cornerRadius(10)
////                .shadow(radius: 5)
////                .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))
////            
////            if isFaceUp {
////                Text("\(card.value)")
////                    .font(.largeTitle)
////                    .foregroundColor(.black)
////            }
////            
////            if showIndicator && !isFaceUp {
////                // Show indicator that CPU picked this card
////                Circle()
////                    .fill(Color.red)
////                    .frame(width: 10, height: 10)
////                    .offset(x: 30, y: -50)
////            }
////        }
////        .onTapGesture {
////            if !isFaceUp {
////                withAnimation(.easeInOut(duration: 0.5)) {
////                    isFlipped.toggle()
////                    action()
////                }
////            }
////        }
////        .onAppear {
////            if isFaceUp && !isFlipped {
////                withAnimation(.easeInOut(duration: 0.5)) {
////                    isFlipped = true
////                }
////            }
////        }
////    }
////}
////
////struct CollisionOverlayView: View {
////    let showCollision: Bool
////    let playerCard: Card?
////    let cpuCard: Card?
////    
////    @State private var playerCardOffset: CGFloat = -200
////    @State private var cpuCardOffset: CGFloat = 200
////    @State private var fadeOut = false
////    
////    var body: some View {
////        if showCollision, let playerCard = playerCard, let cpuCard = cpuCard {
////            ZStack {
////                CardRepresentation(card: playerCard)
////                    .offset(x: playerCardOffset)
////                
////                CardRepresentation(card: cpuCard)
////                    .offset(x: cpuCardOffset)
////                
////            }
////            .onAppear {
////                withAnimation(.easeInOut(duration: 1)) {
////                    playerCardOffset = 0
////                    cpuCardOffset = 0
////                }
////                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
////                    withAnimation(.easeInOut(duration: 1)) {
////                        if playerCard.value > cpuCard.value || cpuCard.value == 1 {
////                            fadeOut = true
////                        } else {
////                            fadeOut = false
////                        }
////                    }
////                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
////                        NotificationCenter.default.post(name: .collisionComplete, object: nil)
////                    }
////                }
////            }
////            .opacity(fadeOut ? 0 : 1)
////        }
////    }
////}
////
////struct CardRepresentation: View {
////    let card: Card
////    
////    var body: some View {
////        ZStack {
////            Rectangle()
////                .fill(Color.white)
////                .frame(width: 80, height: 120)
////                .cornerRadius(10)
////                .shadow(radius: 5)
////            
////            Text("\(card.value)")
////                .font(.largeTitle)
////                .foregroundColor(.black)
////        }
////    }
////}
////
////class GameViewModel: ObservableObject {
////    @Published var playerCards: [Card] = []
////    @Published var cpuCards: [Card] = []
////    @Published var userWins = 0
////    @Published var cpuWins = 0
////    @Published var gameOverMessage: AlertMessage?
////    @Published var selectedPlayerCard: Card?
////    @Published var selectedCPUCard: Card?
////    @Published var showCollision = false
////    @Published var isProcessingTurn = false
////    
////    private var allCards: [Card] = (1...12).map { Card(value: $0) }
////    
////    init() {
////        NotificationCenter.default.addObserver(self, selector: #selector(collisionComplete), name: .collisionComplete, object: nil)
////    }
////    
////    deinit {
////        NotificationCenter.default.removeObserver(self)
////    }
////    
////    func startGame() {
////        drawNewCards()
////    }
////    
////    func drawNewCards() {
////        playerCards = allCards.shuffled().map { card in
////            var newCard = card
////            newCard.isRevealed = false
////            return newCard
////        }
////        cpuCards = allCards.shuffled().map { card in
////            var newCard = card
////            newCard.isRevealed = false
////            return newCard
////        }
////    }
////    
////    func playCard(card: Card) {
////        guard !isProcessingTurn else { return }
////        isProcessingTurn = true
////        selectedPlayerCard = card
////        
////        // CPU plays a card automatically after 0.5 seconds
////        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
////            self.selectedCPUCard = self.cpuCards.randomElement()!
////            self.selectedCPUCard?.isRevealed = true
////            
////            // Show collision animation
////            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
////                self.showCollision = true
////            }
////        }
////    }
////    
////    @objc private func collisionComplete() {
////        resolveTurn()
////    }
////    
////    private func resolveTurn() {
////        guard let playerCard = selectedPlayerCard, let cpuCard = selectedCPUCard else { return }
////        
////        let playerWins = determineWinner(playerCard: playerCard, cpuCard: cpuCard)
////        
////        if playerWins {
////            userWins += 1
////        } else {
////            cpuWins += 1
////        }
////        
////        // Remove the cards that were played
////        if let playerIndex = playerCards.firstIndex(where: { $0.id == playerCard.id }) {
////            playerCards[playerIndex].isRevealed = true
////        }
////        if let cpuIndex = cpuCards.firstIndex(where: { $0.id == cpuCard.id }) {
////            cpuCards[cpuIndex].isRevealed = true
////        }
////        
////        // Reset selections after processing turn
////        selectedPlayerCard = nil
////        selectedCPUCard = nil
////        showCollision = false
////        isProcessingTurn = false
////        
////        // Check if the game is over
////        checkGameOver()
////    }
////    
////    private func determineWinner(playerCard: Card, cpuCard: Card) -> Bool {
////        if playerCard.value == 1 {
////            return true
////        } else if cpuCard.value == 1 {
////            return false
////        }
////        return playerCard.value > cpuCard.value
////    }
////    
////    private func checkGameOver() {
////        if userWins >= 3 {
////            gameOverMessage = AlertMessage(text: "You win! \(userWins) - \(cpuWins)")
////        } else if cpuWins >= 3 {
////            gameOverMessage = AlertMessage(text: "CPU wins! \(cpuWins) - \(userWins)")
////        } else if playerCards.allSatisfy({ $0.isRevealed }) || cpuCards.allSatisfy({ $0.isRevealed }) {
////            if userWins > cpuWins {
////                gameOverMessage = AlertMessage(text: "You win! \(userWins) - \(cpuWins)")
////            } else if cpuWins > userWins {
////                gameOverMessage = AlertMessage(text: "CPU wins! \(cpuWins) - \(userWins)")
////            } else {
////                gameOverMessage = AlertMessage(text: "It's a tie! \(userWins) - \(cpuWins)")
////            }
////        }
////    }
////    
////    func resetGame() {
////        userWins = 0
////        cpuWins = 0
////        selectedPlayerCard = nil
////        selectedCPUCard = nil
////        startGame()
////    }
////}
////
////// Custom struct to hold alert messages
////struct AlertMessage: Identifiable {
////    let id = UUID()
////    let text: String
////}
////
////struct Card: Identifiable {
////    let id = UUID()
////    let value: Int
////    var isRevealed: Bool = false
////}
////
////extension Notification.Name {
////    static let collisionComplete = Notification.Name("collisionComplete")
////}
//
//import SwiftUI
//
//struct BlackjackGameView: View {
//    @StateObject private var gameViewModel = BlackjackGameViewModel()
//    @State private var dealerCardRotations: [Double] = []
//    @State private var showWinParticles = false
//    
//    var body: some View {
//        ZStack {
//            Color.green.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                dealerCardsView
//                Spacer()
//                playerCardsView
//                controlsView
//            }
//            .padding()
//            
//            deckView
//            
//            if showWinParticles {
//                ParticleEffect()
//            }
//        }
//        .onChange(of: gameViewModel.dealerCards) { newValue in
//            updateDealerCardRotations(for: newValue.count)
//        }
//        .alert(item: $gameViewModel.alertItem) { alertItem in
//            Alert(title: Text(alertItem.title),
//                  message: Text(alertItem.message),
//                  dismissButton: .default(Text("OK")) {
//                      gameViewModel.startNewRound()
//                      showWinParticles = false
//                  })
//        }
//    }
//    
//    private var dealerCardsView: some View {
//        VStack {
//            Text("Dealer's Hand")
//                .font(.headline)
//            HStack {
//                ForEach(Array(gameViewModel.dealerCards.enumerated()), id: \.element.id) { index, card in
//                    CardView(card: card, isFaceUp: gameViewModel.isDealerTurn || index == 0)
//                        .rotation3DEffect(
//                            .degrees(dealerCardRotations.indices.contains(index) ? dealerCardRotations[index] : 0),
//                            axis: (x: 0, y: 1, z: 0)
//                        )
//                }
//            }
//            if gameViewModel.isDealerTurn {
//                Text("Total: \(gameViewModel.dealerTotal)")
//                    .font(.subheadline)
//            }
//        }
//    }
//    
//    private var playerCardsView: some View {
//        VStack {
//            Text("Your Hand")
//                .font(.headline)
//            HStack {
//                ForEach(gameViewModel.playerCards, id: \.id) { card in
//                    CardView(card: card, isFaceUp: true)
//                }
//            }
//            Text("Total: \(gameViewModel.playerTotal)")
//                .font(.subheadline)
//        }
//    }
//    
//    private var controlsView: some View {
//        HStack {
//            Button(action: {
//                withAnimation {
//                    gameViewModel.hit()
//                }
//            }) {
//                Label("Hit", systemImage: "plus.circle")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            .disabled(gameViewModel.isGameOver)
//            
//            Button(action: {
//                withAnimation(.easeInOut(duration: 0.5)) {
//                    gameViewModel.stay()
//                    flipDealerCards()
//                }
//            }) {
//                Label("Stay", systemImage: "hand.raised")
//                    .padding()
//                    .background(Color.red)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            .disabled(gameViewModel.isGameOver)
//        }
//    }
//    
//    private var deckView: some View {
//        VStack {
//            Image(systemName: "rectangle.stack.fill")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 60, height: 60)
//                .foregroundColor(.white)
//                .shadow(radius: 5)
//            Text("Deck")
//                .font(.caption)
//        }
//        .position(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.height / 2)
//    }
//    
//    private func updateDealerCardRotations(for count: Int) {
//        dealerCardRotations = Array(dealerCardRotations.prefix(count))
//        while dealerCardRotations.count < count {
//            dealerCardRotations.append(0)
//        }
//    }
//    
//    private func flipDealerCards() {
//        for i in 0..<gameViewModel.dealerCards.count {
//            withAnimation(.easeInOut(duration: 0.5).delay(Double(i) * 0.2)) {
//                if i < dealerCardRotations.count {
//                    dealerCardRotations[i] = 180
//                }
//            }
//        }
//    }
//}
//
//struct CardView: View {
//    let card: Card
//    let isFaceUp: Bool
//    
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 10)
//                .fill(isFaceUp ? Color.white : Color.blue)
//                .frame(width: 70, height: 100)
//                .shadow(radius: 5)
//            
//            if isFaceUp {
//                VStack {
//                    Text(card.rank.description)
//                        .font(.headline)
//                    Image(systemName: card.suit.sfSymbolName)
//                        .foregroundColor(card.suit.color)
//                }
//            } else {
//                Image(systemName: "questionmark")
//                    .foregroundColor(.white)
//            }
//        }
//    }
//}
//
//struct ParticleEffect: View {
//    @State private var time = 0.0
//    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
//    
//    var body: some View {
//        TimelineView(.animation) { timeline in
//            Canvas { context, size in
//                let timelineDate = timeline.date.timeIntervalSinceReferenceDate
//                for i in 0..<100 {
//                    let position = position(forIndex: i, time: timelineDate, in: size)
//                    let circle = Path(ellipseIn: CGRect(x: position.x, y: position.y, width: 5, height: 5))
//                    context.fill(circle, with: .color(.yellow))
//                }
//            }
//        }
//        .edgesIgnoringSafeArea(.all)
//    }
//    
//    func position(forIndex index: Int, time: Double, in size: CGSize) -> CGPoint {
//        let angle = Double.random(in: 0...2 * .pi)
//        let radius = Double.random(in: 0...min(size.width, size.height) / 2)
//        let x = size.width / 2 + CGFloat(cos(angle) * radius) + CGFloat(time * 10).truncatingRemainder(dividingBy: size.width)
//        let y = size.height / 2 + CGFloat(sin(angle) * radius) + CGFloat(time * 10).truncatingRemainder(dividingBy: size.height)
//        return CGPoint(x: x, y: y)
//    }
//}
//
//class BlackjackGameViewModel: ObservableObject {
//    @Published var playerCards: [Card] = []
//    @Published var dealerCards: [Card] = []
//    @Published var isDealerTurn = false
//    @Published var isGameOver = false
//    @Published var alertItem: AlertItem?
//    @Published var score = 0
//    
//    private var deck: [Card] = []
//    
//    init() {
//        startNewGame()
//    }
//    
//    func startNewGame() {
//        resetDeck()
//        playerCards = []
//        dealerCards = []
//        isDealerTurn = false
//        isGameOver = false
//        dealInitialCards()
//    }
//    
//    func startNewRound() {
//        playerCards = []
//        dealerCards = []
//        isDealerTurn = false
//        isGameOver = false
//        dealInitialCards()
//    }
//    
//    private func resetDeck() {
//        deck = []
//        for suit in Suit.allCases {
//            for rank in Rank.allCases {
//                deck.append(Card(suit: suit, rank: rank))
//            }
//        }
//        deck.shuffle()
//    }
//    
//    private func dealInitialCards() {
//        playerCards.append(drawCard())
//        dealerCards.append(drawCard())
//        playerCards.append(drawCard())
//        dealerCards.append(drawCard())
//    }
//    
//    func hit() {
//        playerCards.append(drawCard())
//        if calculateTotal(for: playerCards) > 21 {
//            endRound(playerBusted: true)
//        }
//    }
//    
//    func stay() {
//        isDealerTurn = true
//        while calculateTotal(for: dealerCards) < 17 {
//            dealerCards.append(drawCard())
//        }
//        endRound(playerBusted: false)
//    }
//    
//    private func drawCard() -> Card {
//        if deck.isEmpty {
//            resetDeck()
//        }
//        return deck.removeFirst()
//    }
//    
//    private func calculateTotal(for cards: [Card]) -> Int {
//        var total = 0
//        var aceCount = 0
//        
//        for card in cards {
//            switch card.rank {
//            case .ace:
//                aceCount += 1
//                total += 11
//            case .jack, .queen, .king:
//                total += 10
//            default:
//                total += card.rank.rawValue
//            }
//        }
//        
//        while total > 21 && aceCount > 0 {
//            total -= 10
//            aceCount -= 1
//        }
//        
//        return total
//    }
//    
//    private func endRound(playerBusted: Bool) {
//        isGameOver = true
//        let playerTotal = calculateTotal(for: playerCards)
//        let dealerTotal = calculateTotal(for: dealerCards)
//        
//        if playerBusted {
//            score -= 1
//            alertItem = AlertItem(title: "You Busted!", message: "Your total: \(playerTotal). Dealer's total: \(dealerTotal)")
//        } else if dealerTotal > 21 {
//            score += 1
//            alertItem = AlertItem(title: "You Win!", message: "Dealer busted! Your total: \(playerTotal). Dealer's total: \(dealerTotal)")
//        } else if playerTotal > dealerTotal {
//            score += 1
//            alertItem = AlertItem(title: "You Win!", message: "Your total: \(playerTotal). Dealer's total: \(dealerTotal)")
//        } else if playerTotal < dealerTotal {
//            score -= 1
//            alertItem = AlertItem(title: "You Lose!", message: "Your total: \(playerTotal). Dealer's total: \(dealerTotal)")
//        } else {
//            alertItem = AlertItem(title: "It's a Tie!", message: "Your total: \(playerTotal). Dealer's total: \(dealerTotal)")
//        }
//        
//        if score <= -3 {
//            alertItem = AlertItem(title: "Game Over!", message: "You've reached -3 points. Starting a new game.")
//            score = 0
//        }
//    }
//    
//    var playerTotal: Int {
//        calculateTotal(for: playerCards)
//    }
//    
//    var dealerTotal: Int {
//        calculateTotal(for: dealerCards)
//    }
//}
//
//struct AlertItem: Identifiable {
//    let id = UUID()
//    let title: String
//    let message: String
//}
//
//enum Suit: CaseIterable {
//    case hearts, diamonds, clubs, spades
//    
//    var color: Color {
//        switch self {
//        case .hearts, .diamonds:
//            return .red
//        case .clubs, .spades:
//            return .black
//        }
//    }
//    
//    var sfSymbolName: String {
//        switch self {
//        case .hearts: return "heart.fill"
//        case .diamonds: return "diamond.fill"
//        case .clubs: return "club.fill"
//        case .spades: return "suit.spade.fill"
//        }
//    }
//}
//
//enum Rank: Int, CaseIterable {
//    case ace = 1, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
//    
//    var description: String {
//        switch self {
//        case .ace: return "A"
//        case .jack: return "J"
//        case .queen: return "Q"
//        case .king: return "K"
//        default: return String(rawValue)
//        }
//    }
//}
//
//struct Card: Identifiable, Equatable {
//    let id = UUID()
//    let suit: Suit
//    let rank: Rank
//}
