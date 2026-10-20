import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  AccountRole _role = AccountRole.recipient;
  String _bloodGroup = 'O+';
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.controller.createProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      location: _locationController.text,
      bloodGroup: _bloodGroup,
      role: _role,
    );
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final profiles = widget.controller.users;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              children: [
                const _BrandMark(),
                const SizedBox(height: 28),
                Text(
                  profiles.isEmpty ? 'Give help.\nFind hope.' : 'Who are you here as?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: const Color(0xFF282321),
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  profiles.isEmpty
                      ? 'Create a profile to connect local donors and people in need.'
                      : 'Choose a saved profile, or create a new one on this device.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: const Color(0xFF716B65), height: 1.45),
                ),
                if (profiles.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  for (final profile in profiles)
                    Card(
                      child: ListTile(
                        leading: _BloodBadge(group: profile.bloodGroup),
                        title: Text(profile.name),
                        subtitle: Text(
                          '${profile.role == AccountRole.donor ? 'Donor' : 'Recipient'} · ${profile.location}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => widget.controller.switchProfile(profile.id),
                      ),
                    ),
                  const SizedBox(height: 26),
                  Text(
                    'CREATE A PROFILE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF776F68),
                        ),
                  ),
                  const SizedBox(height: 12),
                ],
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<AccountRole>(
                        segments: const [
                          ButtonSegment(
                            value: AccountRole.recipient,
                            label: Text('I need blood'),
                            icon: Icon(Icons.search),
                          ),
                          ButtonSegment(
                            value: AccountRole.donor,
                            label: Text('I can donate'),
                            icon: Icon(Icons.volunteer_activism_outlined),
                          ),
                        ],
                        selected: {_role},
                        onSelectionChanged: (selection) =>
                            setState(() => _role = selection.first),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) => value == null || value.trim().length < 2
                            ? 'Enter your name'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) => value == null || value.trim().length < 7
                            ? 'Enter a valid contact number'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _locationController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'City or area',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Enter your city or area'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _bloodGroup,
                        decoration: const InputDecoration(
                          labelText: 'Blood group',
                          prefixIcon: Icon(Icons.bloodtype_outlined),
                        ),
                        items: bloodGroups
                            .map((group) => DropdownMenuItem(
                                  value: group,
                                  child: Text(group),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _bloodGroup = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _saving ? null : _createProfile,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.arrow_forward),
                        label: Text(_saving ? 'Creating profile...' : 'Continue'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: const Color(0xFFAD3140),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Profiles and requests stay on this device. This app is not an emergency service.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF77716B),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFAD3140),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.water_drop, color: Colors.white, size: 23),
          ),
          const SizedBox(width: 10),
          Text(
            'pulse',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
          ),
        ],
      );
}

class _BloodBadge extends StatelessWidget {
  const _BloodBadge({required this.group});

  final String group;

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF5E2E0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          group,
          style: const TextStyle(
            color: Color(0xFFA83240),
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}