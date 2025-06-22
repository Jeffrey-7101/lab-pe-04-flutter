import 'package:flutter/material.dart';
import '../../core/routes/navigation_helper.dart';

/// Widget reutilizable para el icono de perfil en AppBars
class ProfileAppBarAction extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  
  const ProfileAppBarAction({
    super.key,
    this.size = 36.0,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () => NavigationHelper.toProfile(context),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: iconColor ?? Colors.green.shade700,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }
}
