flutter devicesimport 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final user = widget.controller.currentUser!;
    final isDonor = user.role == AccountRole.donor;
    final destinations = isDonor
        ? const [
            NavigationDestination(
              icon: Icon(Icons.inbox_outlined),
              selectedIcon: Icon(Icons.inbox),
              label: 'Requests',
            ),
            NavigationDestination(
              icon: Icon(Icons.volunteer_activism_outlined),
              selectedIcon: Icon(Icons.volunteer_activism),
              label: 'Availability',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ]
        : const [
            NavigationDestination(
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.manage_search),
              label: 'Find donors',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'My requests',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.water_drop, color: Color(0xFFAD3140), size: 22),
            const SizedBox(width: 8),
            Text(
              'pulse',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE8D9CF),
              child: Text(
                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF533F36),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: isDonor
            ? [
                _DonorInbox(controller: widget.controller),
                _AvailabilityPage(controller: widget.controller),
                _ProfilePage(controller: widget.controller),
              ]
            : [
                _FindDonorsPage(controller: widget.controller),
                _MyRequestsPage(controller: widget.controller),
                _ProfilePage(controller: widget.controller),
              ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        destinations: destinations,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
      ),
    );
  }
}

class _DonorInbox extends StatelessWidget {
  const _DonorInbox({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final incoming = controller.incomingRequests;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const _PageHeading(
          eyebrow: 'YOUR DONOR PORTAL',
          title: 'Requests',
          subtitle: 'People nearby who could use your help.',
        ),
        const SizedBox(height: 16),
        if (incoming.isEmpty)
          const _EmptyState(
            icon: Icons.inbox_outlined,
            title: 'All quiet for now',
            message: 'New donation requests will appear here.',
          )
        else
          for (final request in incoming)
            _IncomingRequestCard(
              request: request,
              controller: controller,
            ),
      ],
    );
  }
}

class _IncomingRequestCard extends StatelessWidget {
  const _IncomingRequestCard({
    required this.request,
    required this.controller,
  });

