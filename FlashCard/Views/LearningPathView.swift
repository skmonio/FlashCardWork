import SwiftUI

struct LearningPathView: View {
    @ObservedObject var pathManager = LearningPathManager.shared
    @ObservedObject var lessonManager = LessonManager.shared
    let viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLesson: LearningLesson?
    @State private var completedLessons: [UUID: Int] = [:]
    @State private var isShowingLessonDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Unified Header
            UnifiedHeader(
                title: "Learning Path",
                showBackButton: true,
                showProfileIcon: false,
                onBack: { dismiss() }
            )
            
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with progress
                        pathHeader
                        // Learning path visualization
                        if let path = pathManager.currentPath {
                            ForEach(path.chapters) { chapter in
                                chapterView(chapter)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
                // Hidden NavigationLink for lesson detail
                NavigationLink(
                    destination: lessonDetailDestination,
                    isActive: $isShowingLessonDetail
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(Color(.systemGroupedBackground))
    }
    
    private var lessonDetailDestination: some View {
        Group {
            if let lesson = selectedLesson {
                if let actualLesson = lessonManager.lesson(withId: lesson.lessonId) {
                    LessonDetailView(lesson: actualLesson, completedLessons: $completedLessons, viewModel: viewModel)
                        .onDisappear {
                            checkAndMarkLessonCompletion(lesson)
                        }
                } else {
                    VStack(spacing: 32) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Lesson Locked")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Complete the previous lessons to unlock this content.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private func checkAndMarkLessonCompletion(_ learningLesson: LearningLesson) {
        if let score = completedLessons[learningLesson.lessonId], score > 0 {
            pathManager.markLessonCompleted(learningLesson.lessonId)
        }
    }
    
    private var pathHeader: some View {
        VStack(spacing: 16) {
            if let path = pathManager.currentPath {
                VStack(spacing: 8) {
                    HStack {
                        Text(path.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(path.completedLessons)/\(path.totalLessons)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    ProgressView(value: path.progressPercentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    Text("\(Int(path.progressPercentage * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
    }
    
    private func chapterView(_ chapter: LearningChapter) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(chapter.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(chapter.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if chapter.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Text("\(Int(chapter.progressPercentage * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            VStack(spacing: 0) {
                ForEach(Array(chapter.lessons.enumerated()), id: \.element.id) { index, lesson in
                    lessonNode(lesson, isLast: index == chapter.lessons.count - 1)
                }
            }
        }
    }
    
    private func lessonNode(_ lesson: LearningLesson, isLast: Bool) -> some View {
        let isCompleted = pathManager.isLessonCompleted(lesson.lessonId)
        let isLocked = lesson.isLocked
        return VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(lessonStateColor(isCompleted: isCompleted, isLocked: isLocked))
                        .frame(width: 60, height: 60)
                        .shadow(color: lessonStateColor(isCompleted: isCompleted, isLocked: isLocked).opacity(0.3), radius: 4, x: 0, y: 2)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    } else {
                        Text("\(lesson.lessonNumber)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(lesson.title)
                            .font(.headline)
                            .foregroundColor(isLocked ? .secondary : .primary)
                        Spacer()
                        Image(systemName: lesson.difficulty.icon)
                            .foregroundColor(lesson.difficulty.color)
                            .font(.caption)
                    }
                    Text(lesson.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text("\(lesson.estimatedTime)m")
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(lesson.rewards.prefix(2), id: \.id) { reward in
                                Image(systemName: reward.type.icon)
                                    .font(.caption2)
                                    .foregroundColor(reward.type.color)
                            }
                        }
                    }
                }
                if !isLocked {
                    Button(action: {
                        selectedLesson = lesson
                        isShowingLessonDetail = true
                    }) {
                        Image(systemName: isCompleted ? "arrow.clockwise" : "play.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(isCompleted ? Color.orange : Color.blue)
                            .clipShape(Circle())
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            if !isLast {
                Rectangle()
                    .fill(connectingLineColor(isCompleted: isCompleted, isLocked: isLocked))
                    .frame(width: 2, height: 30)
                    .padding(.leading, 29)
            }
        }
    }
    
    private func lessonStateColor(isCompleted: Bool, isLocked: Bool) -> Color {
        if isCompleted {
            return .green
        } else if isLocked {
            return .gray
        } else {
            return .blue
        }
    }
    
    private func connectingLineColor(isCompleted: Bool, isLocked: Bool) -> Color {
        if isCompleted {
            return .green
        } else if isLocked {
            return .gray.opacity(0.3)
        } else {
            return .blue.opacity(0.3)
        }
    }
}

// MARK: - Preview
struct LearningPathView_Previews: PreviewProvider {
    static var previews: some View {
        LearningPathView(viewModel: FlashCardViewModel())
    }
} 