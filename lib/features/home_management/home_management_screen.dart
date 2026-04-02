import 'package:flutter/material.dart';
import '../car/car_screen.dart';
import '../finance/finance_screen.dart';
import '../health/health_screen.dart';
import '../shopping/shopping_screen.dart';
import '../family/family_screen.dart';
import 'home_details_screen.dart';

class HomeManagementScreen extends StatelessWidget {
  const HomeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // בר עליון שחור
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 25),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: const Center(
              child: Text(
                'שולחן עבודה',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          // כרטיס פרופיל (צמצמנו קצת את ה-Margin כדי לתת מקום לריבועים)
          Transform.translate(
            offset: const Offset(0, -15),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(
                      Icons.account_circle,
                      color: Color(0xFF1976D2),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'שלום בן,',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      Text(
                        'מה התוכנית להיום?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // רשת הכפתורים - כיסוי שטח מקסימלי
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ), // צמצום רווחים מהצדדים
              crossAxisCount: 2,
              mainAxisSpacing: 15, // רווח אנכי בין ריבועים
              crossAxisSpacing: 15, // רווח אופקי בין ריבועים
              childAspectRatio:
                  0.88, // הקטנת המספר הופכת את הריבועים לגבוהים יותר (מכסה יותר שטח)
              children: [
                _buildModernCard(
                  context,
                  'ניהול הבית',
                  Icons.roofing_rounded,
                  [const Color(0xFF4A00E0), const Color(0xFF8E2DE2)],
                  const HomeDetailsScreen(),
                  '4 משימות',
                ),
                _buildModernCard(
                  context,
                  'הרכב שלי',
                  Icons.directions_car_filled_rounded,
                  [const Color(0xFFFF5F6D), const Color(0xFFFFC371)],
                  const CarScreen(),
                  'טיפול בקרוב',
                ),
                _buildModernCard(
                  context,
                  'פיננסים',
                  Icons.account_balance_wallet_rounded,
                  [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                  const FinanceScreen(),
                  '₪15,240',
                ),
                _buildModernCard(
                  context,
                  'בריאות',
                  Icons.favorite_rounded,
                  [const Color(0xFFEB3349), const Color(0xFFF45C43)],
                  const HealthScreen(),
                  'תור מחר',
                ),
                _buildModernCard(
                  context,
                  'משפחה',
                  Icons.family_restroom_rounded,
                  [const Color(0xFF2193B0), const Color(0xFF6DD5ED)],
                  const FamilyScreen(),
                  '3 אירועים',
                ),
                _buildModernCard(
                  context,
                  'קניות',
                  Icons.local_mall_rounded,
                  [const Color(0xFFF7971E), const Color(0xFFFFD200)],
                  const ShoppingScreen(),
                  '8 פריטים',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradientColors,
    Widget targetPage,
    String subtitle,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            25,
          ), // פינות מעט פחות מעוגלות כדי להרוויח שטח ויזואלי
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // אייקון בפינה
            Positioned(
              top: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
            ),

            // מלל ממורכז
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