  final DonationRequest request;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == RequestStatus.pending;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _BloodBadge(group: request.bloodGroup),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requesterName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '${request.location} · ${_dateLabel(request.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF716B65),
                            ),
                      ),
                    ],
                  ),
                ),
                _StatusPill(status: request.status),
              ],
            ),
            const SizedBox(height: 14),
            _DetailLine(icon: Icons.local_hospital_outlined, text: request.hospital),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              _DetailLine(icon: Icons.notes, text: request.note),
            ],
            if (request.status == RequestStatus.accepted) ...[
              const SizedBox(height: 8),
              _DetailLine(
                icon: Icons.phone_outlined,
                text: request.requesterPhone,
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => controller.updateRequestStatus(
                        request.id,
                        RequestStatus.declined,
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => controller.updateRequestStatus(
                        request.id,
                        RequestStatus.accepted,
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ] else if (request.status == RequestStatus.accepted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => controller.updateRequestStatus(
                    request.id,
                    RequestStatus.completed,
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark donation complete'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AvailabilityPage extends StatelessWidget {
  const _AvailabilityPage({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const _PageHeading(
          eyebrow: 'YOUR DONOR PORTAL',
          title: 'Availability',
          subtitle: 'You choose when people can find you.',
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: user.isAvailable
                        ? const Color(0xFFE1EFE8)
                        : const Color(0xFFF0EBE6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    user.isAvailable
                        ? Icons.volunteer_activism
                        : Icons.pause_circle_outline,
                    color: user.isAvailable
                        ? const Color(0xFF34786F)
                        : const Color(0xFF756D65),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.isAvailable ? 'Available to be contacted' : 'Taking a break',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.isAvailable
                            ? 'Your profile appears in donor searches.'
                            : 'Your profile is hidden from donor searches.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              height: 1.4,
                              color: const Color(0xFF716B65),
                            ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: user.isAvailable,
                  onChanged: controller.setAvailability,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _InfoBanner(
          icon: Icons.info_outline,
          text:
              'Only accept requests when it feels right for you. Donation eligibility is determined by a qualified medical professional.',
        ),
      ],
    );
  }
}

class _FindDonorsPage extends StatefulWidget {
  const _FindDonorsPage({required this.controller});

  final AppController controller;

  @override
  State<_FindDonorsPage> createState() => _FindDonorsPageState();
}

class _FindDonorsPageState extends State<_FindDonorsPage> {
  static const _anyBloodGroup = 'Any blood group';

  final _searchController = TextEditingController();
  late String _bloodGroup;

  @override
  void initState() {
    super.initState();
    _bloodGroup = widget.controller.currentUser!.bloodGroup;
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final matches = widget.controller.availableDonors.where((donor) {
      final sameGroup =
          _bloodGroup == _anyBloodGroup || donor.bloodGroup == _bloodGroup;
      final matchesSearch = query.isEmpty ||
          donor.location.toLowerCase().contains(query) ||
          donor.name.toLowerCase().contains(query);
      return sameGroup && matchesSearch;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const _PageHeading(
          eyebrow: 'RECIPIENT PORTAL',
          title: 'Find a donor',
          subtitle: 'Search available donors by blood group and area.',
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: _bloodGroup,
          decoration: const InputDecoration(
            labelText: 'Blood group',
            prefixIcon: Icon(Icons.bloodtype_outlined),
          ),
          items: [_anyBloodGroup, ...bloodGroups]
              .map((group) => DropdownMenuItem(value: group, child: Text(group)))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _bloodGroup = value);
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _searchController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Search a city or area',
            prefixIcon: Icon(Icons.location_on_outlined),
            suffixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '${matches.length} ${matches.length == 1 ? 'donor' : 'donors'} available',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF716B65),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        if (matches.isEmpty)
          const _EmptyState(
            icon: Icons.person_search_outlined,
            title: 'No donors found',
            message:
                'Try another area or check back later. You can add a donor profile from the profile tab on this device.',
          )
        else
          for (final donor in matches)
            _DonorCard(
              donor: donor,
              onRequest: () => _showRequestDialog(context, donor),
            ),
      ],
    );
  }

  Future<void> _showRequestDialog(BuildContext context, AppUser donor) async {
    final formKey = GlobalKey<FormState>();
    final hospitalController = TextEditingController();
    final locationController = TextEditingController(
      text: widget.controller.currentUser!.location,
    );
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Contact ${donor.name.split(' ').first}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: hospitalController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Hospital or clinic',
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a hospital or clinic'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: locationController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'City or area',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a location'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: noteController,
                maxLines: 2,
                maxLength: 160,
                decoration: const InputDecoration(
                  labelText: 'Short note (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Send request'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.controller.createRequest(
        donor: donor,
        hospital: hospitalController.text,
        location: locationController.text,
        note: noteController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent to the donor.')),
        );
      }
    }
    hospitalController.dispose();
    locationController.dispose();
    noteController.dispose();
  }
}

class _DonorCard extends StatelessWidget {
  const _DonorCard({required this.donor, required this.onRequest});

  final AppUser donor;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _BloodBadge(group: donor.bloodGroup),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donor.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 3),
                        _DetailLine(
                          icon: Icons.location_on_outlined,
                          text: donor.location,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.circle, size: 10, color: Color(0xFF34786F)),
                  const SizedBox(width: 5),
                  const Text(
                    'Available',
                    style: TextStyle(
                      color: Color(0xFF34786F),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onRequest,
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: const Text('Send a request'),
                ),
              ),
            ],
          ),
        ),
      );
}

class _MyRequestsPage extends StatelessWidget {
  const _MyRequestsPage({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final outgoing = controller.outgoingRequests;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const _PageHeading(
          eyebrow: 'RECIPIENT PORTAL',
          title: 'My requests',
          subtitle: 'Keep track of responses and next steps.',
        ),
        const SizedBox(height: 16),
        if (outgoing.isEmpty)
          const _EmptyState(
            icon: Icons.assignment_outlined,
            title: 'No requests yet',
            message: 'When you contact a donor, your request will show up here.',
          )
        else
          for (final request in outgoing)
            _OutgoingRequestCard(request: request, controller: controller),
      ],
    );
  }
}

