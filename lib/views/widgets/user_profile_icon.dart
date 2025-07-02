import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileIcon extends StatelessWidget {
  final double size;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  const UserProfileIcon({
    super.key,
    this.size = 40.0,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    // Si el usuario tiene una foto de perfil
    if (user?.photoURL != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: backgroundColor, width: 2),
            image: DecorationImage(
              image: NetworkImage(user!.photoURL!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
    
    // Si el usuario tiene un nombre, mostramos sus iniciales
    String initials = '';
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      final nameParts = user.displayName!.split(' ');
      if (nameParts.isNotEmpty) {
        initials += nameParts.first[0];
        if (nameParts.length > 1) {
          initials += nameParts.last[0];
        }
      }
    } else if (user?.email != null) {
      // Si no tiene nombre, usamos la primera letra del email
      initials = user!.email![0].toUpperCase();
    } else {
      // Si no hay información, mostramos un ícono genérico
      return GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: size / 2,
          backgroundColor: backgroundColor,
          child: Icon(
            Icons.person,
            color: iconColor,
            size: size * 0.6,
          ),
        ),
      );
    }

    // Mostramos las iniciales
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: backgroundColor,
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: iconColor,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}
