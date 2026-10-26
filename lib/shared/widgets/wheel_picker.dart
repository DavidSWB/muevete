import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/widgets/my_button.dart';

/// Height of one wheel row; three rows are visible.
const double kWheelItemExtent = 72;

/// One scrollable column of values. The middle row is the selection: it is
/// drawn large in the primary color, the rows around it small and grey.
/// Tapping a row scrolls it into the middle.
class WheelPicker extends StatefulWidget {
  const WheelPicker({
    super.key,
    required this.itemCount,
    required this.initialIndex,
    required this.labelBuilder,
    required this.onSelected,
    this.width = 120,
    this.selectedFontSize = 52,
    this.semanticsLabel,
  });

  final int itemCount;
  final int initialIndex;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onSelected;
  final double width;
  final double selectedFontSize;
  final String? semanticsLabel;

  @override
  State<WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<WheelPicker> {
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.initialIndex);
  late int _selected = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _selected) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = index);
    widget.onSelected(index);
  }

  void _step(int delta) {
    final target = (_selected + delta).clamp(0, widget.itemCount - 1);
    _controller.animateToItem(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lets screen readers step through the values like a slider.
    final canIncrease = _selected < widget.itemCount - 1;
    final canDecrease = _selected > 0;
    return Semantics(
      label: widget.semanticsLabel,
      value: widget.labelBuilder(_selected),
      increasedValue: canIncrease ? widget.labelBuilder(_selected + 1) : null,
      decreasedValue: canDecrease ? widget.labelBuilder(_selected - 1) : null,
      onIncrease: canIncrease ? () => _step(1) : null,
      onDecrease: canDecrease ? () => _step(-1) : null,
      child: SizedBox(
        width: widget.width,
        height: kWheelItemExtent * 3,
        child: ListWheelScrollView.useDelegate(
          controller: _controller,
          itemExtent: kWheelItemExtent,
          physics: const FixedExtentScrollPhysics(),
          diameterRatio: 4,
          onSelectedItemChanged: _select,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: widget.itemCount,
            builder: (context, index) {
              final selected = index == _selected;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _controller.animateToItem(
                  index,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.labelBuilder(index),
                      style: TextStyle(
                        fontSize: selected
                            ? widget.selectedFontSize
                            : widget.selectedFontSize * 0.7,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? AppColors.primaryDark
                            : AppColors.textDisabled,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Lines above and below the selected row, across all [children] columns,
/// with a fixed [unit] label beside them when the unit is not itself a wheel.
class WheelPickerBand extends StatelessWidget {
  const WheelPickerBand({super.key, required this.children, this.unit});

  final List<Widget> children;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    const line = Divider(height: 1, thickness: 1, color: AppColors.border);

    return SizedBox(
      height: kWheelItemExtent * 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            left: 0,
            right: 0,
            top: kWheelItemExtent,
            child: line,
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: kWheelItemExtent * 2,
            child: line,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...children,
              if (unit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    unit!,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A bottom sheet with [title], a wheel built by [wheelBuilder] and a Done
/// button. Returns the picked value, or null when dismissed.
Future<T?> showWheelPickerSheet<T>(
  BuildContext context, {
  required String title,
  required String doneLabel,
  required T initialValue,
  required Widget Function(ValueChanged<T> onChanged) wheelBuilder,
}) {
  var value = initialValue;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            wheelBuilder((picked) => value = picked),
            const SizedBox(height: 20),
            MyButton(
              key: const ValueKey('wheel-sheet-done'),
              text: doneLabel,
              margin: EdgeInsets.zero,
              onTap: () => Navigator.of(context).pop(value),
            ),
          ],
        ),
      ),
    ),
  );
}