class _OutgoingRequestCard extends StatelessWidget {
  const _OutgoingRequestCard({
    required this.request,
    required this.controller,
  });

  final DonationRequest request;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final donor = controller.userById(request.donorId);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _BloodBadge(group: request.bloodGroup),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donor?.name ?? 'Donor profile unavailable',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '${request.hospital} · ${_dateLabel(request.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF716B65),
                            ),
                      ),
                    ],
                  ),
                ),
                _StatusPill(status: request.status),
              ],
            ),
            if (request.status == RequestStatus.accepted && donor != null) ...[
              const Divider(height: 24),
              _DetailLine(icon: Icons.phone_outlined, text: donor.phone),
              _DetailLine(
                icon: Icons.location_on_outlined,
                text: '${donor.name} · ${donor.location}',
              ),
            ],
            if (request.status == RequestStatus.pending) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => controller.updateRequestStatus(
                    request.id,
                    RequestStatus.cancelled,
                  ),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Cancel request'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const _PageHeading(
          eyebrow: 'ACCOUNT',
          title: 'Your profile',
          subtitle: 'Your contact details are shared only after a request is accepted.',
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFFF2DEDC),
                  child: Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFAD3140),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.role == AccountRole.donor ? 'Donor' : 'Recipient',
                  style: const TextStyle(color: Color(0xFF716B65)),
                ),
                const Divider(height: 28),
                _DetailLine(icon: Icons.bloodtype_outlined, text: user.bloodGroup),
                _DetailLine(icon: Icons.phone_outlined, text: user.phone),
                _DetailLine(icon: Icons.location_on_outlined, text: user.location),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showProfiles(context),
          icon: const Icon(Icons.switch_account_outlined),
          label: const Text('Switch or add profile'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
        const SizedBox(height: 16),
        const _InfoBanner(
          icon: Icons.health_and_safety_outlined,
          text:
              'Pulse helps people connect. A hospital or qualified medical professional must confirm blood type, eligibility, and arrangements.',
        ),
      ],
    );
  }

  Future<void> _showProfiles(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Switch profile',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                for (final profile in controller.users)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _BloodBadge(group: profile.bloodGroup),
                    title: Text(profile.name),
                    subtitle: Text(
                      '${profile.role == AccountRole.donor ? 'Donor' : 'Recipient'} · ${profile.location}',
                    ),
                    trailing: profile.id == controller.currentUser?.id
                        ? const Icon(Icons.check_circle, color: Color(0xFF34786F))
                        : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      controller.switchProfile(profile.id);
                    },
                  ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    controller.switchProfile(null);
                  },
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Create another profile'),
                ),
              ],
            ),
          ),
        ),
      );
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFFAD3140),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF282321),
                ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: const Color(0xFF716B65),
                ),
          ),
        ],
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFFEFE9E2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFAD3140), size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.45,
                    color: const Color(0xFF716B65),
                  ),
            ),
          ],
        ),
      );
}

class _BloodBadge extends StatelessWidget {
  const _BloodBadge({required this.group});

  final String group;

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      RequestStatus.accepted || RequestStatus.completed => const Color(0xFF34786F),
      RequestStatus.pending => const Color(0xFF98651C),
      RequestStatus.declined || RequestStatus.cancelled => const Color(0xFF756D65),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF77716B)),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF514B45),
                      height: 1.4,
                    ),
              ),
            ),
          ],
        ),
      );
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFECE9E0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 19, color: const Color(0xFF7A643D)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.45,
                      color: const Color(0xFF5E554A),
                    ),
              ),
            ),
          ],
        ),
      );
}

String _dateLabel(DateTime date) {
  final local = date.toLocal();
  final now = DateTime.now();
  if (local.year == now.year && local.month == now.month && local.day == now.day) {
    return 'Today';
  }
  return '${local.day}/${local.month}/${local.year}';
}