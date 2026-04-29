import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';
import 'package:water_delivery_app/shared/models/product_model.dart';
import 'package:water_delivery_app/shared/services/product_service.dart';
import 'package:water_delivery_app/shared/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class WaterSelectionScreen extends StatefulWidget {
  const WaterSelectionScreen({super.key});

  @override
  State<WaterSelectionScreen> createState() => _WaterSelectionScreenState();
}

class _WaterSelectionScreenState extends State<WaterSelectionScreen> {
  int _selectedTab = 0; // 0 = Bottles, 1 = Tanks
  List<Product> _bottles = [];
  List<Product> _tanks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bottles = await ProductService.getBottles();
      final tanks = await ProductService.getTanks();

      setState(() {
        _bottles = bottles;
        _tanks = tanks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Product> get _currentProducts => _selectedTab == 0 ? _bottles : _tanks;
  String get _currentSubtitle => _selectedTab == 0
      ? 'Fresh purified water in convenient bottles'
      : 'Large capacity tanks for bulk storage';

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartItemCount = cartProvider.totalItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Water'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.cart);
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      cartItemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : Column(
                  children: [
                    // Tab Selector
                    _buildTabSelector(),

                    // Info Banner
                    _buildInfoBanner(),

                    // Products Grid
                    Expanded(
                      child: _currentProducts.isEmpty
                          ? _buildEmptyState()
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _getCrossAxisCount(context),
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _currentProducts.length,
                              itemBuilder: (context, index) {
                                final product = _currentProducts[index];
                                final cartItem =
                                    cartProvider.getItem(product.id);
                                final quantity = cartItem?.quantity ?? 0;
                                return _buildProductCard(
                                    product, quantity, cartProvider);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 2;
    if (width < 700) return 3;
    return 4;
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Text(
                  '💧 Water Bottles',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 0
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Text(
                  '🗄️ Water Tanks',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 1
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_drink, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentSubtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
      Product product, int quantity, CartProvider cartProvider) {
    final discounted = product.discountPrice != null;
    final priceToShow = discounted ? product.discountPrice! : product.price;
    final originalPrice = discounted ? product.price : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image/Icon
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  product.bottleType == 'tank'
                      ? Icons.opacity
                      : Icons.water_drop,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // Product Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.sizeLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description ?? 'Fresh purified water',
                    style: const TextStyle(fontSize: 11, color: AppColors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (discounted) ...[
                            Text(
                              'TZS ${originalPrice!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 11,
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            'TZS ${priceToShow.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  discounted ? Colors.red : AppColors.primary,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '≈ TZS ${(priceToShow / product.volumeLiters).toStringAsFixed(0)}/L',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.grey),
                          ),
                        ],
                      ),
                      if (quantity == 0)
                        GestureDetector(
                          onTap: () {
                            cartProvider.addItem(product, 1);
                            _showAddedSnackbar(product.name);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 18),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (quantity > 1) {
                                    cartProvider.updateQuantity(
                                        product.id, quantity - 1);
                                  } else {
                                    cartProvider.removeItem(product.id);
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.remove,
                                      size: 16, color: AppColors.primary),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (quantity < product.maxOrderQuantity) {
                                    cartProvider.updateQuantity(
                                        product.id, quantity + 1);
                                  } else {
                                    _showMaxQuantitySnackbar(
                                        product.maxOrderQuantity);
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.add,
                                      size: 16, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.grey),
          const SizedBox(height: 16),
          const Text(
            'Unable to load products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppColors.grey)),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Retry',
            onPressed: _loadProducts,
            width: 150,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedTab == 0 ? Icons.water_drop : Icons.opacity,
            size: 80,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${_selectedTab == 0 ? 'bottles' : 'tanks'} available',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('Please check back later',
              style: TextStyle(color: AppColors.grey)),
        ],
      ),
    );
  }

  void _showAddedSnackbar(String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $productName to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMaxQuantitySnackbar(int maxQuantity) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Maximum quantity reached'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
