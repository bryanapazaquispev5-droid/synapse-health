---
name: code-documenter
description: Standardized Clean Code commenting and docstring generation protocol for Dart/Flutter, TypeScript/JavaScript, Python, and C++/Arduino based on alirezarezvani/claude-skills, roebi/agent-skills, and Uncle Bob Clean Code. Use when the user asks to comment, document, add docstrings, explain functions, or generate API/code documentation.
---

# Code Documenter Protocol (Clean Code & Standard Docstrings)

Expert code commenting and docstring standard for professional, maintainable, and legible software architectures. Strictly enforces the **"Why, not What"** Clean Code rule and official language docstring specifications.

---

## 1. Golden Rules of Code Commenting

### 1.1 The "Why, Not What" Principle (Strict Anti-Noise)
* **NEVER** write redundant comments that restate obvious syntax:
  ```dart
  // ❌ BAD (Noise / Redundant):
  // increment counter
  count++;

  //  GOOD (Intent & Context):
  // Throttle request count to enforce API rate limits (max 5 req/min).
  count++;
  ```
* **ALWAYS** comment:
  1. **Business Rationale:** Why a specific algorithm, formula, or fallback exists.
  2. **Edge Cases & Workarounds:** Why a special condition or delay is needed.
  3. **Security Context (OWASP):** Why tokens are stored in Keychain/Keystore or sanitized.
  4. **Complex State Transitions:** Multi-step asynchronous flows or state machines.

### 1.2 No Dead / Zombie Code
* **NEVER** leave commented-out legacy code (`// oldCode();`). Git manages history.

---

## 2. Standardized Formats by Tech Stack

### 2.1 Dart & Flutter (Official DartDoc Standard)
* Use triple slashes (`///`) for all public classes, methods, and functions.
* Use square brackets (`[ClassName]`, `[methodName]`) to enable IDE symbol hyperlinks.
* Document parameters, return values, and possible exceptions:
```dart
/// Manages user authentication and token refresh cycles with Firebase Auth.
///
/// Throws an [AuthException] if network connectivity is lost during the handshake.
///
/// Example:
/// ```dart
/// final auth = AuthService();
/// await auth.signInWithToken(token);
/// ```
class AuthService {
  /// Authenticates user against backend API.
  ///
  /// [token] The raw JWT bearer token received from the identity provider.
  /// Returns a [UserSession] containing immutable claims.
  Future<UserSession> authenticate(String token) async {
    // ...
  }
}
```

### 2.2 TypeScript & JavaScript (TSDoc / JSDoc Standard)
* Use standard `/** ... */` block comments with typed tags (`@param`, `@returns`, `@throws`, `@deprecated`):
```typescript
/**
 * Calculates the total shopping cart price including regional VAT and active discounts.
 *
 * @param items - List of validated cart items.
 * @param taxRate - Percentage rate (e.g. 0.18 for 18% VAT).
 * @param discountCode - Optional promo code applied before tax.
 * @returns Final price rounded to 2 decimal places in USD.
 * @throws {InvalidTaxRateError} When taxRate is negative or exceeds 1.0.
 */
export function calculateCartTotal(
  items: CartItem[],
  taxRate: number,
  discountCode?: string
): number {
  // ...
}
```

### 2.3 Python (PEP 257 & Google Style Docstrings)
* Use triple double-quotes (`"""..."""`) immediately following function/class definitions:
```python
def process_biometric_data(user_id: str, raw_samples: list[float]) -> dict:
    """Processes and normalizes raw sensor readings for heart-rate variability.

    Applies a 50Hz low-pass Butterworth filter to eliminate motion artifacts
    before computing standard deviation intervals.

    Args:
        user_id: Unique UUIDv4 string representing the patient.
        raw_samples: Unfiltered voltage readings from ADC channel 1.

    Returns:
        Dictionary containing 'hrv_score' and 'is_anomaly_detected'.

    Raises:
        ValueError: If raw_samples contains fewer than 10 data points.
    """
    # ...
```

### 2.4 C++ / Arduino / ESP32 (Doxygen Standard)
* Use standard Doxygen blocks (`/** ... */`) with `@brief`, `@param`, `@return`:
```cpp
/**
 * @brief Reads calibrated temperature from DS18B20 OneWire sensor.
 * 
 * Non-blocking read using hardware timer interrupts to avoid freezing FreeRTOS loop.
 * 
 * @param pin GPIO pin assigned to OneWire bus (must be pull-up enabled).
 * @return float Temperature in Celsius (-55.0 to +125.0).
 */
float readTemperature(uint8_t pin) {
  // ...
}
```

---

## 3. Workflow & Trigger Handling

When the user asks to:
* *"Comenta este código"*
* *"Documenta este archivo / función / clase"*
* *"Add docstrings"*
* *"Explica qué hace este método en el código"*

1. **Surgical Application:** Target the specific function or class using `replace_file_content`.
2. **File Size Compliance:** Ensure comments are concise and descriptive so the total file stays under **250 lines**.
3. **No Logic Alteration:** Never modify the underlying execution logic when adding comments.
