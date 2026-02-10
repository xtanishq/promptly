import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTabView extends StatefulWidget {
  const CustomTabView({
    super.key,
    required this.itemCount,
    required this.tabBuilder,
    required this.pageBuilder,
    this.stub,
    this.onPositionChange,
    this.onScroll,
    this.initPosition,
    required this.selecttabcolor, this.unselectedLabelColor, this.labelColor,
  });

  final int itemCount;
  final IndexedWidgetBuilder tabBuilder;
  final Color selecttabcolor;
  final IndexedWidgetBuilder pageBuilder;
  final Widget? stub;
  final ValueChanged<int>? onPositionChange;
  final ValueChanged<double>? onScroll;
  final int? initPosition;
  final Color? unselectedLabelColor;
  final Color? labelColor;

  @override
  CustomTabsState createState() => CustomTabsState();
}

class CustomTabsState extends State<CustomTabView>
    with TickerProviderStateMixin {
  late TabController controller;
  late int _currentCount;
  late int _currentPosition;

  @override
  void initState() {
    _currentPosition = widget.initPosition ?? 0;
    controller = TabController(
      length: widget.itemCount,
      vsync: this,
      initialIndex: _currentPosition,
    );
    controller.addListener(onPositionChange);
    controller.animation!.addListener(onScroll);
    _currentCount = widget.itemCount;
    super.initState();
  }

  @override
  void didUpdateWidget(CustomTabView oldWidget) {
    if (_currentCount != widget.itemCount) {
      controller.animation!.removeListener(onScroll);
      controller.removeListener(onPositionChange);
      controller.dispose();

      if (widget.initPosition != null) {
        _currentPosition = widget.initPosition!;
      }

      if (_currentPosition > widget.itemCount - 1) {
        _currentPosition = widget.itemCount - 1;
        _currentPosition = _currentPosition < 0 ? 0 : _currentPosition;
        if (widget.onPositionChange is ValueChanged<int>) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && widget.onPositionChange != null) {
              widget.onPositionChange!(_currentPosition);
            }
          });
        }
      }

      _currentCount = widget.itemCount;
      setState(() {
        controller = TabController(
          length: widget.itemCount,
          vsync: this,
          initialIndex: _currentPosition,
        );
        controller.addListener(onPositionChange);
        controller.animation!.addListener(onScroll);
      });
    } else if (widget.initPosition != null) {
      controller.animateTo(widget.initPosition!);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.animation!.removeListener(onScroll);
    controller.removeListener(onPositionChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount < 1) return widget.stub ?? Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding:  EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            decoration: BoxDecoration(
              // YOUR UNSELECTED COLOR HERE
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              isScrollable: true,

              controller: controller,
              padding: EdgeInsets.only(top: 15.h,bottom: 15.h),
              labelPadding: EdgeInsets.symmetric(horizontal: 5),
              unselectedLabelColor: widget.unselectedLabelColor??Colors.grey,
              labelColor: widget.labelColor??Colors.white,

              indicator: BoxDecoration(
                color: widget.selecttabcolor,

                borderRadius: BorderRadius.circular(35),
              ),
              automaticIndicatorColorAdjustment: true,
              dividerColor: Colors.transparent,

              tabAlignment: TabAlignment.center,
              tabs: List.generate(
                widget.itemCount,(index) => widget.tabBuilder(context, index),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: TabBarView(
            controller: controller,
            children: List.generate(
              widget.itemCount, (index) => widget.pageBuilder(context, index),
            ),
          ),
        ),
      ],
    );
  }

  // void onPositionChange() {
  //   if (!controller.indexIsChanging) {
  //     _currentPosition = controller.index;
  //     if (widget.onPositionChange is ValueChanged<int>) {
  //       widget.onPositionChange!(_currentPosition);
  //     }
  //   }
  // }
  void onPositionChange() {
    if (!controller.indexIsChanging) {
      _currentPosition = controller.index;
      setState(() {}); // This forces the tabBuilder to refresh and update colors
      if (widget.onPositionChange != null) {
        widget.onPositionChange!(_currentPosition);
      }
    }
  }

  void onScroll() {
    if (widget.onScroll is ValueChanged<double>) {
      widget.onScroll!(controller.animation!.value);
    }
  }
}