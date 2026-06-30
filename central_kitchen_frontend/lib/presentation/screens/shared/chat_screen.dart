import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../business/providers/delivery_chat_provider.dart';
import '../../../core/constants/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final bool showBackButton;
  const ChatScreen({super.key, this.showBackButton = true});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  int? _selectedStoreId;
  int? _selectedKitchenId;
  bool _isInit = true;
  late DeliveryChatProvider _chatProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = Provider.of<DeliveryChatProvider>(context, listen: false);
    if (_isInit) {
      final auth = context.read<AuthProvider>();
      
      // Setup default IDs based on roles
      if (auth.userRole == 'KITCHEN_STAFF') {
        _selectedKitchenId = auth.kitchenId ?? 1;
        _chatProvider.fetchStoresAndKitchens().then((_) {
          if (_chatProvider.storesList.isNotEmpty) {
            setState(() {
              _selectedStoreId = _chatProvider.storesList.first['storeId'] as int?;
            });
            _startConversation();
          }
        });
      } else if (auth.userRole == 'SUPPLY_COORDINATOR') {
        _selectedKitchenId = null; // Driver chats with Store, so kitchenId is null
        _chatProvider.fetchStoresAndKitchens().then((_) {
          if (_chatProvider.storesList.isNotEmpty) {
            setState(() {
              _selectedStoreId = _chatProvider.storesList.first['storeId'] as int?;
            });
            _startConversation();
          }
        });
      } else {
        // FRANCHISE_STAFF
        _selectedStoreId = auth.storeId ?? 1;
        _selectedKitchenId = auth.kitchenId ?? 1; // Default to chat with kitchen
        _startConversation();
      }
      _isInit = false;
    }
  }

  void _startConversation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider.loadConversationAsync(_selectedStoreId, _selectedKitchenId).then((_) => _scrollToBottom());
      _chatProvider.startChatPolling(_selectedStoreId, _selectedKitchenId);
    });
  }

  @override
  void dispose() {
    _chatProvider.stopChatPolling();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final chatProvider = context.read<DeliveryChatProvider>();
    final currentUserId = auth.currentUser?.userId;

    if (currentUserId == null) return;

    _messageController.clear();
    await chatProvider.sendMessageAsync(
      senderId: currentUserId,
      storeId: _selectedStoreId,
      kitchenId: _selectedKitchenId,
      messageText: text,
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chatProvider = context.watch<DeliveryChatProvider>();
    
    // Auto scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.primary),
        title: Column(
          children: [
            const Text(
              'Kênh Liên Lạc',
              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              auth.userRole == 'KITCHEN_STAFF' 
                  ? 'Bếp trung tâm ➔ Cửa hàng' 
                  : auth.userRole == 'SUPPLY_COORDINATOR'
                      ? 'Nhân viên giao hàng ➔ Cửa hàng'
                      : _selectedKitchenId != null
                          ? 'Cửa hàng ➔ Bếp trung tâm'
                          : 'Cửa hàng ➔ Nhân viên giao hàng',
              style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: AppTheme.primary),
            onPressed: () {
              chatProvider.loadConversationAsync(_selectedStoreId, _selectedKitchenId);
            },
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: AppTheme.outlineVariant, width: 1),
        ),
      ),
      body: Column(
        children: [
          // Segmented channel toggle selector for Franchise Store
          if (auth.userRole == 'FRANCHISE_STAFF')
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppTheme.outlineVariant, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    showCheckmark: false,
                    label: const Text('Bếp trung tâm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    selected: _selectedKitchenId != null,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedKitchenId = auth.kitchenId ?? 1;
                        });
                        _startConversation();
                      }
                    },
                    selectedColor: AppTheme.primary.withOpacity(0.08),
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: _selectedKitchenId != null ? AppTheme.primary : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    showCheckmark: false,
                    label: const Text('Nhân viên giao hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    selected: _selectedKitchenId == null,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedKitchenId = null;
                        });
                        _startConversation();
                      }
                    },
                    selectedColor: AppTheme.primary.withOpacity(0.08),
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: _selectedKitchenId == null ? AppTheme.primary : const Color(0xFFE2E8F0)),
                    ),
                  ),
                ],
              ),
            ),

          // Dropdown filter for kitchen staff or driver to select stores
          if ((auth.userRole == 'KITCHEN_STAFF' || auth.userRole == 'SUPPLY_COORDINATOR') && chatProvider.storesList.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppTheme.outlineVariant, width: 1)),
              ),
              child: Row(
                children: [
                  const Text('Chọn Cửa Hàng: ', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.outlineVariant),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedStoreId,
                          style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w500),
                          items: chatProvider.storesList.map((store) {
                            return DropdownMenuItem<int>(
                              value: store['storeId'] as int,
                              child: Text(store['storeName'] as String),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedStoreId = val;
                              });
                              _startConversation();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Message list area
          Expanded(
            child: chatProvider.isChatLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : chatProvider.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.outline.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            const Text(
                              'Chưa có tin nhắn nào.\nHãy bắt đầu cuộc trò chuyện!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final msg = chatProvider.messages[index];
                          final isMe = msg.senderId == auth.currentUser?.userId;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isMe) ...[
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppTheme.primaryContainer,
                                    child: Text(
                                      msg.senderName.isNotEmpty ? msg.senderName.substring(0, 1).toUpperCase() : 'U',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isMe ? AppTheme.secondary : Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                                        bottomRight: Radius.circular(isMe ? 4 : 16),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                      border: isMe ? null : Border.all(color: AppTheme.outlineVariant),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!isMe)
                                          Text(
                                            msg.senderName,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.primary,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        if (!isMe) const SizedBox(height: 4),
                                        Text(
                                          msg.messageText,
                                          style: TextStyle(
                                            color: isMe ? Colors.white : AppTheme.onSurface,
                                            fontSize: 15,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatTime(msg.createdAt),
                                          style: TextStyle(
                                            color: isMe ? Colors.white.withOpacity(0.8) : AppTheme.outline,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppTheme.secondaryContainer,
                                    child: Text(
                                      (auth.currentUser?.fullName ?? 'Me').substring(0, 1).toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Message input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppTheme.outlineVariant, width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      style: const TextStyle(fontSize: 15, color: AppTheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: const TextStyle(color: AppTheme.outline),
                        filled: true,
                        fillColor: AppTheme.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 1),
                        ),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryContainer,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final localDt = dt.toLocal();
    final hour = localDt.hour.toString().padLeft(2, '0');
    final minute = localDt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
