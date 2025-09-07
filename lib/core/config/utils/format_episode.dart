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