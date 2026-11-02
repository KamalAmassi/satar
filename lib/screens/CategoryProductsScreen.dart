import 'package:flutter/material.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFBF9), // لون الخلفية الموحد للمشروع
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'قرطاسية - ٥ منتجات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1F2B),
            ),
          ),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.black87),
                onPressed: () {},
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF2D1F2B),
                      size: 20,
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D1F2B),
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. شريط البحث
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'شو بتدور عليه اليوم؟',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    icon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. ترويسة القسم مع زر التصفية
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'قرطاسية',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D1F2B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'دفاتر, أقلام وأدوات يومية',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.filter_list,
                      size: 16,
                      color: Color(0xFF2D1F2B),
                    ),
                    label: const Text(
                      'تصفية بالقسم',
                      style: TextStyle(fontSize: 12, color: Color(0xFF2D1F2B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. شبكة المنتجات (Grid View)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
                children: [
                  _buildProductCard(
                    title: 'ألوان خشبية احترافية',
                    subtitle: 'متوفر • 12 لون',
                    price: '18.50 ₪',
                    imageBg: const Color(0xFFF7F2EE),
                  ),
                  _buildProductCard(
                    title: 'دفتر سلك مسطر',
                    subtitle: 'متوفر • A5',
                    price: '12.00 ₪',
                    imageBg: const Color(0xFFF7F2EE),
                  ),
                  _buildProductCard(
                    title: 'مجموعة أقلام تخطيط',
                    subtitle: 'خيارات متعددة',
                    price: '16.00 ₪',
                    imageBg: const Color(0xFFEBEFF2),
                  ),
                  _buildProductCard(
                    title: 'قصة الفيل الصغير ومغامرات الغابة الطويلة',
                    subtitle: 'غير متوفر حالياً',
                    price: '28.00 ₪',
                    imageBg: const Color(0xFFF9F6F0),
                    isUnavailable: true,
                  ),
                  _buildProductCard(
                    title: 'منتج خاص',
                    subtitle: 'الصورة غير متوفرة',
                    price: '',
                    imageBg: const Color(0xFFF2F0F3),
                    isSpecial: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // بطاقة المنتج الفردية
  Widget _buildProductCard({
    required String title,
    required String subtitle,
    required String price,
    required Color imageBg,
    bool isUnavailable = false,
    bool isSpecial = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: imageBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isSpecial
                        ? Icons.inventory_2_outlined
                        : Icons.image_outlined,
                    color: Colors.grey,
                    size: 36,
                  ),
                ),
                if (isSpecial)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D1F2B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'سعر خاص',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF2D1F2B),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isUnavailable ? Colors.red.shade400 : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          if (!isSpecial)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF2D1F2B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isUnavailable
                        ? Colors.grey.shade300
                        : const Color(0xFF2D1F2B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUnavailable ? Icons.add : Icons.add,
                    color: isUnavailable ? Colors.grey.shade600 : Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
