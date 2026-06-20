import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../business/providers/delivery_chat_provider.dart';
import '../../../core/constants/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  int? _selectedStoreId;
  int? _selectedKitchenId;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final auth = context.read<AuthProvider>();
      final deliveryChat = context.read<DeliveryChatProvider>();
      
      // Setup default IDs based on roles
      if (auth.userRole == 'KITCHEN_STAFF') {
        _selectedKitchenId = auth.kitchenId ?? 1;
        deliveryChat.fetchStoresAndKitchens().then((_) {
          if (deliveryChat.storesList.isNotEmpty) {
            setState(() {
              _selectedStoreId = deliveryChat.storesList.first['storeId'] as int?;
            });
            _startConversation();
          }
        });
      } else {
        // FRANCHISE_STAFF or MANAGER or ADMIN
        _selectedStoreId = auth.storeId ?? 1;
        _selectedKitchenId = auth.kitchenId ?? 1; // Default kitchen
        _startConversation();
      }
      _isInit = false;
    }
  }

  void _startConversation() {
    final chatProvider = context.read<DeliveryChatProvider>();
    chatProvider.loadConversationAsync(_selectedStoreId, _selectedKitchenId).then((_) => _scrollToBottom());
    chatProvider.startChatPolling(_selectedStoreId, _selectedKitchenId);
  }

  @override
  void dispose() {
    final chatProvider = context.read<DeliveryChatProvider>();
    chatProvider.stopChatPolling();
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
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: AppTheme.primary.withOpacity(0.85),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: true,
              title: Column(
                children: [
                  const Text(
                    'Kênh Liên Lạc',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  Text(
                    auth.userRole == 'KITCHEN_STAFF' 
                        ? 'Bếp trung tâm -> Cửa hàng' 
                        : 'Cửa hàng -> Bếp trung tâm',
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.sync_rounded, color: Colors.white),
                  onPressed: () {
                    chatProvider.loadConversationAsync(_selectedStoreId, _selectedKitchenId);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Dynamic Background Elements
          Positioned(
            top: 100, right: -50,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.secondary.withOpacity(0.15), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: 200, left: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.primary.withOpacity(0.1), Colors.transparent]),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 60),
          // Dropdown filter for kitchen staff to select stores
          if (auth.userRole == 'KITCHEN_STAFF' && chatProvider.storesList.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  const Text('Chọn Cửa Hàng: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedStoreId,
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
                                    backgroundColor: AppTheme.secondary,
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
                                      gradient: isMe 
                                          ? const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0072FF)])
                                          : null,
                                      color: isMe ? null : Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(20),
                                        topRight: const Radius.circular(20),
                                        bottomLeft: Radius.circular(isMe ? 20 : 4),
                                        bottomRight: Radius.circular(isMe ? 4 : 20),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isMe ? const Color(0xFF0072FF).withOpacity(0.3) : Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                                      border: isMe ? null : Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
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
                                    backgroundColor: AppTheme.primaryContainer,
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

          // Floating Glassmorphism Input Bar
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 4,
                        minLines: 1,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          hintStyle: TextStyle(color: AppTheme.outline.withOpacity(0.7)),
                          filled: true,
                          fillColor: AppTheme.background.withOpacity(0.5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0072FF)]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0xFF0072FF), blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
