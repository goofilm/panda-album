import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/private_album_provider.dart';

class PrivateSettingsPage extends StatefulWidget {
  const PrivateSettingsPage({super.key});

  @override
  State<PrivateSettingsPage> createState() => _PrivateSettingsPageState();
}

class _PrivateSettingsPageState extends State<PrivateSettingsPage> {
  bool _hasPin = false;

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final provider = context.read<PrivateAlbumProvider>();

    final hasPin = await provider.hasPinSet();

    setState(() {
      _hasPin = hasPin;

      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('私密设置'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // PIN 设置区域
          _buildSection(
            '密码设置',
            [
              if (_hasPin) ...[
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: Colors.blue),
                  title: const Text('修改密码'),
                  subtitle: const Text('更改 4 位 PIN 码'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _changePin,
                ),
                ListTile(
                  leading: const Icon(Icons.lock_open, color: Colors.orange),
                  title: const Text('关闭密码'),
                  subtitle: const Text('进入私密相册不再需要验证'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _disablePin,
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Colors.green),
                  title: const Text('设置密码'),
                  subtitle: const Text('设置 4 位 PIN 码保护私密内容'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _setPin,
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // 说明信息
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '说明',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                _infoItem('设置密码后，每次进入私密相册都需要验证'),
                _infoItem('关闭密码后，可直接进入私密相册'),
                _infoItem('忘记密码可通过关闭密码重新设置'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _infoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 6, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setPin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _PinSetupPage(isChange: false)),
    );
  }

  void _changePin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _PinSetupPage(isChange: true)),
    );
  }

  void _disablePin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认关闭'),
        content: const Text('关闭密码后，任何人都可以查看你的私密相册。\n确定要关闭吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('关闭'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<PrivateAlbumProvider>().deletePin();

      if (mounted) {
        setState(() {
          _hasPin = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密码已关闭')),
        );
      }
    }
  }
}

/// PIN 设置/修改页面
class _PinSetupPage extends StatefulWidget {
  final bool isChange;

  const _PinSetupPage({this.isChange = false});

  @override
  State<_PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<_PinSetupPage> {
  String _pin = '';

  String _confirmPin = '';

  bool _isConfirmMode = false;

  String? _error;

  /// 修改密码时需要先验证旧密码
  bool _needVerifyOld = true;

  String _oldPin = '';

  @override
  void initState() {
    super.initState();

    _needVerifyOld = widget.isChange;
  }

  void _onKeyTap(String key) {
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }

    if (_needVerifyOld) {
      // 先验证旧密码
      if (_oldPin.length < 4) {
        setState(() {
          _oldPin += key;
        });

        if (_oldPin.length == 4) {
          _verifyOldPin();
        }
      }
    } else if (!_isConfirmMode) {
      // 输入新密码
      if (_pin.length < 4) {
        setState(() {
          _pin += key;
        });

        if (_pin.length == 4) {
          setState(() {
            _isConfirmMode = true;
            _confirmPin = _pin;
            _pin = '';
          });
        }
      }
    } else {
      // 确认新密码
      if (_pin.length < 4) {
        setState(() {
          _pin += key;
        });

        if (_pin.length == 4) {
          _confirmNewPin();
        }
      }
    }
  }

  void _onDelete() {
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }

    if (_needVerifyOld && _oldPin.isNotEmpty) {
      setState(() {
        _oldPin = _oldPin.substring(0, _oldPin.length - 1);
      });
    } else if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _verifyOldPin() async {
    final provider = context.read<PrivateAlbumProvider>();

    final valid = await provider.verifyPin(_oldPin);

    if (valid) {
      setState(() {
        _needVerifyOld = false;
        _oldPin = '';
      });
    } else {
      setState(() {
        _oldPin = '';

        _error = '原密码错误，请重试';
      });
    }
  }

  Future<void> _confirmNewPin() async {
    if (_pin != _confirmPin) {
      setState(() {
        _pin = '';

        _confirmPin = '';

        _isConfirmMode = false;

        _error = '两次输入不一致，请重新设置';
      });

      return;
    }

    final provider = context.read<PrivateAlbumProvider>();

    await provider.savePin(_pin);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.isChange ? '密码已修改' : '密码已设置')),
    );

    Navigator.pop(context);
  }

  String get _currentInput => _needVerifyOld ? _oldPin : _pin;

  String get _title {
    if (_needVerifyOld) return '验证原密码';

    if (_isConfirmMode) return '再次确认新密码';

    return widget.isChange ? '输入新密码' : '设置密码';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isChange ? '修改密码' : '设置密码'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            Icon(
              widget.isChange ? Icons.lock_reset : Icons.lock_outline,
              size: 56,
              color: Colors.blue.shade300,
            ),

            const SizedBox(height: 20),

            Text(
              _title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 28),

            // PIN 输入指示器
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _currentInput.length
                        ? Colors.blue
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],

            const Spacer(flex: 2),

            // 数字键盘
            _buildKeypad(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          _buildKeyRow(['1', '2', '3']),
          const SizedBox(height: 12),
          _buildKeyRow(['4', '5', '6']),
          const SizedBox(height: 12),
          _buildKeyRow(['7', '8', '9']),
          const SizedBox(height: 12),
          _buildKeyRow(['', '0', 'del']),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key == '') {
          return const SizedBox(width: 72, height: 72);
        }

        if (key == 'del') {
          return GestureDetector(
            onTap: _onDelete,
            child: Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              child: const Icon(
                Icons.backspace_outlined,
                size: 28,
                color: Colors.grey,
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () => _onKeyTap(key),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
            ),
            alignment: Alignment.center,
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
