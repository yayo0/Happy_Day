import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';

// Kpostal 우편번호 화면 (콜백 방식)
class KpostalScreen extends StatelessWidget {
  const KpostalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KpostalView(
        callback: (Kpostal result) {
          // 주소 정보를 이전 화면으로 전달
          Navigator.of(
            context,
          ).pop({'postalCode': result.postCode, 'address': result.address});
        },
        useLocalServer: false, // 기본값 사용
      ),
    );
  }
}

// Kpostal 우편번호 화면 (결과값 리턴 방식)
class KpostalScreenReturn extends StatelessWidget {
  final void Function(Map<String, String>)? onResult;

  const KpostalScreenReturn({super.key, this.onResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KpostalView(
        callback: (Kpostal result) {
          onResult?.call({
            'postalCode': result.postCode,
            'address': result.address,
          });
          // 팝은 Kpostal 내부에서 처리될 수 있으므로 여기서는 호출하지 않음
        },
        useLocalServer: false, // 기본값 사용
      ),
    );
  }
}
