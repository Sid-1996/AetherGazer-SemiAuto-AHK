# FindText 整合指南

## 專案特別說明

**重要提醒：本專案使用特殊的座標轉換機制來整合 FindText，所有 FindText 相關工作都必須遵循此標準流程。**

## 工作流程

### 1. 圖片代碼獲取
- 使用者提供 FindText 圖片代碼（如：`"|<>*127$33.03rzzzk3zzzzk3..."`）
- 這些代碼是透過 FindText 工具截取遊戲畫面並轉換為文字格式

### 2. Agent 修改步驟
當收到新的圖片代碼時，Agent 必須：

#### 步驟 A：添加文字常數
在 `src/apps/SidAgApp.ahk` 的全域變數區添加：
```autohotkey
global [CharacterName][SkillName]Text := "|<>*127$33.03rzzzk3zzzzk3..."
```

#### 步驟 B：替換 ImageSearch 為 FindText
找到對應的 ImageSearch 程式碼：
```autohotkey
// 原來的：
if (ImageSearch(&fx, &fy, x1, y1, x2, y2, "*" . variation . " " . ImagePath))
```

替換為：
```autohotkey
// 新的：
screenCoords := WindowToScreen(x1, y1)
screenCoords2 := WindowToScreen(x2, y2)
if (FindText(&fx, &fy, screenCoords.x, screenCoords.y, screenCoords2.x, screenCoords2.y, 0, 0, [CharacterName][SkillName]Text))
```

## 座標轉換機制

### 為什麼需要轉換？
- 專案使用 `CoordMode("Pixel", "Window")` - 所有座標相對於遊戲視窗
- FindText 預設使用螢幕絕對座標
- 必須轉換才能正確辨識

### 轉換函數
```autohotkey
// 視窗座標 → 螢幕座標
screenCoords := WindowToScreen(winX, winY)

// 螢幕座標 → 視窗座標  
windowCoords := ScreenToWindow(screenX, screenY)
```

## 範例：緋染F技能

### 原始程式碼
```autohotkey
global FeiRanFImage := GetCharacterAssetPath("緋染", "緋染F.png")

// 在 CheckFeiRanSkills() 函數中：
if (ImageSearch(&fx, &fy, 1162, 764, 1468, 885, "*" . FeiRanVariationStrict . " " . FeiRanFImage))
```

### 修改後程式碼
```autohotkey
global FeiRanFImage := GetCharacterAssetPath("緋染", "緋染F.png")
global FeiRanFText := "|<>*127$33.03rzzzk3zzzzk3zzzzk3zkyDU7zb7z0DzXza0ztzww1zTzbk7zzwzUTzz7y1zzszw7zz7zkLztzz4vzDzwZztzzsTzDzyDztzzWzzDzsrztzyDzyDzbzzlztzzyDyTzzVzjzzwDvzzzVzzzzwDzzzzVzxzzwDzDzzVzkTzwDw3zzlzUTTyDwDszlzrz3yDzzw"

// 在 CheckFeiRanSkills() 函數中：
screenCoords := WindowToScreen(1162, 764)
screenCoords2 := WindowToScreen(1468, 885)
if (FindText(&fx, &fy, screenCoords.x, screenCoords.y, screenCoords2.x, screenCoords2.y, 0, 0, FeiRanFText))
```

## 注意事項

1. **必須使用座標轉換**：直接使用視窗座標會導致搜尋位置錯誤
2. **保留原始圖片變數**：不要刪除原有的 `Image` 變數，保持向後相容
3. **錯誤處理**：保持原有的 try-catch 結構
4. **命名規則**：使用 `[CharacterName][SkillName]Text` 的命名規則

## 測試驗證

修改完成後，建議：
1. 執行 `test_coordinates.ahk` 驗證座標轉換
2. 在遊戲中實際測試辨識功能
3. 檢查日誌輸出確認正常運作

## 已完成案例

- ✅ 緋染F技能：已成功從 ImageSearch 轉換為 FindText
- ✅ 座標轉換機制：已建立並測試通過
- ✅ 文檔化：此指南已建立

---

**記住：本專案所有 FindText 整合都必須遵循此標準流程！**
