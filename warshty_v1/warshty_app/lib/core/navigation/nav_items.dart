import 'package:flutter/material.dart';

import '../routing/route_paths.dart';
import 'bottom_nav_item.dart';

const navItems = [
  BottomNavItem(
    label: 'الرئيسية',
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    routePath: RoutePaths.home,
  ),
  BottomNavItem(
    label: 'الأشخاص',
    icon: Icons.people_outline,
    activeIcon: Icons.people,
    routePath: RoutePaths.persons,
  ),
  BottomNavItem(
    label: 'الشغلانات',
    icon: Icons.construction_outlined,
    activeIcon: Icons.construction,
    routePath: RoutePaths.jobs,
  ),
  BottomNavItem(
    label: 'الخزينة',
    icon: Icons.account_balance_outlined,
    activeIcon: Icons.account_balance,
    routePath: RoutePaths.treasury,
  ),
  BottomNavItem(
    label: 'التقارير',
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart,
    routePath: RoutePaths.reports,
  ),
];
