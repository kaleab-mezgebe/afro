import 'dart:convert';

// ─── URLs ─────────────────────────────────────────────────────────────────────
const String kHubUrl = 'https://axumite-api.dev.niyatconsultancy.com/hubs/trip';
const String kApiBase = 'https://axumite-api.dev.niyatconsultancy.com/api';

// ─── JWT ──────────────────────────────────────────────────────────────────────
const String kToken =
    'eyJhbGciOiJSUzI1NiIsImtpZCI6IlNMQ1JMWUNVR1FGTVRLLV9HUVE0RkcyVTVFTVIzVDRVS1BaV19NSjAiLCJ0eXAiOiJhdCtqd3QifQ.eyJpc3MiOiJodHRwczovL2F4dW1pdGUtYXBpLmRldi5uaXlhdGNvbnN1bHRhbmN5LmNvbS8iLCJleHAiOjE3NzY3OTA1NDUsImlhdCI6MTc3Njc4ODc0NSwiYXVkIjoiYS1yaWRlLWFwaSIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgb2ZmbGluZV9hY2Nlc3MiLCJqdGkiOiI3MjQwNzMxMy01NGMyLTRhM2QtYTYxZC1mNmYwYzBkY2E0MGMiLCJzdWIiOiJiODVhYTQ3Yi00ZjY3LTQ4YjQtYjdkYi1lOWMxNzQ3ZGFmNTgiLCJuYW1lIjoiNDQzM2tyQGdtYWlsLmNvbSIsInJvbGUiOiJQYXNzZW5nZXIiLCJQaG9uZU51bWJlciI6IisyNTE5NDU5MTY0NDQiLCJQZXJtaXNzaW9ucyI6WyJQQVNTRU5HRVI6Q3JlYXRlIiwiUEFTU0VOR0VSOlZpZXdNZSIsIlBBU1NFTkdFUjpVcGRhdGVNZSIsIlBBU1NFTkdFUjpSZWFkU2V0dGluZ3MiLCJQQVNTRU5HRVI6VXBkYXRlU2V0dGluZ3MiLCJQQVlNRU5UOlZpZXdNZSIsIk5PVElGSUNBVElPTjpWaWV3TWUiLCJBVVRIOkxvZ291dCJdLCJvaV9wcnN0IjoiZTVkNTU2NTQtMjIzZC00ZTcxLTgxOGUtOWVkOGQ5OTEwZWQyIiwib2lfYXVfaWQiOiJjOTg2ZTY3MC1kYjY3LTQxYzItOTY2YS01MjE2OTJkY2E0Y2QiLCJjbGllbnRfaWQiOiJlNWQ1NTY1NC0yMjNkLTRlNzEtODE4ZS05ZWQ4ZDk5MTBlZDIiLCJvaV90a25faWQiOiJmNjM1NzJjNS1lMDNmLTQxMTUtOTc4ZC0zN2FmZjlmNTA1ZmMifQ.JGE8yZMq8nIqkA3jIzuTPinPTd4V5-VdP8dsNGx_eiYf55Z96gP95u_xEjBJMlSkkQEDcO5CrcoE7KR3IIHWlYg49E-t1yw_8q5iau_YAwWobzBdA4UV3AWnga9BC6jM6JF4lWxCydegEa4UdVc0nyXLbGq6eSv87xdtXFLNwKslrRW92GokMlariK-8z0IT0Y8pzzlmljvW52ksP7CdmcSB9S9Clcs62OyvxBF0PbKBuhZOZHySanpBP6J6_Gujbnn-YlYusO3Swh0Dn6WZa8fvvjuY6O2ZRL8gBK85OT8um6FzRdkvdARqvBwLAoi8RufAnk9Ld8U9Xxc9vnlmbg';

// ─── Test coordinates (Addis Ababa) ───────────────────────────────────────────
const double kPickupLat = 9.0300;
const double kPickupLng = 38.7400;
const double kDropoffLat = 9.0500;
const double kDropoffLng = 38.7600;

// ─── JWT decoder ──────────────────────────────────────────────────────────────
class JwtConfig {
  final String userId;
  final String phoneNumber;
  final String role;
  final DateTime? expiresAt;
  final Map<String, dynamic> raw;

  const JwtConfig({
    required this.userId,
    required this.phoneNumber,
    required this.role,
    this.expiresAt,
    required this.raw,
  });

  factory JwtConfig.fromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return JwtConfig._empty();
    try {
      String payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final claims =
          jsonDecode(utf8.decode(base64Decode(payload)))
              as Map<String, dynamic>;
      final expSec = claims['exp'] as int?;
      return JwtConfig(
        userId: claims['sub']?.toString() ?? '',
        phoneNumber: claims['PhoneNumber']?.toString() ?? '',
        role: claims['role']?.toString() ?? '',
        expiresAt: expSec != null
            ? DateTime.fromMillisecondsSinceEpoch(expSec * 1000)
            : null,
        raw: claims,
      );
    } catch (_) {
      return JwtConfig._empty();
    }
  }

  factory JwtConfig._empty() =>
      const JwtConfig(userId: '', phoneNumber: '', role: '', raw: {});
}

/// Singleton parsed at startup
final JwtConfig jwtConfig = JwtConfig.fromToken(kToken);
