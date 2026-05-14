// lib/views/screens/admin/admin_home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/surat_controller.dart';
import '../../../controllers/informasi_controller.dart';
import '../../../models/surat_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/date_helper.dart';
import '../auth/login_screen.dart';
import '../../widgets/info_banner_widget.dart';
import '../user/user_detail_screen.dart';
import '../informasi/informasi_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  final AuthController authController;
  final SuratController suratController;
  final InformasiController informasiController;

  const AdminHomeScreen({
    super.key,
    required this.authController,
    required this.suratController,
    required this.informasiController,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _tabs;

  @override
  void initState() {
    super.initState();
    widget.suratController.loadData();
    widget.informasiController.loadData();
    _tabs = ['Daftar Surat', 'Informasi', 'Dashboard'];
    if (widget.authController.isSuperAdmin) {
      _tabs.add('Kelola User');
    }
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await widget.authController.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginScreen(
          authController: widget.authController,
          suratController: widget.suratController,
          informasiController: widget.informasiController,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.currentUser!;
    final isSuperAdmin = widget.authController.isSuperAdmin;
    final initials = user.namaLengkap.isNotEmpty
        ? user.namaLengkap.trim().split(' ').map((e) => e[0]).take(2).join('')
        : 'A';

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: ListenableBuilder(
        listenable: widget.suratController,
        builder: (context, _) {
          final ctrl = widget.suratController;
          final isLoading = ctrl.loading;

          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // ── Hero Header ──
                    _buildHeroHeader(
                        context,
                        user,
                        initials,
                        ctrl.total,
                        ctrl.jumlahMenunggu,
                        ctrl.jumlahDiproses,
                        ctrl.jumlahSelesai),
                    // ── Info Banner ──
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: InfoBannerWidget(
                        textColor: AppConstants.textPrimary,
                        subTextColor: AppConstants.textSecondary,
                      ),
                    ),
                    // ── Tab Bar ──
                    _buildTabBar(),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _suratTab(isLoading, ctrl),
                InformasiScreen(
                  authController: widget.authController,
                  informasiController: widget.informasiController,
                  showAppBar: false,
                ),
                AdminDashboardScreen(suratController: widget.suratController),
                if (isSuperAdmin) _kelolaUserTab(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, user, String initials,
      int total, int menunggu, int diproses, int selesai) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background banner with wave clip
        ClipPath(
          clipper: _HeaderWaveClipper(),
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppConstants.primaryColor,
              image: DecorationImage(
                image: AssetImage('assets/images/image.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Dark gradient overlay for text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6],
                    ),
                  ),
                ),
                // Decorative circles
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 40,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  left: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                // Logout button top-right
                Positioned(
                  top: 44,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.white, size: 22),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ),
              ],
            ),
          ),
        ),

        // White card below banner with name, role, and stats
        Padding(
          padding: const EdgeInsets.only(top: 200),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
              child: Column(
                children: [
                  // Name & verified badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.namaLengkap,
                        style: GoogleFonts.poppins(
                          color: AppConstants.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded,
                          color: Color(0xFF5DB075), size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Role subtitle
                  Text(
                    AppConstants.roleLabel(user.role),
                    style: GoogleFonts.poppins(
                      color: AppConstants.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(total.toString(), 'Total'),
                      _buildStatDivider(),
                      _buildStatItem(menunggu.toString(), 'Menunggu',
                          AppConstants.accentColor),
                      _buildStatDivider(),
                      _buildStatItem(diproses.toString(), 'Diproses',
                          AppConstants.secondaryColor),
                      _buildStatDivider(),
                      _buildStatItem(selesai.toString(), 'Selesai',
                          AppConstants.successColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Avatar – LAST in Stack, selalu tampil di atas kartu putih
        Positioned(
          top: 158,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF5DB075), Color(0xFF3A9E5F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, [Color? valueColor]) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: valueColor ?? AppConstants.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppConstants.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppConstants.surfaceLight,
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: AppConstants.textSecondary,
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppConstants.primaryColor,
            width: 3,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
        ),
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }


  Widget _suratTab(bool isLoading, SuratController ctrl) {
    final surat = ctrl.daftarTampil();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        );
      },
      child: ListView.builder(
        key: ValueKey('list-${ctrl.filterStatus}-$isLoading'),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
        itemCount: isLoading ? 6 : (surat.isEmpty ? 2 : surat.length + 1),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  TextField(
                    onChanged: ctrl.setQuery,
                    style: GoogleFonts.poppins(
                        color: AppConstants.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Cari nama, NIK, atau nomor surat...',
                      hintStyle: GoogleFonts.poppins(
                          color: AppConstants.textSecondary, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppConstants.textSecondary, size: 20),
                      filled: true,
                      fillColor: AppConstants.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppConstants.surfaceLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppConstants.surfaceLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppConstants.primaryColor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Menunggu', 'Diproses', 'Selesai']
                          .map((s) => _filterChip(s, ctrl))
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          }
          if (isLoading) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSkeletonCard(),
            );
          }
          if (surat.isEmpty) {
            return SizedBox(
              height: 300,
              child: _emptyState(key: ValueKey('empty-${ctrl.filterStatus}')),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _suratCard(surat[i - 1]),
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, SuratController ctrl) {
    final isSelected = ctrl.filterStatus == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected
                ? AppConstants.surfaceColor
                : AppConstants.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => ctrl.setFilter(label),
        backgroundColor: AppConstants.surfaceColor,
        selectedColor: AppConstants.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? AppConstants.primaryColor
                : AppConstants.surfaceLight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _suratCard(SuratModel surat) {
    final statusColor = AppConstants.statusColor(surat.status);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => UserDetailScreen(
            surat: surat,
            suratController: widget.suratController,
            isAdmin: true,
          ),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left accent bar
                Container(
                  width: 4,
                  color: statusColor,
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                surat.jenisSurat,
                                style: GoogleFonts.poppins(
                                  color: AppConstants.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(AppConstants.statusIcon(surat.status),
                                      color: statusColor, size: 11),
                                  const SizedBox(width: 4),
                                  Text(
                                    surat.status,
                                    style: GoogleFonts.poppins(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded,
                                color: AppConstants.textSecondary, size: 13),
                            const SizedBox(width: 4),
                            Text(surat.namaPemohon,
                                style: GoogleFonts.poppins(
                                    color: AppConstants.textSecondary,
                                    fontSize: 12)),
                            const Spacer(),
                            Text(
                                DateHelper.formatPendek(surat.tanggalPengajuan),
                                style: GoogleFonts.poppins(
                                    color: AppConstants.textSecondary,
                                    fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          surat.nomorSurat,
                          style: GoogleFonts.poppins(
                            color: AppConstants.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState({Key? key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.inbox_rounded,
                color: AppConstants.primaryColor, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada surat',
            style: GoogleFonts.poppins(
              color: AppConstants.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Belum ada pengajuan surat',
            style: GoogleFonts.poppins(
              color: AppConstants.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Kelola User (SuperAdmin only) ──
  Widget _kelolaUserTab() {
    return FutureBuilder<List>(
      future: widget.authController.getAllUsers(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppConstants.primaryColor));
        }
        final users = snap.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (_, i) {
            final u = users[i] as dynamic;
            final isDefault =
                AppConstants.defaultAccounts.any((a) => a['id'] == u.id);
            final roleColor = AppConstants.roleColor(u.role);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppConstants.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppConstants.surfaceLight, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(AppConstants.roleIcon(u.role),
                        color: roleColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.namaLengkap,
                            style: GoogleFonts.poppins(
                                color: AppConstants.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        Text('@${u.username}',
                            style: GoogleFonts.poppins(
                                color: AppConstants.textSecondary,
                                fontSize: 12)),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(AppConstants.roleLabel(u.role),
                              style: GoogleFonts.poppins(
                                  color: roleColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  if (!isDefault)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppConstants.errorColor, size: 20),
                      onPressed: () async {
                        final konfirmasi = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: AppConstants.surfaceColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: Text('Hapus User?',
                                style: GoogleFonts.poppins(
                                    color: AppConstants.textPrimary,
                                    fontWeight: FontWeight.bold)),
                            content: Text(
                                'User "${u.namaLengkap}" akan dihapus.',
                                style: GoogleFonts.poppins(
                                    color: AppConstants.textSecondary)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Batal',
                                    style: GoogleFonts.poppins(
                                        color: AppConstants.textSecondary)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.errorColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Hapus',
                                    style: GoogleFonts.poppins(
                                        color: AppConstants.surfaceColor)),
                              ),
                            ],
                          ),
                        );
                        if (konfirmasi == true) {
                          await widget.authController.hapusUser(u.id);
                          setState(() {});
                        }
                      },
                    ),
                  if (isDefault)
                    const Icon(Icons.lock_rounded,
                        color: AppConstants.textSecondary, size: 18),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Skeleton Loading ────────────────────────────────────────────────────────

  Widget _buildSkeletonList() {
    return ListView.builder(
      key: const ValueKey('skeleton'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: 5,
      itemBuilder: (_, __) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar skeleton
              _shimmerBox(width: 4, height: double.infinity),
              // Content
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: _shimmerBox(
                                  width: double.infinity,
                                  height: 14,
                                  radius: 6)),
                          const SizedBox(width: 12),
                          _shimmerBox(width: 72, height: 22, radius: 11),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _shimmerBox(width: 120, height: 11, radius: 5),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _shimmerBox(width: 130, height: 11, radius: 5),
                          const Spacer(),
                          _shimmerBox(width: 18, height: 18, radius: 9),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 4,
  }) {
    return _ShimmerBox(width: width, height: height, radius: radius);
  }
}

// ── Shimmer animation widget ─────────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          width: widget.width == double.infinity ? null : widget.width,
          height: widget.height == double.infinity ? null : widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFE0E0E0),
                Color(0xFFEEEEEE),
              ],
              stops: [
                (_animation.value - 0.5).clamp(0.0, 1.0),
                _animation.value.abs().clamp(0.0, 1.0),
                (_animation.value + 0.5).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Custom Clipper for Wavy Header ───────────────────────────────────────────

class _HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Start from top-left, go down to just above bottom
    path.lineTo(0, size.height - 40);

    // First curve (dips down)
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 20);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    // Second curve (goes up slightly)
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 40);
    var secondEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    // Go to top-right and close
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
