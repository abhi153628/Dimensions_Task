import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  final bool isDesktop;
  
  const AppBarWidget({
    Key? key,
    required this.isDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 16, 
        vertical: 12
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isDesktop 
        // Desktop layout
        ? Row(
            children: [
              // Nav Links
              Row(
                children: [
                  _buildNavLink('Home', false),
                  const SizedBox(width: 20),
                  _buildNavLink('Search Jobs', true),
                  const SizedBox(width: 20),
                  _buildNavLink('Companies', false),
                  const SizedBox(width: 20),
                  _buildNavLink('Post Jobs', false),
                ],
              ),
              
              // Logo
              Expanded(
                child: Center(
                  child: _buildLogo(height: 50, fontSize: 20),
                ),
              ),
              
              // User Area
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 24),
                  
                  _buildUserInfo(isLarge: true),
                ],
              ),
            ],
          )
        // Mobile layout
        : Column(
            children: [
              // Top row with logo and icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  _buildLogo(height: 40, fontSize: 18),
                  
                  // Icons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              
              // User info row
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildUserInfo(isLarge: false),
              ),
            ],
          ),
    );
  }

  Widget _buildNavLink(String text, bool isActive) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: isActive ? Colors.purple : Colors.black,
        padding: EdgeInsets.zero,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? Colors.purple : Colors.black,
        ),
      ),
    );
  }

  Widget _buildLogo({required double height, required double fontSize}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('asset/100708567-removebg-preview.png', height: height),
        const SizedBox(width: 8),
        Text(
          'GetJob',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo({required bool isLarge}) {
    return Row(
      children: [
        CircleAvatar(
          radius: isLarge ? 16 : 12,
          backgroundImage: NetworkImage(
            'https://ui-avatars.com/api/?name=John+Wick&background=random',
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Hello, John Wick',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
