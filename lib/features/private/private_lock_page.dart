import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/private_album_provider.dart';
import 'private_album_page.dart';
import 'private_settings_page.dart';

class PrivateLockPage extends StatefulWidget {
  const PrivateLockPage({super.key});

  @override
  State<PrivateLockPage> createState() => _PrivateLockPageState();
}

class _PrivateLockPageState extends State<PrivateLockPage> {
  String _pin = '';

  String _confirmPin = '';

  bool _isConfirmMode = false;

  bool _hasPin = false;

  bool _initialized = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _checkPin();
  }

  Future<void> _checkPin() async {
    final provider = context.read<PrivateAlbumProvider>();

    _hasPin = await provider.hasPinSet();

    setState(() {
      _initialized = true;
    });
  }

  void _onKeyTap(String key) {
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }

    if (_hasPin) {
      // 验证模式
      if (_pin.length < 4) {
        setState(() {
          _pin += key;
        });

        if (_pin.length == 4) {
          _verifyPin();
        }
      }
    } else {
      // 设置模式
      if (!_isConfirmMode) {
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
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _error = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    final provider = context.read<PrivateAlbumProvider>();

    final valid = await provider.verifyPin(_pin);

    if (valid) {
      provider.unlock();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (_) => const PrivateAlbumPage()),
      );
    } else {
      setState(() {
        _pin = '';

        _error = 'PIN 码错误，请重试';
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

    provider.unlock();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,

      MaterialPageRoute(builder: (_) => const PrivateAlbumPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final title = _hasPin
        ? '输入 PIN 码'
        : (_isConfirmMode ? '再次确认 PIN 码' : '设置 PIN 码');

    return Scaffold(
      appBar: AppBar(
        title: const Text('私密相册'),
        actions: [
          if (_hasPin)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: '设置',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivateSettingsPage(),
                  ),
                );
              },
            ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // 锁图标
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Colors.blue.shade300,
            ),

            const SizedBox(height: 24),

            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

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
                    color: i < _pin.length
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
