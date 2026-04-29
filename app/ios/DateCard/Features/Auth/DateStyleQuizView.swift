import SwiftUI

struct DateStyleQuizView: View {
    @EnvironmentObject var onboardingData: OnboardingData
    @State private var currentQuestion = 0
    @State private var answers: [Int] = Array(repeating: 50, count: 8)
    @State private var showCategoryPicker = false

    private let questions: [(question: String, axis: String, lowLabel: String, highLabel: String)] = [
        ("How do you feel about trying new restaurants?", "foodie", "Comfort classics", "Always exploring"),
        ("When it comes to planning dates...", "planner", "Go with the flow", "Every detail mapped"),
        ("On a perfect evening, I'd rather...", "adventurous", "Cozy night in", "Spontaneous adventure"),
        ("During a date, I tend to...", "talker", "Listen and observe", "Lead the conversation"),
        ("Trying something completely new is...", "adventurous", "Stressful", "Thrilling"),
        ("For a first date, I prefer...", "planner", "Casual and simple", "A curated experience"),
        ("When it comes to food on a date...", "foodie", "It's just fuel", "It's the main event"),
        ("Silence during a date is...", "talker", "Comfortable", "Something to fill"),
    ]

    var body: some View {
        VStack(spacing: 32) {
            ProgressView(value: Double(currentQuestion + 1), total: Double(questions.count))
                .tint(Color.accentColor)
                .padding(.horizontal)

            VStack(spacing: 16) {
                Text(questions[currentQuestion].question)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 8) {
                    Slider(value: Binding(
                        get: { Double(answers[currentQuestion]) },
                        set: { answers[currentQuestion] = Int($0) }
                    ), in: 0...100)
                    .tint(Color.accentColor)

                    HStack {
                        Text(questions[currentQuestion].lowLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(questions[currentQuestion].highLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 32)
            }

            Spacer()

            HStack(spacing: 16) {
                if currentQuestion > 0 {
                    Button("Back") {
                        withAnimation { currentQuestion -= 1 }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button(currentQuestion == questions.count - 1 ? "Finish" : "Next") {
                    if currentQuestion == questions.count - 1 {
                        computeDateStyleCard()
                        showCategoryPicker = true
                    } else {
                        withAnimation { currentQuestion += 1 }
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .navigationTitle("Date Style")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showCategoryPicker) {
            CategoryPickerView()
        }
    }

    private func computeDateStyleCard() {
        // Questions map: 0=foodie, 1=planner, 2=adventurous, 3=talker,
        //                4=adventurous, 5=planner, 6=foodie, 7=talker
        let foodie = (answers[0] + answers[6]) / 2
        let planner = (answers[1] + answers[5]) / 2
        let adventurous = (answers[2] + answers[4]) / 2
        let talker = (answers[3] + answers[7]) / 2

        onboardingData.dateStyleCard = DateStyleCard(
            adventurous: adventurous,
            planner: planner,
            talker: talker,
            foodie: foodie
        )
    }
}

#Preview {
    NavigationStack {
        DateStyleQuizView()
            .environmentObject(OnboardingData())
    }
}
