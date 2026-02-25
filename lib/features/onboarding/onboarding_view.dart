import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  // Controller untuk PageView
  late PageController _pageController;
  int _currentPage = 0;

  // Data onboarding
  final List<OnboardingData> _onboardingList = [
    OnboardingData(
      image: 'assets/images/onboarding1.png',
      title: 'Selamat Datang',
      description: 'Aplikasi LogBook membantu Anda mencatat setiap aktivitas dengan mudah dan rapi.',
    ),
    OnboardingData(
      image: 'assets/images/onboarding2.jpg',
      title: 'Kelola Counter',
      description: 'Tambah atau kurangi nilai counter dengan langkah yang dapat disesuaikan.',
    ),
    OnboardingData(
      image: 'assets/images/onboarding3.jpg',
      title: 'Pantau Riwayat',
      description: 'Lihat semua aktivitas Anda dalam riwayat yang terorganisir dengan baik.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // PageView untuk menampilkan gambar dan teks
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onboardingList.length,
              itemBuilder: (context, index) {
                return _buildOnboardingPage(
                  _onboardingList[index],
                );
              },
            ),
          ),

          // Page Indicator (Dots)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _onboardingList.length,
              effect: const ExpandingDotsEffect(
                dotHeight: 12,
                dotWidth: 12,
                activeDotColor: Colors.blue,
                dotColor: Colors.grey,
                spacing: 8,
              ),
            ),
          ),

          // Tombol Navigation
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Skip
                TextButton(
                  onPressed: () {
                    _pageController.jumpToPage(_onboardingList.length - 1);
                  },
                  child: const Text('Skip'),
                ),

                // Tombol Next / Get Started
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _onboardingList.length - 1) {
                      // Halaman terakhir - ke Login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                      );
                    } else {
                      // Lanjut ke halaman berikutnya
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _currentPage == _onboardingList.length - 1
                        ? 'Get Started'
                        : 'Next',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk setiap halaman onboarding
  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gambar
          Image.asset(
            data.image,
            height: 300,
            width: 300,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),

          // Judul
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Deskripsi
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Model untuk data onboarding
class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}