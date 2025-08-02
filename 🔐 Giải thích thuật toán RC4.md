---
title: "\U0001F510 Giải thích thuật toán RC4"

---

# 🔐Giới thiệu thuật toán RC4
RC4 là một thuật toán mã hóa dòng (stream cipher) nổi tiếng được thiết kế bởi Ron Rivest năm 1987. Nó sử dụng một khóa bí mật để tạo ra một chuỗi bit giả ngẫu nhiên (keystream), được dùng để mã hóa/giải mã dữ liệu bằng phép XOR.

---

# Giải thích thuật toán RC4

## 🔧 Giai đoạn 1: Thuật toán khởi tạo khóa (KSA)

Khởi tạo mảng S: `S = [0, 1, 2, ..., 255]`

### Với mỗi i trong 0..255:
```asm
j = (j + S[i] + key[i mod keyLen]) mod 256
swap S[i] và S[j]
i = (i + 1) mod 256
j = (j + S[i]) mod 256
swap S[i], S[j]
t = (S[i] + S[j]) mod 256
keyStreamByte = S[t]
cipherByte = plaintextByte XOR keyStreamByte
```
___

## 🔁Giai đoạn 2: Pseudo-Random Generation Algorithm (PRGA)
✅ Mục tiêu:
Tạo chuỗi keystream để mã hóa plaintext.
### 📌
```asm=i = 0, j = 0
For mỗi byte trong plaintext:
    i = (i + 1) mod 256
    j = (j + S[i]) mod 256
    swap S[i] ↔ S[j]
    t = (S[i] + S[j]) mod 256
    K = S[t]  ; byte keystream
    CipherByte = PlainByte XOR K
```
## 🔓 Giải mã (Decryption)
Giải mã RC4 dùng lại cùng thuật toán PRGA. Vì phép XOR có tính tự đảo, ta dùng lại keystream:
```asm
PlainByte = CipherByte XOR K
```


