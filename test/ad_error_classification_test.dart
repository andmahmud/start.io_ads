import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:start_io_ads_demo/services/start_io_ad_service.dart';

void main() {
  group('StartIoAdService.describeError classification', () {
    test('NO FILL (banner: status 204) maps to the no-fill message', () {
      final error = PlatformException(
        code: 'failed_to_receive_ad',
        message:
            'GET https://sdk-exchange.startappservice.com/1.5/gethtmlad, '
            'status 204, retry',
      );
      final result = StartIoAdService.describeError(error);
      expect(result, startsWith(StartIoAdService.noFillMessage));
      expect(result, contains('Details:'));
    });

    test('NO FILL (native: Empty Response) maps to the no-fill message', () {
      final error = PlatformException(
        code: 'failed_to_receive_ad',
        message: 'Empty Response',
      );
      expect(
        StartIoAdService.describeError(error),
        startsWith(StartIoAdService.noFillMessage),
      );
    });

    test('no_fill error code maps to the no-fill message', () {
      final error = PlatformException(code: 'no_fill');
      expect(
        StartIoAdService.describeError(error),
        startsWith(StartIoAdService.noFillMessage),
      );
    });

    test('network/connectivity failure maps to the network message', () {
      final error = PlatformException(
        code: 'failed_to_receive_ad',
        message:
            'GET https://sdk-exchange.startappservice.com/1.5/gethtmlad, '
            'java.net.UnknownHostException: unable to resolve host',
      );
      expect(
        StartIoAdService.describeError(error),
        startsWith(StartIoAdService.networkMessage),
      );
    });

    test('any other SDK/ad error maps to the generic message', () {
      final error = PlatformException(
        code: 'failed_to_receive_ad',
        message: 'Unexpected server response',
      );
      expect(
        StartIoAdService.describeError(error),
        startsWith(StartIoAdService.genericMessage),
      );
    });

    test('unknown errors also fall back to the generic message', () {
      expect(
        StartIoAdService.describeError(StateError('boom')),
        startsWith(StartIoAdService.genericMessage),
      );
    });
  });
}