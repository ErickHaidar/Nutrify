import 'dart:io';

void main() {
  final file = File('lib/screens/user_profile_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(
    "_buildStatItem('Postingan', _postsCount),",
    "_buildStatItem(AppStrings.posts, _postsCount),"
  );
  content = content.replaceAll(
    "_buildStatItem('Mengikuti', _followingCount),",
    "_buildStatItem(AppStrings.followingCountLabel, _followingCount),"
  );
  content = content.replaceAll(
    "_buildStatItem('Pengikut', _followerCount),",
    "_buildStatItem(AppStrings.followersCountLabel, _followerCount),"
  );
  content = content.replaceAll(
    "_isFollowing ? 'Diikuti' : _isRequested ? 'Diminta' : 'Ikuti',",
    "_isFollowing ? AppStrings.followingStatus : _isRequested ? AppStrings.requestedStatus : AppStrings.followStatus,"
  );
  
  file.writeAsStringSync(content);
  print('Fixed user_profile_screen.dart');
}
