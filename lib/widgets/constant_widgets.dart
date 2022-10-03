import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:math' as math;

class CustomText extends StatelessWidget {
  final String title;
  double? letterspacing;
   CustomText(this.title,this.letterspacing, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontFamily: 'Gotham',
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
        letterSpacing: letterspacing==null?
          0:
          letterspacing,
        color: Colors.black,
      ),

    );
  }
}
class CustomText2 extends StatelessWidget {
  final String title;
   CustomText2(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontFamily: 'Gotham',
          fontWeight: FontWeight.bold,
        color: Colors.black,
      ),

    );
  }
}

class CustomText3 extends StatelessWidget {
  final String title;
  const CustomText3(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Gotham',
        color: Colors.black.withOpacity(0.7),
        fontSize:14,
        fontWeight: FontWeight.bold
      ),
    );
  }
}

class CustomText4 extends StatelessWidget {
  final String title;
  final Color tme;
  const CustomText4(this.title,this.tme, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Gotham',
        fontWeight: FontWeight.bold,
        color:tme,
        letterSpacing: 1,
      ),

    );
  }
}


class CustomText5 extends StatelessWidget {
  final String title;
   FontStyle? style;
 CustomText5(this.title,this.style,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Gotham',
        color: Colors.black.withOpacity(0.3),
        fontStyle: style==null?null:FontStyle.italic,
        fontWeight: FontWeight.bold,
        //letterSpacing: 1,
        fontSize:11,

      ),

    );
  }
}


class CustomText6 extends StatelessWidget {
  var title;
  CustomText6(this.title,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      timeago.format(title.toDate()),
      overflow:TextOverflow.ellipsis,
      style: TextStyle(
          fontSize:10,
          fontFamily: 'Gotham',
          fontWeight: FontWeight.bold,
          color: Colors.black.withOpacity(0.3)
      ),
      softWrap: true,);
  }
}

class CustomText7 extends StatelessWidget {
  final String title;
  const CustomText7(this.title,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontFamily: 'Gotham',
          color: Colors.black.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          //letterSpacing: 1,
          fontSize:12
      ),

    );
  }
}

class CustomText8 extends StatelessWidget {
  final String title;
  const CustomText8(this.title,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontFamily: 'Gotham',
          color: Colors.orange,
          fontWeight: FontWeight.bold,
          //letterSpacing: 1,
          fontSize:18
      ),

    );
  }
}


@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    Key? key,
    this.initialOpen,
    required this.distance,
    required this.children,
  }) : super(key: key);

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
    i < count;
    i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 2),
          child: FloatingActionButton(
            backgroundColor: Colors.green.shade100,
            onPressed: _toggle,
            child: const Icon(Icons.add,size: 35,),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  _ExpandingActionButton({
    Key? key,
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  }) : super(key: key);

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.accentColor,
      elevation: 4.0,
      child: IconTheme.merge(
        data: theme.accentIconTheme,
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
        ),
      ),
    );
  }
}
