---获取角色的指针
function Char.GetCharPointer(charIndex)
  if Char.GetData(charIndex, CONST.CHAR_类型) == 1 then
    return Addresses.CharaTablePTR + charIndex * 0x21EC;
  end
  return 0;
end

function Char.GetWeapon(charIndex)
  local ItemIndex = Char.GetItemIndex(charIndex, CONST.EQUIP_左手);
  if ItemIndex >= 0 and Item.isWeapon(Item.GetData(ItemIndex, CONST.道具_类型)) then
    return ItemIndex, CONST.EQUIP_左手;
  end
  ItemIndex = Char.GetItemIndex(charIndex, CONST.EQUIP_右手)
  if ItemIndex >= 0 and Item.isWeapon(Item.GetData(ItemIndex, CONST.道具_类型)) then
    return ItemIndex, CONST.EQUIP_右手;
  end
  return -1, -1;
end

local giveItem = Char.GiveItem;
Char.GiveItem = function(CharIndex, ItemID, Amount, ShowMsg)
  ShowMsg = type(ShowMsg) ~= 'boolean' and true or ShowMsg;
  if not ShowMsg then
    ffi.patch(0x0058223B, { 0x90, 0x90, 0x90, 0x90, 0x90, });
  end
  local ret = giveItem(CharIndex, ItemID, Amount)
  if not ShowMsg then
    ffi.patch(0x0058223B, { 0xE8, 0x90, 0x46, 0xEB, 0xFF, });
  end
  return ret;
end

local delItem = Char.DelItem;
Char.DelItem = function(CharIndex, ItemID, Amount, ShowMsg)
  ShowMsg = type(ShowMsg) ~= 'boolean' and true or ShowMsg;
  if not ShowMsg then
    ffi.patch(0x0058281B, { 0x90, 0x90, 0x90, 0x90, 0x90, });
  end
  local ret = delItem(CharIndex, ItemID, Amount)
  if not ShowMsg then
    ffi.patch(0x0058281B, { 0xE8, 0xB0, 0x40, 0xEB, 0xFF, });
  end
  return ret;
end

local cDeleteCharItem = ffi.cast('int (__cdecl*)(const char * str1, int lineNo, uint32_t charAddr, uint32_t slot)', 0x00428390)
local cRemoveItem = ffi.cast('void (__cdecl *)(int itemIndex, const char * str, int lineNo)', 0x004C8370)
Char.DelItemBySlot = function(CharIndex, Slot)
  local charPtr = Char.GetCharPointer(CharIndex);
  if charPtr < Addresses.CharaTablePTR then
    return -1;
  end
  local itemIndex = Char.GetItemIndex(CharIndex, Slot);
  if itemIndex < 0 then
    return -2;
  end
  cDeleteCharItem('LUA cDeleteCharItem', 0, charPtr, Slot);
  cRemoveItem(itemIndex, 'LUA cDeleteCharItem', 0);
  Item.UpItem(CharIndex, Slot)
  return 0;
end

function Char.UnsetWalkPostEvent(charIndex)
  Char.SetData(charIndex, 1588, 0)
  Char.SetData(charIndex, 1663, 0)
  Char.SetData(charIndex, 1985, 0)
end

function Char.UnsetWalkPreEvent(charIndex)
  Char.SetData(charIndex, 1587, 0)
  Char.SetData(charIndex, 1631, 0)
  Char.SetData(charIndex, 1984, 0)
end

function Char.UnsetPostOverEvent(charIndex)
  Char.SetData(charIndex, 1759, 0)
  Char.SetData(charIndex, 0x1F10 / 4, 0)
  Char.SetData(charIndex, (0x18C8 + 0x30) / 4, 0)
end

function Char.UnsetLoopEvent(charIndex)
  Char.SetData(charIndex, 0x1C7C / 4, 0)
  Char.SetData(charIndex, 0x1F18 / 4, 0)
  Char.SetData(charIndex, 0x1F2C / 4, 0)
  Char.SetData(charIndex, 0x1F30 / 4, 0)
  Char.SetData(charIndex, (0x18C8 + 0x2C) / 4, 0)
end

function Char.UnsetTalkedEvent(charIndex)
  Char.SetData(charIndex, 0x1D7C / 4, 0)
  Char.SetData(charIndex, 0x1F20 / 4, 0)
  Char.SetData(charIndex, (0x18C8 + 0x18) / 4, 0)
end

function Char.UnsetWindowTalkedEvent(charIndex)
  Char.SetData(charIndex, 0x1E7C / 4, 0)
  Char.SetData(charIndex, 0x1F28 / 4, 0)
  Char.SetData(charIndex, (0x18C8 + 0x28) / 4, 0)
end

function Char.UnsetItemPutEvent(charIndex)
  Char.SetData(charIndex, 0x1CFC / 4, 0)
  Char.SetData(charIndex, 0x1F1C / 4, 0)
  Char.SetData(charIndex, (0x18C8 + 0x20) / 4, 0)
end

function Char.UnsetWatchEvent(charIndex)
  Char.SetData(charIndex, 0x1A7C / 4, 0)
  Char.SetData(charIndex, 0x1F08 / 4, 0)
  Char.SetData(charIndex, (0x18C8 + 0xC) / 4, 0)
end
