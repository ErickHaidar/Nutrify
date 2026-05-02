import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/utils/locale/app_strings.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.helpTitle,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle(AppStrings.aboutNutrify),
          _buildCard(AppStrings.aboutNutrifyDesc),
          const SizedBox(height: 20),
          _buildSectionTitle(AppStrings.howToTrack),
          _buildStepCard('1', AppStrings.stepSearchTitle, AppStrings.stepSearchDesc),
          _buildStepCard('2', AppStrings.stepSelectTitle, AppStrings.stepSelectDesc),
          _buildStepCard('3', AppStrings.stepSaveTitle, AppStrings.stepSaveDesc),
          const SizedBox(height: 20),
          _buildSectionTitle(AppStrings.howToSetGoals),
          _buildCard(AppStrings.goalGuideDesc),
          const SizedBox(height: 12),
          _buildGoalCard(AppStrings.cutting, AppStrings.cuttingDesc, Icons.trending_down),
          _buildGoalCard(AppStrings.maintain, AppStrings.maintainDesc, Icons.remove),
          _buildGoalCard(AppStrings.bulking, AppStrings.bulkingDesc, Icons.trending_up),
          const SizedBox(height: 20),
          _buildSectionTitle(AppStrings.faq),
          _buildFaqCard(AppStrings.faqQ1, AppStrings.faqA1),
          _buildFaqCard(AppStrings.faqQ2, AppStrings.faqA2),
          _buildFaqCard(AppStrings.faqQ3, AppStrings.faqA3),
          _buildFaqCard(AppStrings.faqQ4, AppStrings.faqA4),
          _buildFaqCard(AppStrings.faqQ5, AppStrings.faqA5),
          const SizedBox(height: 30),
          Center(
            child: Text(
              'Nutrify v1.0.0+5',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.navy.withOpacity(0.4),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),
    );
  }

  Widget _buildCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.navy.withOpacity(0.8)),
      ),
    );
  }

  Widget _buildStepCard(String number, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.amber,
            child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navy)),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppColors.navy.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.amber, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navy)),
                Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppColors.navy.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard(String question, String answer) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(question, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navy)),
      children: [
        Text(answer, style: GoogleFonts.inter(fontSize: 13, color: AppColors.navy.withOpacity(0.7))),
      ],
    );
  }
}
