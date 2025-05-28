import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_checkbox.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/core/widgets/decrement_button.dart';
import 'package:rebill_flutter/core/widgets/header_column.dart';
import 'package:rebill_flutter/core/widgets/increment_button.dart';
import 'package:rebill_flutter/features/stock-taking/models/stock_taking.dart';

class ExpandableList extends ConsumerStatefulWidget {
  const ExpandableList({
    super.key,
    required this.stockTakings,
    required this.title,
  });

  final List<StockTaking> stockTakings;
  final String title;

  @override
  ConsumerState<ExpandableList> createState() => _ExpandableListState();
}

class _ExpandableListState extends ConsumerState<ExpandableList> {
  List<TextEditingController> controllers = [];

  @override
  void initState() {
    super.initState();
    for (var _ in widget.stockTakings) {
      controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockTakings = widget.stockTakings;
    final theme = Theme.of(context);
    return AnimatedSize(
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.surfaceContainer),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            //header
            AppMaterial(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                ),
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.title, style: theme.textTheme.displaySmall),
                    Row(children: [SizedBox(width: 12), AppCheckbox()]),
                  ],
                ),
              ),
            ),

            //list
            Container(
              width: double.infinity,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: stockTakings.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            index != stockTakings.length - 1
                                ? BorderSide(
                                  color: theme.colorScheme.surfaceContainer,
                                )
                                : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      children: [
                        CellColumn(
                          flex: 2,
                          text: stockTakings[index].productName,
                        ),
                        CellColumn(
                          flex: 1,
                          text: stockTakings[index].productStock.toString(),
                          textAlign: TextAlign.center,
                        ),
                        CellColumn(
                          flex: 1,
                          text: '',
                          child: Container(
                            height: 45,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 12,
                              children: [
                                DecrementButton(),
                                Expanded(
                                  child: AppTextField(
                                    showLabel: false,
                                    controller: controllers[index],
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                IncrementButton(),
                              ],
                            ),
                          ),
                        ),
                        CellColumn(
                          flex: 1,
                          text: '',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [AppCheckbox()],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
