import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200 && largeDesktop != null) {
          return largeDesktop!;
        } else if (constraints.maxWidth >= 800 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;
        if (constraints.maxWidth >= 800) {
          columns = desktopColumns;
        } else if (constraints.maxWidth >= 600) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }

        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;
  final bool center;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      child: center
          ? Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            )
          : ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
    );
  }
}

class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  T getValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200 && largeDesktop != null) {
      return largeDesktop!;
    } else if (width >= 800 && desktop != null) {
      return desktop!;
    } else if (width >= 600 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

class ResponsiveEdgeInsets extends StatelessWidget {
  final ResponsiveValue<EdgeInsets> value;
  final Widget child;

  const ResponsiveEdgeInsets({
    super.key,
    required this.value,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: value.getValue(context),
      child: child,
    );
  }
}

class ResponsiveSizedBox extends StatelessWidget {
  final ResponsiveValue<double>? width;
  final ResponsiveValue<double>? height;
  final Widget? child;

  const ResponsiveSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width?.getValue(context),
      height: height?.getValue(context),
      child: child,
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String data;
  final ResponsiveValue<TextStyle>? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style?.getValue(context),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool showMobile;
  final bool showTablet;
  final bool showDesktop;
  final bool showLargeDesktop;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.showMobile = true,
    this.showTablet = true,
    this.showDesktop = true,
    this.showLargeDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        bool shouldShow = false;

        if (width >= 1200 && showLargeDesktop) {
          shouldShow = true;
        } else if (width >= 800 && showDesktop) {
          shouldShow = true;
        } else if (width >= 600 && showTablet) {
          shouldShow = true;
        } else if (showMobile) {
          shouldShow = true;
        }

        return shouldShow ? child : const SizedBox.shrink();
      },
    );
  }
}

class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 800;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet &&
      MediaQuery.of(context).size.width < desktop;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static Orientation getOrientation(BuildContext context) =>
      MediaQuery.of(context).orientation;
}

class ResponsiveFlex extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final ResponsiveValue<MainAxisAlignment>? responsiveMainAxisAlignment;
  final ResponsiveValue<CrossAxisAlignment>? responsiveCrossAxisAlignment;
  final ResponsiveValue<Axis>? direction;
  final ResponsiveValue<double>? spacing;

  const ResponsiveFlex({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.responsiveMainAxisAlignment,
    this.responsiveCrossAxisAlignment,
    this.direction,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final currentSpacing = spacing?.getValue(context) ?? 0.0;
    final currentDirection = direction?.getValue(context) ?? Axis.horizontal;

    if (currentSpacing > 0 && currentDirection == Axis.horizontal) {
      return Row(
        mainAxisAlignment:
            responsiveMainAxisAlignment?.getValue(context) ?? mainAxisAlignment,
        crossAxisAlignment: responsiveCrossAxisAlignment?.getValue(context) ??
            crossAxisAlignment,
        children: _addSpacing(children, currentSpacing),
      );
    } else if (currentSpacing > 0 && currentDirection == Axis.vertical) {
      return Column(
        mainAxisAlignment:
            responsiveMainAxisAlignment?.getValue(context) ?? mainAxisAlignment,
        crossAxisAlignment: responsiveCrossAxisAlignment?.getValue(context) ??
            crossAxisAlignment,
        children: _addSpacing(children, currentSpacing),
      );
    } else if (currentDirection == Axis.horizontal) {
      return Row(
        mainAxisAlignment:
            responsiveMainAxisAlignment?.getValue(context) ?? mainAxisAlignment,
        crossAxisAlignment: responsiveCrossAxisAlignment?.getValue(context) ??
            crossAxisAlignment,
        children: children,
      );
    } else {
      return Column(
        mainAxisAlignment:
            responsiveMainAxisAlignment?.getValue(context) ?? mainAxisAlignment,
        crossAxisAlignment: responsiveCrossAxisAlignment?.getValue(context) ??
            crossAxisAlignment,
        children: children,
      );
    }
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;

    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing, height: spacing));
      }
    }
    return spacedChildren;
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final ResponsiveValue<EdgeInsets>? margin;
  final ResponsiveValue<EdgeInsets>? padding;
  final ResponsiveValue<double>? elevation;
  final ResponsiveValue<BorderRadius>? borderRadius;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin?.getValue(context),
      elevation: elevation?.getValue(context) ?? 4.0,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius?.getValue(context) ?? BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding?.getValue(context) ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class ResponsiveSliverGrid extends StatelessWidget {
  final List<Widget> children;
  final ResponsiveValue<int> crossAxisCount;
  final ResponsiveValue<double>? crossAxisSpacing;
  final ResponsiveValue<double>? mainAxisSpacing;
  final ResponsiveValue<double>? childAspectRatio;

  const ResponsiveSliverGrid({
    super.key,
    required this.children,
    required this.crossAxisCount,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount.getValue(context),
        crossAxisSpacing: crossAxisSpacing?.getValue(context) ?? 16.0,
        mainAxisSpacing: mainAxisSpacing?.getValue(context) ?? 16.0,
        childAspectRatio: childAspectRatio?.getValue(context) ?? 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => children[index],
        childCount: children.length,
      ),
    );
  }
}
