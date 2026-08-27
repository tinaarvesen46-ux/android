import 'package:flutter/material.dart';
import '../theme/theme.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  int _selectedPlanIndex = 1; // Default to yearly (best value)

  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      name: 'Monthly',
      price: 3.99,
      period: '/month',
      billingCycle: 'Billed monthly',
      savings: null,
      isPopular: false,
    ),
    SubscriptionPlan(
      name: 'Yearly',
      price: 40.79,
      period: '/year',
      billingCycle: 'Billed annually',
      savings: '15% OFF',
      isPopular: true,
    ),
  ];

  final List<String> _features = [
    'Premium Themes & Customization',
    'Extended Story Privacy Controls',
    'Priority Customer Support',
    'No Advertisements',
    'Advanced Chat Features',
    'Unlimited Media Storage',
    'Custom Profile Badges',
    'Early Access to New Features',
    'HD Video Calls',
    'Enhanced Security Features',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SwiftSnap+',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildPlanSelector(),
            const SizedBox(height: 30),
            _buildFeaturesList(),
            const SizedBox(height: 30),
            _buildSubscribeButton(),
            const SizedBox(height: 20),
            _buildTerms(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.orange.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Upgrade to SwiftSnap+',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock premium features and elevate your messaging experience',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._plans.asMap().entries.map((entry) {
          final index = entry.key;
          final plan = entry.value;
          return _buildPlanCard(plan, index);
        }),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, int index) {
    final isSelected = _selectedPlanIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? SwiftSnapTheme.cardColor : SwiftSnapTheme.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.amber.shade600 : SwiftSnapTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amber.shade600.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.amber.shade600 : Colors.white38,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.billingCycle,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${plan.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      plan.period,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (plan.isPopular)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade600, Colors.orange.shade700],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (plan.savings != null)
              Positioned(
                bottom: -8,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    plan.savings!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Premium Features',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SwiftSnapTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SwiftSnapTheme.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            children: _features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: SwiftSnapTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton() {
    final selectedPlan = _plans[_selectedPlanIndex];
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade600, Colors.orange.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade600.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          _showPurchaseConfirmation(selectedPlan);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Subscribe Now - \$${selectedPlan.price.toStringAsFixed(2)}${selectedPlan.period}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTerms() {
    return Column(
      children: [
        Text(
          'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            _showCancellationInfo();
          },
          child: const Text(
            'How to Cancel Subscription',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 13,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _showPurchaseConfirmation(SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
            SizedBox(width: 12),
            Text(
              'Confirm Subscription',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to subscribe to:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SwiftSnap+ ${plan.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${plan.price.toStringAsFixed(2)}${plan.period}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  if (plan.savings != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Save ${plan.savings}',
                      style: TextStyle(
                        color: Colors.green.shade300,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              plan.billingCycle,
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPurchase(plan);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  void _processPurchase(SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Checkout unavailable',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: const Text(
          'SwiftSnap+ billing is not connected to a payment provider on this account yet, so no charge was made. Your plan selection is saved for when checkout is enabled.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade600, Colors.orange.shade700],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to SwiftSnap+!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your ${plan.name.toLowerCase()} subscription is now active.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Start Exploring'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancellationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Cancel Subscription',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'To cancel your subscription:\n\n'
          '1. Go to Settings > Account\n'
          '2. Tap "Manage Subscription"\n'
          '3. Select "Cancel Subscription"\n\n'
          'You can also manage subscriptions through your device\'s app store settings.',
          style: TextStyle(color: Colors.white70, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class SubscriptionPlan {
  final String name;
  final double price;
  final String period;
  final String billingCycle;
  final String? savings;
  final bool isPopular;

  SubscriptionPlan({
    required this.name,
    required this.price,
    required this.period,
    required this.billingCycle,
    this.savings,
    required this.isPopular,
  });
}
