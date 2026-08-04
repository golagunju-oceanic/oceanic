import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/auth/presentations/provider/auth_provider.dart';
import 'package:oceanic/features/policy/presentation/provider/policy_provider.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';
import 'package:oceanic/presentation/widgets/floating_app_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showCardFront = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);
    final policyState = ref.watch(policyProvider);

    final user = authState.user;
    final card = policyState.card;
    final dependants = policyState.dependants;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 88, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PROFILE HEADER CARD ---
                  _buildProfileHeaderCard(
                    scheme: scheme,
                    userName:
                        card?.fullName ??
                        "${user?.firstName ?? 'Valued'} ${user?.lastName ?? 'Member'}",
                    email: user?.email ?? 'member@oceanichealthng.com',
                    memberId:
                        card?.memberId ?? policyState.policy?.memberId ?? '--',
                    dependantCount: dependants.length,
                  ),

                  const SizedBox(height: 24),

                  // --- DIGITAL CARD TITLE & TOGGLE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Digital Member Card',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),

                      // Front / Back Card Toggle
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildCardSideButton('Front', _showCardFront, () {
                              setState(() => _showCardFront = true);
                            }, scheme),
                            _buildCardSideButton('Back', !_showCardFront, () {
                              setState(() => _showCardFront = false);
                            }, scheme),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // --- DIGITAL HMO CARD VIEW ---
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showCardFront
                        ? _buildCardFront(scheme, card, user)
                        : _buildCardBack(scheme),
                  ),

                  const SizedBox(height: 28),

                  // --- EMERGENCY CONTACT CARD ---
                  _buildSupportInfoCard(scheme),
                ],
              ),
            ),

            // --- FLOATING APP BAR ---
            FloatingAppBar(
              scrollController: _scrollController,
              text: 'Profile',
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  // --- PROFILE HEADER ---
  Widget _buildProfileHeaderCard({
    required ColorScheme scheme,
    required String userName,
    required String email,
    required String memberId,
    required int dependantCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: scheme.primary.withValues(alpha: 0.12),
            child: Icon(Icons.person_rounded, size: 36, color: scheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "ID: $memberId",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$dependantCount Beneficiary${dependantCount == 1 ? '' : 's'}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: scheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD SIDE TOGGLE BUTTON ---
  Widget _buildCardSideButton(
    String title,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme scheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? scheme.onPrimary
                : scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  // --- MEMBER CARD FRONT ---
  Widget _buildCardFront(ColorScheme scheme, dynamic card, dynamic user) {
    const cardBrand = Color(0xFF2C2F7A);

    return Container(
      key: const ValueKey('Front'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
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
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: card?.photo != null && card.photo.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                card.photo,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 54,
                              color: Colors.grey.shade400,
                            ),
                    ),
                    const SizedBox(height: 12),
                    Image.asset(
                      'assets/images/logo.png',
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'OCEANIC HEALTH\nMANAGEMENT LTD.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: cardBrand,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Column(
                    children: [
                      _buildInfoField(
                        'FULL NAME',
                        card?.fullName ??
                            "${user?.firstName ?? ''} ${user?.lastName ?? ''}"
                                .trim(),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoField('I.D NUMBER', card?.memberId ?? '--'),
                      const SizedBox(height: 10),
                      _buildInfoField(
                        'PLAN',
                        card?.planVariant.toUpperCase() ?? 'AQUA SINGLE',
                      ),
                      const SizedBox(height: 10),
                      _buildInfoField('VALIDITY', '31-12-2026'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Metallic Gradient Strip
          Container(
            height: 6,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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

  // --- MEMBER CARD BACK ---
  Widget _buildCardBack(ColorScheme scheme) {
    const cardBrand = Color(0xFF2C2F7A);
    const cardText = Color(0xFF444444);

    return Container(
      key: const ValueKey('Back'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'TERMS & EMERGENCY INFORMATION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: cardBrand,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'The bearer of this card has subscribed to Oceanic Health Management Limited healthcare plan. It entitles the bearer to receive medical care from chosen primary healthcare providers.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: cardText, height: 1.5),
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            '24/7 Call Center: 02013300300',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: cardBrand,
            ),
          ),
          const Text(
            'E-mail: hmo@oceanichealthng.com',
            style: TextStyle(fontSize: 11, color: cardText),
          ),
          const Text(
            'Web: oceanichealth.com',
            style: TextStyle(fontSize: 11, color: cardText),
          ),
          const SizedBox(height: 12),
          Text(
            'If found, please return to:\n266, Murtala Muhammed Way, Alagomeji, Yaba, Lagos State.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
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
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2C2F7A),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2F7A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.isEmpty ? '--' : value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // --- SUPPORT INFO ---
  Widget _buildSupportInfoCard(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.headset_mic_outlined, color: scheme.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                'Help & Enquiries',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'For urgent emergency care, treatment authorizations, or complaints, reach our customer care desk at 02013300300.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: scheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
