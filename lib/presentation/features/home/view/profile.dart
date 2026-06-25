import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';
import 'package:oceanic/presentation/widgets/floating_app_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: CustomDrawer(),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Card',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildSelfSection(scheme),
                          const SizedBox(height: 24),
                          _buildMemberCard(scheme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FloatingAppBar(
              scrollController: _scrollController,
              username: 'User',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelfSection(ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.12),
              child: Icon(
                Icons.person,
                size: 26,
                color: scheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'User',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Beneficiary',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.tertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '0',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemberCard(ColorScheme scheme) {
    // The member card intentionally keeps a light appearance in both modes
    // since it represents a physical ID card with fixed branding colors.
    const cardBrand = Color(0xFF2C2F7A);
    const cardText = Color(0xFF444444);
    const cardSubtext = Color(0xFF888888);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 110,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 150,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'OCEANIC HEALTH\nMANAGEMENT LIMITED',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: cardBrand,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoField('NAME', 'User'),
                      const SizedBox(height: 12),
                      _buildInfoField('I.D NUMBER', 'null'),
                      const SizedBox(height: 12),
                      _buildInfoField('PLAN', 'AQUA SINGLE'),
                      const SizedBox(height: 12),
                      _buildInfoField('VALIDITY', '31-12-2026'),
                      const SizedBox(height: 12),
                      _buildInfoField(
                        'CLIENT',
                        'OCEANIC HEALTH\nMANAGEMENT\nLIMITED',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2C2F7A),
                  Color(0xFF00B4D8),
                  Color(0xFFF5A623),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'The bearer of this card has subscribed to Oceanic Health Management Limited healthcare plan. It entitles the bearer to receive medical care from the chosen primary healthcare provider and emergency care at any Oceanic Health registered provider.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: cardText, height: 1.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'For emergencies and complaint:',
                  style: TextStyle(fontSize: 12, color: cardText),
                ),
                Text(
                  'Call: 02013300300',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cardBrand,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'E-mail: hmo@oceanichealthng.com',
                  style: TextStyle(fontSize: 12, color: cardText),
                ),
                Text(
                  'Web: oceanichealth.com',
                  style: TextStyle(fontSize: 12, color: cardText),
                ),
                const SizedBox(height: 12),
                Text(
                  'If found, please return to:',
                  style: TextStyle(fontSize: 11, color: cardSubtext),
                ),
                Text(
                  '266, Murtala Muhammed Way, Alagomeji, Yaba, Lagos State.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: cardSubtext),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_buildSignature(), _buildSignature()],
                ),
              ],
            ),
          ),
          Container(
            height: 6,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2C2F7A),
                  Color(0xFF00B4D8),
                  Color(0xFFF5A623),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2F7A),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2F7A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignature() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 40,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFBBBBBB))),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Authorized Signature',
          style: TextStyle(fontSize: 10, color: Color(0xFF2C2F7A)),
        ),
      ],
    );
  }
}
