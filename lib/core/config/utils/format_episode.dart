extension FormatEpisode on String {
  String toFormatEpisode () {
    int totalMinutes = int.parse(this.split(" ")[0]); //sử dụng tryParse khi không phải số
    int hours = totalMinutes ~/ 60; //chia lấy nguyên
    int minutes = totalMinutes % 60; //-> chia lấy dư
    return "${hours.toString()}h ${minutes.toString().padLeft(2, '0')}m";
  }
}
// extension FormatEpisode on String {
//   String toFormatEpisode () {
//     int totalMinutes = int.parse(this.split("")[0]); //sử dụng tryParse khi không phải số
//     int hours = totalMinutes ~/ 60; //chia lấy nguyên
//     int minutes = totalMinutes % 60; //-> chia lấy dư
//     return "${minutes.toString()} phút/tập";
//   }
// }
extension ConvertLang on String {
  String toConvertLang () {
    String lang = this;
    switch (lang) {
      case 'Vietsub' : 
      return 'PĐ';
      case 'Lồng Tiếng' : 
      return 'LT';
      case 'Vietsub + Lồng Tiếng' :
      return 'PĐ.LT';
      case 'Vietsub + Thuyết Minh' :
      return 'PĐ.TM';
    }
    // if(lang == 'Vietsub') {
    //   return 'PĐ';
    // }
    // if(lang == 'Lồng Tiếng') {
    //   return 'LT';
    // }
    // if(lang == 'Vietsub + Lồng Tiếng') {
    //   return 'PĐ.LT';
    // }
    // if(lang == 'Vietsub + Thuyết Minh') {
    //   return 'PĐ.TM';
    // }
    
    return 'unKnown';
  }
}