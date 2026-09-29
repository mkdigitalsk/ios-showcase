import DesignSystem
import SwiftUI

struct CalendarScreenView: View {
    @State private var viewModel: CalendarViewModel

    init(viewModel: CalendarViewModel = CalendarViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text(.calendarSubtitle)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsTextSecondary)
                MonthCard(viewModel: viewModel)
                SelectionCard(selection: viewModel.selection, format: viewModel.format, clear: viewModel.clear)
            }
            .screenPadding()
        }
        .background(Color.dsBackground)
        .navigationTitle(Text(.calendarTitle))
    }
}

private struct MonthCard: View {
    let viewModel: CalendarViewModel

    var body: some View {
        VStack(spacing: Spacing.m) {
            HStack {
                Button(action: viewModel.showPreviousMonth) {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel(Text(.calendarPreviousMonth))
                Spacer()
                Text(viewModel.monthTitle)
                    .font(.dsBodyEmphasis)
                    .foregroundStyle(Color.dsTextPrimary)
                Spacer()
                Button(action: viewModel.showNextMonth) {
                    Image(systemName: "chevron.right")
                }
                .accessibilityLabel(Text(.calendarNextMonth))
            }
            .foregroundStyle(Color.dsAccent)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.xs), count: CalendarMonth.daysPerWeek), spacing: Spacing.xs) {
                ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsTextSecondary)
                }
                ForEach(viewModel.month.days) { day in
                    DayCell(
                        number: viewModel.dayNumber(day.date),
                        kind: viewModel.kind(of: day.date),
                        isInMonth: day.isInMonth,
                        isToday: viewModel.isToday(day.date),
                        isDisabled: viewModel.isDisabled(day.date),
                    ) {
                        viewModel.select(day.date)
                    }
                }
            }
        }
        .padding(Spacing.m)
        .background(Color.dsSurface, in: .rect(cornerRadius: 12))
    }
}

private struct DayCell: View {
    let number: Int
    let kind: CalendarViewModel.DayKind
    let isInMonth: Bool
    let isToday: Bool
    let isDisabled: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            Text(number, format: .number)
                .font(.dsBody)
                .strikethrough(isDisabled)
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(background, in: .rect(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isToday ? Color.dsAccent : .clear),
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private var foreground: Color {
        switch kind {
        case .start, .end, .single: .dsOnAccent
        case .inRange: .dsTextPrimary
        case .plain: isDisabled || !isInMonth ? .dsTextSecondary : .dsTextPrimary
        }
    }

    private var background: Color {
        switch kind {
        case .start, .end, .single: .dsAccent
        case .inRange: .dsAccent.opacity(0.2)
        case .plain: .clear
        }
    }
}

private struct SelectionCard: View {
    let selection: CalendarSelection
    let format: (Date) -> String
    let clear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(.calendarSelectedRange)
                .font(.dsBodyEmphasis)
                .foregroundStyle(Color.dsTextPrimary)
            summary
                .font(.dsBody)
                .foregroundStyle(Color.dsTextSecondary)
            Button(String(localized: .calendarClearSelection), action: clear)
                .buttonStyle(.dsSecondary)
                .disabled(selection == .empty)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.m)
        .background(Color.dsSurface, in: .rect(cornerRadius: 12))
    }

    @ViewBuilder
    private var summary: some View {
        switch selection {
        case .empty:
            Text(.calendarNoDatesSelected)
        case let .start(start):
            Text(.calendarStartDate(format(start)))
        case let .range(range) where range.start == range.end:
            Text(.calendarSingleDate(format(range.start)))
        case let .range(range):
            Text(.calendarRange(format(range.start), format(range.end)))
        }
    }
}

#Preview {
    NavigationStack {
        CalendarScreenView()
    }
}
