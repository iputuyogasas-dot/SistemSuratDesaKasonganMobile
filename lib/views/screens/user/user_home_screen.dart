// lib/views/screens/user/user_home_screen.dart

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
import '../informasi/informasi_screen.dart';
import '../informasi/informasi_detail_screen.dart';
import '../../widgets/informasi_card_widget.dart';
import 'user_tambah_screen.dart';
import 'user_detail_screen.dart';

class UserHomeScreen extends StatefulWidget {
  final AuthController authController;
  final SuratController suratController;
  final InformasiController informasiController;

  const UserHomeScreen({
    super.key,
    required this.authController,
    required this.suratController,
    required this.informasiController,
  });

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Semua', 'Menunggu', 'Diproses', 'Selesai'];
  int _currentTab = 0;

  String get _userId => widget.authController.userId;

  @override
  void initState() {
    super.initState();
    widget.suratController.loadData();
    widget.informasiController.loadData();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.suratController.setFilter(_tabs[_tabController.index]);
      }
    });
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
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // ── Konten utama (indexed tabs) ──
          Positioned.fill(
            child: IndexedStack(
              index: _currentTab,
              children: [
                _buildHomeContent(),
                InformasiScreen(
                  authController: widget.authController,
                  informasiController: widget.informasiController,
                  showAppBar: false,
                ),
                InformasiScreen(
                  authController: widget.authController,
                  informasiController: widget.informasiController,
                  initialTabIndex: 3, // Tab "Disematkan"
                  showAppBar: false,
                ),
              ],
            ),
          ),
          // ── Floating Bottom Nav ──
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SafeArea(
              bottom: true,
              child: _buildFloatingNav(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    final user = widget.authController.currentUser!;
    final initials = user.namaLengkap.isNotEmpty
        ? user.namaLengkap.trim().split(' ').map((e) => e[0]).take(2).join()
        : 'U';

    return ListenableBuilder(
      listenable: widget.suratController,
      builder: (context, _) {
        final isLoading = widget.suratController.loading;
        final total = widget.suratController.totalUser(user.id);
        final menunggu = widget.suratController.menungguUser(user.id);
        final selesai = widget.suratController.selesaiUser(user.id);
        final surat =
            widget.suratController.daftarTampil(filterUserId: user.id);

        return NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // ── Hero Header ──
                  _buildHeroHeader(
                      context, user, initials, total, menunggu, selesai),
                  // ── Info Banner ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: InfoBannerWidget(
                      textColor: AppConstants.textPrimary,
                      subTextColor: AppConstants.textSecondary,
                    ),
                  ),
                  // ── Informasi Terbaru Section ──
                  _buildInformasiSection(),
                  // ── Tab Bar ──
                  _buildTabBar(),
                ],
              ),
            ),
          ],
          body: AnimatedSwitcher(
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
            child: isLoading
                ? _buildSkeletonList()
                : surat.isEmpty
                    ? _emptyState(
                        key: ValueKey(
                            'empty-${widget.suratController.filterStatus}'))
                    : ListView.builder(
                        key: ValueKey(
                            'list-${widget.suratController.filterStatus}'),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        itemCount: surat.length,
                        itemBuilder: (_, i) => _suratCard(surat[i]),
                      ),
          ),
        );
      },
    );
  }

  // ── Floating Bottom Navigation Bar ────────────────────────────────────────

  Widget _buildFloatingNav() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ColorFilter.mode(
          Colors.white.withOpacity(0.8),
          BlendMode.srcOver,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navTab(0, Icons.home_rounded, 'Home'),
              _navTab(1, Icons.info_outline_rounded, 'Info'),
              _navTab(2, Icons.bookmark_outline_rounded, 'Saved'),
              _navAction(
                Icons.add_box_rounded,
                onTap: () async {
                  await Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => UserTambahScreen(
                        suratController: widget.suratController,
                        userId: widget.authController.currentUser!.id,
                      ),
                      transitionsBuilder: (_, anim, __, child) =>
                          SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                            parent: anim, curve: Curves.easeOutCubic)),
                        child: child,
                      ),
                    ),
                  );
                },
                iconColor: AppConstants.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navTab(int index, IconData icon, String label) {
    final isActive = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppConstants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppConstants.textSecondary,
              size: 20,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _navAction(
    IconData icon, {
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          color: iconColor ?? AppConstants.textSecondary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, user, String initials,
      int total, int menunggu, int selesai) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background banner with wave clip
        ClipPath(
          clipper: HeaderClipper(),
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
                        Colors.black.withOpacity(0.6),
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
                      color: Colors.white.withOpacity(0.07),
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
                    'Warga Kasongan',
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
                      _buildStatItem(total.toString(), 'Total Surat'),
                      _buildStatDivider(),
                      _buildStatItem(menunggu.toString(), 'Menunggu'),
                      _buildStatDivider(),
                      _buildStatItem(selesai.toString(), 'Selesai'),
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
                    color: AppConstants.primaryColor.withOpacity(0.3),
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppConstants.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
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
        border: Border(
          bottom: BorderSide(color: AppConstants.surfaceLight, width: 1),
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
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(
            color: AppConstants.primaryColor,
            width: 3,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
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
            isAdmin: false,
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
              color: Colors.black.withOpacity(0.05),
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
                                color: statusColor.withOpacity(0.1),
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
                        const SizedBox(height: 4),
                        Text(
                          surat.nomorSurat,
                          style: GoogleFonts.poppins(
                            color: AppConstants.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                color: AppConstants.textSecondary, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              DateHelper.formatPanjang(surat.tanggalPengajuan),
                              style: GoogleFonts.poppins(
                                color: AppConstants.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right_rounded,
                                color: AppConstants.primaryColor, size: 18),
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
      ),
    );
  }

  Widget _emptyState({Key? key}) {
    return SingleChildScrollView(
      key: key,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.inbox_rounded,
                    color: AppConstants.primaryColor, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada surat',
                style: GoogleFonts.poppins(
                  color: AppConstants.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap tombol di bawah untuk mengajukan surat baru',
                style: GoogleFonts.poppins(
                  color: AppConstants.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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

  // ── Informasi Terbaru Section ─────────────────────────────────────────────

  Widget _buildInformasiSection() {
    return ListenableBuilder(
      listenable: widget.informasiController,
      builder: (context, _) {
        final items =
            widget.informasiController.semuaInformasi.take(3).toList();
        if (items.isEmpty) return const SizedBox.shrink();

        return Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppConstants.primaryColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Informasi Terbaru',
                      style: GoogleFonts.poppins(
                        color: AppConstants.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InformasiScreen(
                            authController: widget.authController,
                            informasiController: widget.informasiController,
                          ),
                        ),
                      ),
                      child: Text(
                        'Lihat Semua →',
                        style: GoogleFonts.poppins(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 170,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return SizedBox(
                      width: 280,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InformasiCardWidget(
                          item: item,
                          isBookmarked:
                              false, // Tidak ditampilkan di home compact
                          isCompact: true,
                          onBookmark:
                              null, // Sembunyikan tombol bookmark di home
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InformasiDetailScreen(
                                item: item,
                                informasiController: widget.informasiController,
                                userId: _userId,
                                isAdmin: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
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

class HeaderClipper extends CustomClipper<Path> {
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
