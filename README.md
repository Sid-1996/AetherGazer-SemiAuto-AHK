<!-- Google Search Console Verification -->
<meta name="google-site-verification" content="cp1I1EkUOFzDxlgMDqINp5rkt2t4MaocapRQO0qwBjA" />

# 深空之眼 Sid 半自動腳本

[![GitHub stars](https://img.shields.io/github/stars/Sid-1996/AetherGazer-SemiAuto-AHK?style=for-the-badge&logo=github)](https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/Sid-1996/AetherGazer-SemiAuto-AHK?style=for-the-badge&logo=github)](https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/forks)
[![GitHub issues](https://img.shields.io/github/issues/Sid-1996/AetherGazer-SemiAuto-AHK?style=for-the-badge&logo=github)](https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/issues)
[![GitHub license](https://img.shields.io/github/license/Sid-1996/AetherGazer-SemiAuto-AHK?style=for-the-badge&logo=github)](https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/blob/main/LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/Sid-1996/AetherGazer-SemiAuto-AHK?style=for-the-badge&logo=github)](https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/releases/latest)
[![GitHub downloads](https://img.shields.io/github/downloads/Sid-1996/AetherGazer-SemiAuto-AHK/total?style=for-the-badge&logo=github)](https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/releases)
[![GitHub last commit](https://img.shields.io/github/last-commit/Sid-1996/AetherGazer-SemiAuto-AHK?style=for-the-badge&logo=github)](https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/commits/main)
[![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0-red?style=for-the-badge&logo=autohotkey)](https://www.autohotkey.com/)
[![Windows](https://img.shields.io/badge/Windows-10%2B-blue?style=for-the-badge&logo=windows)](https://www.microsoft.com/windows/)

---  
本倉庫僅提供 **代碼邏輯演示版（不可執行）**，所有細節與演算法均已省略或替換為註解。  
實際可執行版本已打包成 **EXE 壓縮檔**，請前往 Releases 頁面下載。  

---

## 🎮 專案簡介
這是一款針對 **《深空之眼 (Aether Gazer)》** 所設計的 **半自動戰鬥輔助腳本**，由 Sid 製作。  
設計目標是降低戰鬥時間的人工作業，同時保留即時手動介入的彈性。

---

## ✨ 主要功能特色
- **自動戰鬥核心**
  - 自動判定技能可用狀態與普攻施放
  - 基於像素/圖片偵測的冷卻判斷與保護
  - 偵測 WASD 移動中時暫緩施放，避免干擾手操
- **角色特化模式**
  - 內建角色選擇：**通用模式、魂羽、緋染、巧构**（**其它**功能開發中）
  - 角色模式優先於通用偵測，針對技能圖示進行強化判斷
- **狀態疊圖 Overlay**
  - 顯示腳本狀態、戰鬥狀態、目前動作、模式與普攻開關、當前角色
- **輸入優化**
  - 以 **直接傳送至遊戲視窗** 的方式發送按鍵，降低與玩家操作衝突

---

作者環境為 **陸服 PC 版本** 製作，台服尚未測試。  
因作者角色有限，目前 **F5 專屬模式** 僅支援作者所擁有的角色。  

## 🖥 環境要求

- **螢幕解析度**：僅支援 `1920×1080`
- **遊戲視窗模式**：僅支援 `1600×900`
- ⚠️ **重要提醒**：請務必在 `1920×1080` 的螢幕解析度下，  
  使用 `1600×900` 的遊戲視窗模式進行
- ⌨️ 可使用 **F2** 一鍵調整並置中遊戲視窗

---

## ⌨️ 熱鍵一覽（對應腳本實作）

| 熱鍵  | 功能 |
|-------|------|
| **F1**  | 切換 **自動普攻**（開/關） |
| **F2**  | 調整 **遊戲視窗為 1600×900 並置中**，並啟用該視窗 |
| **F3**  | 開啟/關閉 **熱鍵說明面板**（Help GUI） |
| **F4**  | **手動暫停/恢復** 腳本；暫停時 **進入戰鬥會自動恢復** |
| **F5**  | 開啟 **角色選擇面板**（通用模式、魂羽、緋染、巧构；赤音顯示「開發中」） |
| **F6**  | 切換 **烤肉模式**（自動按 **E/Q**；啟用時暫停其他自動邏輯） |
| **F7**  | **手動檢測腳本更新狀態** |
| **F11** | **重新載入** 腳本 |
| **F12** | **結束** 腳本 |

> 註：以上描述均直接對應腳本內的熱鍵區塊與 Help GUI 顯示內容。

---

## 📦 使用方式
1. 前往 Releases 下載最新的 **EXE 壓縮包**。  
2. 解壓並執行 `深空之眼Sid半自動腳本.exe`。  
3. 將遊戲設為 **視窗模式 1600×900**（可按 **F2** 自動調整）。  
4. 進入關卡後按 **F5** 選擇角色模式，按 **F1/F6** 視需求啟用普攻/烤肉模式。  

---

## ⚠️ 注意事項
- 此倉庫內 `.ahk` 僅為 **邏輯演示版**，不可直接執行。  
- 可執行版本請務必從 **Releases** 取得。  
- 本腳本僅供 **學術研究、技術展示與個人學習** 之用，**禁止商業用途**。  
- 本腳本對應 **視窗模式 1600×900**，其他解析度不保證可用。  

---

## 🔒 授權聲明
本專案採用 **Sid 自定義授權條款**（見下方 LICENSE）。

---

## 📬 聯絡方式
作者：Sid  
GitHub：[@Sid-1996](https://github.com/Sid-1996)  
YouTube：[@SID-v7t](https://www.youtube.com/@SID-v7t)

---

## ☕ 支持作者  

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/K3K11KMXOL)  

[🔗 Support This Project](https://www.paypal.com/ncp/payment/4YCFVARX3ADGW](https://www.paypal.com/ncp/payment/GJS4D5VTSVWG4))  

[💚 綠界科技贊助（支持作者）](https://p.ecpay.com.tw/E0E3A)  

[![Donate via ECPay](https://payment.ecpay.com.tw/Upload/QRCode/201901/QRCode_21c4c069-547f-4115-9f8d-2c050273f028.png)](https://p.ecpay.com.tw/E0E3A)  
感謝每一位支持者！💖

---

Sid Custom License v1.0
=======================

Copyright (c) 2025 Sid

Permission is hereby granted, free of charge, to any individual
obtaining a copy of this software (the “Software”), to use the
Software strictly under the following conditions:

1) Permission is granted solely for **personal use, study, and research**.
2) Redistribution of the Software, in original or modified form,
   is **strictly prohibited** without prior written consent from the author.
3) Commercial use, including but not limited to selling, licensing,
   bundling, or monetizing the Software in any form, is **strictly prohibited**.
4) Modification for private use is allowed, but **publishing or redistributing
   modified versions** requires explicit authorization from the author.
5) Any derivative works, forks, or public releases based on the Software
   must first obtain written approval from the author.

Violation of these terms may result in revocation of usage rights
and potential legal action.
