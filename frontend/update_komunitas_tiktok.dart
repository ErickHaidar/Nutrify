import 'dart:io';

void main() {
  final file = File('lib/screens/komunitas_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(
    "headerName = 'Membalas \$replyToName';", 
    "headerName = '\${c.userName}' + AppStrings.tiktokReplyIndicator + '\$replyToName';"
  );
  
  // also the mention logic below it:
  // final mentionPrefix = '@$replyToName';
  // we might want to keep it or hide the mention if we use TikTok style. TikTok style doesn't need @replyName in the comment text if we show it in the header.
  
  file.writeAsStringSync(content);
  print('Updated komunitas_screen.dart for TikTok style');
}
