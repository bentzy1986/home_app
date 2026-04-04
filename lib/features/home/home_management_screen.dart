import 'package:flutter/material.dart';
import '../car/car_screen.dart';
import '../finance/finance_screen.dart';
import '../health/health_screen.dart';
import '../shopping/shopping_screen.dart';
import '../family/family_screen.dart';
import '../home/home_screen.dart';

class HomeManagementScreen extends StatefulWidget {
  const HomeManagementScreen({super.key});
  @override
  State<HomeManagementScreen> createState() => _HomeManagementScreenState();
}

class _HomeManagementScreenState extends State<HomeManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  final List<_ModuleItem> _modules = [
    _ModuleItem(
      title: 'ניהול הבית',
      subtitle: '4 משימות פתוחות',
      icon: Icons.villa_rounded,
      gradient: [Color(0xFF5856D6), Color(0xFFAF52DE)],
      page: HomeDetailsScreen(),
    ),
    _ModuleItem(
      title: 'הרכב שלי',
      subtitle: 'טסט בעוד 45 יום',
      icon: Icons.directions_car_filled_rounded,
      gradient: [Color(0xFFFF3B30), Color(0xFFFF6B35)],
      page: CarScreen(),
    ),
    _ModuleItem(
      title: 'פיננסים',
      subtitle: 'יתרה ₪6,600',
      icon: Icons.show_chart_rounded,
      gradient: [Color(0xFF34C759), Color(0xFF30D158)],
      page: FinanceScreen(),
    ),
    _ModuleItem(
      title: 'בריאות',
      subtitle: 'תור מחר',
      icon: Icons.monitor_heart_rounded,
      gradient: [Color(0xFFFF2D55), Color(0xFFFF6B8A)],
      page: HealthScreen(),
    ),
    _ModuleItem(
      title: 'משפחה',
      subtitle: '3 אירועים קרובים',
      icon: Icons.diversity_3_rounded,
      gradient: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
      page: FamilyScreen(),
    ),
    _ModuleItem(
      title: 'קניות',
      subtitle: '8 פריטים ברשימה',
      icon: Icons.shopping_bag_rounded,
      gradient: [Color(0xFFFF9500), Color(0xFFFFCC00)],
      page: ShoppingScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'בוקר טוב'
        : hour < 17
        ? 'צהריים טובים'
        : 'ערב טוב';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A3A6B),
              Color(0xFF1B4F9E),
              Color(0xFF2563C4),
              Color(0xFF1E88D4),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // ====== כותרת ======
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting, בן',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'שולחן עבודה',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ====== גריד קוביות ======
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.95,
                          ),
                      itemCount: _modules.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 350 + index * 70),
                          curve: Curves.easeOut,
                          builder: (context, value, child) =>
                              Transform.translate(
                                offset: Offset(0, 18 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              ),
                          child: _buildModuleCard(_modules[index]),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(_ModuleItem module) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => module.page,
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 280),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            // עיגולים דקורטיביים
            Positioned(
              bottom: -25,
              right: -25,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              top: -18,
              left: -18,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            // תוכן
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // אייקון גדול עם גרדיאנט
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: module.gradient,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: module.gradient[0].withValues(alpha: 0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(module.icon, color: Colors.white, size: 34),
                  ),
                  const Spacer(),
                  // שם הנושא — גדול ובולט
                  Text(
                    module.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // תת כותרת — בולטת יותר
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      module.subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Widget page;

  const _ModuleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.page,
  });
}
