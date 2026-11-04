import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/auth_login/cognito/model/cognito_config.dart';

void main() {
  test('China region endpoint and issuer use partition suffix', () {
    const china = CognitoConfig(
      region: 'cn-north-1',
      userPoolId: 'cn-north-1_Test',
      clientId: 'test123',
    );
    expect(china.isValid, true);
    expect(china.endpoint.host, 'cognito-idp.cn-north-1.amazonaws.com.cn');
    expect(
      china.issuer,
      'https://cognito-idp.cn-north-1.amazonaws.com.cn/cn-north-1_Test',
    );
  });
}
