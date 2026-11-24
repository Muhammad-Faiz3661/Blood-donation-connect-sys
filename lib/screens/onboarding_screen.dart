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
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  AccountRole _role = AccountRole.recipient;
  String _bloodGroup = 'O+';
  bool _saving = false;
  bool _isCreatingProfile = false;
  String? _loginError;

  @override
  void initState() {
    super.initState();
    _isCreatingProfile = widget.controller.users.isEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _userIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = widget.controller;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    await controller.createProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      location: _locationController.text,
      bloodGroup: _bloodGroup,
      role: _role,
      password: _passwordController.text,
    );
    final accountId = controller.currentUser?.id;
    if (accountId != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Profile created. Your account ID is $accountId'),
          duration: const Duration(seconds: 8),
        ),
      );
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _loginError = null;
    });
    final success = await widget.controller.login(
      userId: _userIdController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (!success) _loginError = 'ID or password is incorrect.';
    });
  }

  final _loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final profiles = widget.controller.users;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF8F7), Color(0xFFF8F5F1), Color(0xFFF1EAE3)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  const _BrandMark(),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFB92F45), Color(0xFFE76576)],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2E8A1020),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            profiles.isEmpty
                                ? 'A single act.\nA lifesaving impact.'
                                : _isCreatingProfile
                                    ? 'Create your\nPulse profile'
                                    : 'Good to\nhave you back',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 76,
                          height: 76,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0x30FFFFFF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                Text(
                  profiles.isEmpty
                      ? 'Give help.\nFind hope.'
                      : _isCreatingProfile
                          ? 'Create your profile'
                          : 'Welcome back',
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
                      : _isCreatingProfile
                          ? 'Your account will get a unique ID. Keep it safe with your password.'
                          : 'Log in with your unique account ID and password.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: const Color(0xFF716B65), height: 1.45),
                ),
                if (profiles.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                              _isCreatingProfile = !_isCreatingProfile;
                              _loginError = null;
                              _passwordController.clear();
                              _confirmPasswordController.clear();
                            }),
                    child: Text(
                      _isCreatingProfile
                          ? 'Already have an account? Log in'
                          : 'New here? Create a profile',
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (_isCreatingProfile)
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
                          validator: (value) =>
                              value == null || value.trim().length < 2
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
                          validator: (value) =>
                              value == null || value.trim().length < 7
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
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter your city or area'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _bloodGroup,
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
                            if (value != null) {
                              setState(() => _bloodGroup = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Create password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) =>
                              value == null || value.length < 8
                                  ? 'Use at least 8 characters'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) =>
                              value != _passwordController.text
                                  ? 'Passwords do not match'
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _saving ? null : _createProfile,
                          icon: _saving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward),
                              label: Text(
                                _saving ? 'Creating profile...' : 'Create profile',
                              ),
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
                  )
                else
                  Form(
                    key: _loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _userIdController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Unique account ID',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter your account ID'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter your password'
                                  : null,
                        ),
                        if (_loginError != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _loginError!,
                            style: const TextStyle(color: Color(0xFFAD3140)),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _saving ? null : _login,
                          icon: _saving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.login),
                          label: Text(_saving ? 'Logging in...' : 'Log in'),
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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFB92F45), Color(0xFFE76576)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22B92F45),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
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
