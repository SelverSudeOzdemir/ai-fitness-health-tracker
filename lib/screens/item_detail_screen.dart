import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;

  const ItemDetailScreen({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _imageUrlController;

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController =
        TextEditingController(text: widget.item.description ?? '');
    _priceController = TextEditingController(
      text: widget.item.price.toStringAsFixed(2),
    );
    _categoryController =
        TextEditingController(text: widget.item.category ?? '');
    _imageUrlController =
        TextEditingController(text: widget.item.imageUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Detayı'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Düzenlemeyi iptal et
                  _titleController.text = widget.item.title;
                  _descriptionController.text = widget.item.description ?? '';
                  _priceController.text = widget.item.price.toStringAsFixed(2);
                  _categoryController.text = widget.item.category ?? '';
                  _imageUrlController.text = widget.item.imageUrl ?? '';
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: _isEditing ? _buildEditView() : _buildDetailView(),
    );
  }

  // ==================== DETAY GÖRÜNÜMÜ ====================

  Widget _buildDetailView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ürün Resmi
          _buildProductImage(),

          // Ürün Bilgileri
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  widget.item.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Kategori
                if (widget.item.category != null)
                  Chip(
                    label: Text(widget.item.category!),
                    backgroundColor: Colors.blue[100],
                  ),
                const SizedBox(height: 16),

                // Fiyat
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₺${widget.item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Açıklama
                const Text(
                  'Açıklama',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.item.description ?? 'Açıklama bulunmuyor',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Stok Bilgisi
                if (widget.item.stockQuantity != null)
                  _buildInfoRow(
                    'Stok:',
                    '${widget.item.stockQuantity} adet',
                  ),

                const SizedBox(height: 8),

                // Oluşturma Tarihi
                if (widget.item.createdAt != null)
                  _buildInfoRow(
                    'Oluşturulma:',
                    widget.item.createdAt!,
                  ),

                const SizedBox(height: 24),

                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showDeleteDialog();
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Sil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _shareItem();
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Paylaş'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DÜZENLEME GÖRÜNÜMÜ ====================

  Widget _buildEditView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim Önizlemesi
            Center(
              child: _buildProductImage(),
            ),
            const SizedBox(height: 24),

            // Başlık
            _buildTextField(
              controller: _titleController,
              label: 'Başlık',
              hint: 'Ürün başlığını gir',
            ),
            const SizedBox(height: 16),

            // Kategori
            _buildTextField(
              controller: _categoryController,
              label: 'Kategori',
              hint: 'Kategori adını gir',
            ),
            const SizedBox(height: 16),

            // Fiyat
            _buildTextField(
              controller: _priceController,
              label: 'Fiyat',
              hint: '0.00',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Açıklama
            _buildTextField(
              controller: _descriptionController,
              label: 'Açıklama',
              hint: 'Ürün açıklamasını gir',
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            // Resim URL'i
            _buildTextField(
              controller: _imageUrlController,
              label: 'Resim URL\'i',
              hint: 'https://example.com/image.jpg',
            ),
            const SizedBox(height: 24),

            // Kaydet Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Değişiklikleri Kaydet',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== YARDIMCI WİDGETLER ====================

  Widget _buildProductImage() {
    if (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.item.imageUrl!,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported, size: 64),
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_not_supported, size: 64),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: _getIconForLabel(label),
        ),
      ),
    );
  }

  Widget _getIconForLabel(String label) {
    switch (label) {
      case 'Başlık':
        return const Icon(Icons.title);
      case 'Kategori':
        return const Icon(Icons.category);
      case 'Fiyat':
        return const Icon(Icons.attach_money);
      case 'Açıklama':
        return const Icon(Icons.description);
      case 'Resim URL\'i':
        return const Icon(Icons.image);
      default:
        return const Icon(Icons.edit);
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // ==================== İŞLEMLER ====================

  Future<void> _saveChanges() async {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Başlık boş olamaz', Colors.red);
      return;
    }

    if (_priceController.text.isEmpty) {
      _showSnackBar('Fiyat boş olamaz', Colors.red);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedItem = Item(
      id: widget.item.id,
      title: _titleController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text) ?? widget.item.price,
      imageUrl: _imageUrlController.text,
      category: _categoryController.text,
      stockQuantity: widget.item.stockQuantity,
      userId: widget.item.userId,
      createdAt: widget.item.createdAt,
    );

    final success = await context.read<ItemProvider>().updateItem(
          widget.item.id,
          updatedItem,
        );

    setState(() {
      _isSaving = false;
    });

    if (success) {
      _showSnackBar('Ürün güncellendi', Colors.green);
      setState(() {
        _isEditing = false;
      });
      // Sayfayı yenile
      Navigator.pop(context);
    } else {
      _showSnackBar('Güncelleme başarısız', Colors.red);
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Sil'),
        content: const Text(
          'Bu ürünü silmek istediğinizden emin misiniz?\n\nBu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final success = await context.read<ItemProvider>().deleteItem(
                    widget.item.id,
                  );

              if (mounted) {
                if (success) {
                  _showSnackBar('Ürün silindi', Colors.green);
                  Navigator.pop(context);
                } else {
                  _showSnackBar('Silme başarısız', Colors.red);
                }
              }
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _shareItem() {
    final text = '''
${widget.item.title}

Fiyat: ₺${widget.item.price.toStringAsFixed(2)}
Kategori: ${widget.item.category ?? 'Belirtilmemiş'}

${widget.item.description ?? ''}
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paylaş'),
        content: SelectableText(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          TextButton(
            onPressed: () {
              // Gerçek uygulamada share_plus paketini kullan
              _showSnackBar('Paylaşıldı', Colors.green);
              Navigator.pop(context);
            },
            child: const Text('Paylaş'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
