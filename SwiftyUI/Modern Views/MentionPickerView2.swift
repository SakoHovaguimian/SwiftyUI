import SwiftUI
import Combine

// MARK: – 1. Mention model and splitting

enum MentionSegment {
    case plain(String)
    case mention(String)
}

extension String {
    /// Splits text into plain and mention segments (e.g. ["Hey ", "@Sako", " how are you?"])
    var mentionSegments: [MentionSegment] {
        var segments: [MentionSegment] = []
        let pattern = "@[A-Za-z0-9_]+"
        let regex = try? NSRegularExpression(pattern: pattern)
        var lastIndex = startIndex

        regex?.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            guard
                let match = match,
                let range = Range(match.range, in: self)
            else { return }

            if lastIndex < range.lowerBound {
                segments.append(.plain(String(self[lastIndex..<range.lowerBound])))
            }

            let mentionText = String(self[range])
            segments.append(.mention(String(mentionText.dropFirst())))

            lastIndex = range.upperBound
        }

        if lastIndex < endIndex {
            segments.append(.plain(String(self[lastIndex..<endIndex])))
        }

        return segments
    }
}

// MARK: – 2. Build AttributedString from segments

extension AttributedString {
    init(segments: [MentionSegment]) {
        self.init()
        for segment in segments {
            switch segment {
            case .plain(let s):
                append(AttributedString(s))

            case .mention(let name):
                var run = AttributedString("@\(name)")
                run.font = .system(size: 16, weight: .semibold)
                run.foregroundColor = .white
                run.backgroundColor = .purple
                append(run)
            }
        }
    }
}

// MARK: – 3. ViewModel with debounce + filtering

final class MentionPickerViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var showMentionList = false
    @Published var filteredNames: [String] = []
    @Published var caretRect: CGRect = .zero

    private let allNames: [String]
    private let maxSuggestions = 10
    private var cancellables = Set<AnyCancellable>()

    init(names: [String] = ["John","Jane","Jack","Jill","Joe","Jenny","James","Jocelyn","Jordan","Jasmine"]) {
        self.allNames = names

        $text
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                self?.filterMentions(for: newValue)
            }
            .store(in: &cancellables)
    }

    private func filterMentions(for newText: String) {
        guard let atIndex = newText.lastIndex(of: "@") else {
            withAnimation(.smooth) { showMentionList = false }
            return
        }

        let query = String(newText[newText.index(after: atIndex)...]).lowercased()
        let matches = allNames.filter { $0.lowercased().hasPrefix(query) }
        filteredNames = Array(matches.prefix(maxSuggestions))

        withAnimation(.smooth) {
            showMentionList = !filteredNames.isEmpty
        }
    }

    func selectName(_ name: String) {
        if let atIndex = text.lastIndex(of: "@") {
            text = String(text[..<atIndex]) + "@\(name) "
        } else {
            text += "@\(name) "
        }
        withAnimation(.smooth) {
            showMentionList = false
        }
    }

    var segments: [MentionSegment] {
        text.mentionSegments
    }
}

// MARK: – 4. UITextField wrapper to track caret

struct CaretTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var caretRect: CGRect
    var onEditingChanged: (Bool) -> Void

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.delegate = context.coordinator
        tf.addTarget(context.coordinator,
                     action: #selector(Coordinator.textChanged),
                     for: .editingChanged)
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        DispatchQueue.main.async {
            if let range = uiView.selectedTextRange {
                let rect = uiView.caretRect(for: range.start)
                if let global = uiView.superview?.convert(rect, to: nil) {
                    caretRect = global
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CaretTextField

        init(_ parent: CaretTextField) {
            self.parent = parent
        }

        @objc func textChanged(_ tf: UITextField) {
            parent.text = tf.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onEditingChanged(true)
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onEditingChanged(false)
        }
    }
}

// MARK: – 5. SwiftUI view that renders the AttributedString

struct MentionedText: View {
    let segments: [MentionSegment]

    var body: some View {
        Text(AttributedString(segments: segments))
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: – 6. Main MentionPickerView

struct MentionPickerView: View {
    @StateObject private var vm = MentionPickerViewModel()
    @State private var fieldFrame: CGRect = .zero

    var body: some View {
        ZStack(alignment: .topLeading) {
            // suggestion list anchored under the caret
            if vm.showMentionList {
                ScrollView {
                    VStack(alignment: .leading, spacing: .appSmall) {
                        ForEach(vm.filteredNames, id: \.self) { name in
                            Text("@\(name)")
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                                .onTapGesture { vm.selectName(name) }
                        }
                    }
                    .padding(8)
                }
                .frame(width: 200, height: 150)
                .background(ThemeManager.shared.background(.secondary))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .appShadow(style: .card)
                .offset(x: vm.caretRect.minX - fieldFrame.minX,
                        y: vm.caretRect.maxY - fieldFrame.minY + 4)
                .animation(.smooth, value: vm.caretRect)
            }

            // the actual input field
            CaretTextField(text: $vm.text,
                           caretRect: $vm.caretRect) { isEditing in
                if !isEditing {
                    withAnimation(.smooth) {
                        vm.showMentionList = false
                    }
                }
            }
            .padding(12)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { fieldFrame = proxy.frame(in: .global) }
                        .onChange(of: proxy.frame(in: .global)) { fieldFrame = $0 }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
        .padding()
        // show the resulting text with inline mentions
        MentionedText(segments: vm.segments)
            .padding(.top, 40)
    }
}

// MARK: – Preview

struct MentionPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MentionPickerView()
    }
}
