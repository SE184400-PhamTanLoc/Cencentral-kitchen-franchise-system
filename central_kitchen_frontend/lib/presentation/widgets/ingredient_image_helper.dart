import 'package:flutter/material.dart';

/// Hàm ánh xạ từ SKU hoặc Tên nguyên liệu sang đường dẫn hình ảnh asset tương ứng.
String? getIngredientImage(String? sku, String name) {
  final cleanName = name.toLowerCase().trim();
  final cleanSku = sku?.toUpperCase().trim() ?? '';
  
  if (cleanSku == 'RAW-FLOUR' || cleanName.contains('bột mì')) {
    return 'assets/images/bot-mi-la-gi.jpg';
  }
  if (cleanSku == 'RAW-SUGAR' || cleanName.contains('đường')) {
    return 'assets/images/duong.jpg';
  }
  if (cleanSku == 'RAW-BUTTER' || cleanName == 'bơ' || cleanName.contains('bơ thực vật')) {
    return 'assets/images/bo-thuc-vat.jpg';
  }
  if (cleanSku == 'FIN-BREAD' || cleanName == 'vỏ bánh mì' || cleanName == 'bánh mì') {
    return 'assets/images/banhmi.jpg';
  }
  if (cleanSku == 'FIN-MEATBALL' || cleanName == 'xíu mại') {
    return 'assets/images/xiumai.jpg';
  }
  if (cleanSku == 'FIN-BMXM' || cleanName.contains('bánh mì xíu mại')) {
    return 'assets/images/banhmixiumai.jpg';
  }
  if (cleanSku == 'RAW-PORK' || cleanName.contains('thịt heo')) {
    return 'assets/images/thitheo.jpg';
  }
  if (cleanSku == 'RAW-ONION' || cleanName.contains('hành tây') || cleanName.contains('hành')) {
    return 'assets/images/hanhtay.jpg';
  }
  if (cleanSku == 'RAW-PATE' || cleanName.contains('pate')) {
    return 'assets/images/patel.jpg';
  }
  if (cleanSku == 'RAW-HAM' || cleanName.contains('chả lụa') || cleanName.contains('chả')) {
    return 'assets/images/chalua.jpg';
  }
  if (cleanSku == 'RAW-FLOSS' || cleanName.contains('chà bông')) {
    return 'assets/images/chabong.jpg';
  }
  if (cleanSku == 'RAW-EGG' || cleanName.contains('trứng')) {
    return 'assets/images/trungga.jpg';
  }
  if (cleanSku == 'RAW-BEEF' || cleanName.contains('thịt bò')) {
    return 'assets/images/thitbo.jpg';
  }
  if (cleanSku == 'RAW-VEG' || cleanName.contains('dưa leo') || cleanName.contains('rau thơm') || cleanName.contains('rau')) {
    return 'assets/images/dualeo.jpg';
  }
  if (cleanSku == 'FIN-SAUCE' || cleanName.contains('sốt bơ trứng') || cleanName.contains('sốt')) {
    return 'assets/images/sotbotrung.jpg';
  }
  if (cleanSku == 'FIN-BMPC' || cleanName.contains('pate chả lụa')) {
    return 'assets/images/banh-mi-pate-cha-lua.jpg';
  }
  if (cleanSku == 'FIN-BMBN' || cleanName.contains('bò né')) {
    return 'assets/images/banh-mi-bo-ne.jpg';
  }
  if (cleanSku == 'FIN-BMCB' || cleanName.contains('chà bông')) {
    return 'assets/images/banh-mi-cha-bong-dam-bong.jpg';
  }
  return null;
}

/// Widget hiển thị ảnh nguyên liệu từ local assets, hoặc fallback về widget mặc định nếu không khớp.
Widget buildIngredientPreview(String? sku, String name, {double size = 48, double borderRadius = 12, required Widget fallback}) {
  final imagePath = getIngredientImage(sku, name);
  if (imagePath != null) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
  return fallback;
}
