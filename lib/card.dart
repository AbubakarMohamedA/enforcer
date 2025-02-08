// Card(
// elevation: 4.0,
// color: Colors.amber,
// clipBehavior: Clip.hardEdge,
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(15.0),
// ),
// child: InkWell(
// onTap: (){
//
// },
// child: Container(
// // height: 200,
// padding: EdgeInsets.only(top: 17),
// width: MediaQuery.of(context).size.width,
// margin: const EdgeInsets.only(left: 5),
// decoration: const BoxDecoration(
// color: Colors.white,
// borderRadius: BorderRadius.horizontal(
// left: Radius.circular(15),
// )),
// child: Column(
// children: [
// Padding(
// padding: const EdgeInsets.symmetric(horizontal: 15),
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// Expanded(
// flex:1,
// child: Column(
// mainAxisAlignment: MainAxisAlignment.start,
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text(
// "Name",
// style: GoogleFonts.manrope(
// fontWeight: FontWeight.w700,
// fontSize: 14,
// color:Colors.black.withOpacity(0.4)),
// ),
// SizedBox(height: 1,),
// Text(
// hawker.name,
// style: GoogleFonts.manrope(
// fontWeight: FontWeight.w700,
// fontSize: 16,
// color: Color(0XFF3E4095)),
// ),
// ],
// ),
// ),
// SizedBox(width: 10,),
// Expanded(
// flex:1,
// child: Column(
// mainAxisAlignment: MainAxisAlignment.end,
// crossAxisAlignment: CrossAxisAlignment.end,
// children: [
// Text(
// "Zone",
// style: GoogleFonts.manrope(
// fontWeight: FontWeight.w700,
// fontSize: 14,
// color:Colors.black.withOpacity(0.4)),
// ),
// SizedBox(height: 1,),
// Text(
// hawker.zone,
// style: GoogleFonts.manrope(
// fontWeight: FontWeight.w700,
// fontSize: 16,
// color: Color(0XFF3E4095)),
// ),
// ],
// ),
// )
// ],
// ),
// ),
// SizedBox(height: 10,),
// Align(
// alignment: Alignment.bottomRight,
// child: Container(
// width:screenWidth*0.3,
// decoration: BoxDecoration(
// color: Colors.green,
// borderRadius: BorderRadius.only(
// bottomRight: Radius.circular(15),
// topLeft: Radius.circular(15),
// ),
// ),
// padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// child: Row(
// children: [
// Text(
// "View More",
// style: GoogleFonts.manrope(
// fontWeight: FontWeight.w700,
// fontSize: 14,
// color: Colors.white,
// ),
// ),
// SizedBox(width: 4),
// Icon(
// Icons.arrow_forward_ios,
// color: Colors.white,
// size: 14,
// ),
// ],
// ),
// ),
// )
// ],
// ),
// ),
// ),
// ),