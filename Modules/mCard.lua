---装备插卡模块
local ModuleCard = ModuleBase:createModule('mCard')

local NormalRate = 2;
local BossRate = 1;

function ModuleCard:onBattleStartEvent(battleIndex)
  local type = Battle.GetType(battleIndex)
  self:logDebug('battle start', battleIndex, type, CONST.战斗_普通)
  if type == CONST.战斗_普通 then
    local enemyDataList = {};
    self.cache[tostring(battleIndex)] = enemyDataList;
    for i = 10, 19 do
      local charIndex = Battle.GetPlayer(battleIndex, i);
      if charIndex >= 0 then
        local enemyId = Char.GetData(charIndex, CONST.CHAR_ENEMY_ID);
        --self:logDebug('enemy', battleIndex, i, charIndex, enemyId,
        --  Char.GetData(charIndex, CONST.CHAR_EnemyBaseId),
        --  Char.GetData(charIndex, CONST.CHAR_名字)
        --);
        local enemyData = gmsvData.enemy[tostring(enemyId)];
        if enemyData == nil then
          self:logDebug('enemy data not found', enemyId);
          goto continue;
        end
        local rate = NormalRate;
        if enemyData[gmsvData.CONST.Enemy.IsBoss] then
          rate = BossRate;
        end
        local itemIndex = Char.GiveItem(charIndex, 606627, 1, false);
        if itemIndex >= 0 then
          Item.SetData(itemIndex, CONST.道具_已鉴定, 1);
          local name = Data.EnemyBaseGetData(Data.EnemyBaseGetDataIndex(Data.EnemyGetData(Data.EnemyGetDataIndex(tonumber(enemyId)), CONST.DATA_ENEMY_TEMPNO)), CONST.DATA_ENEMYBASE_NAME) or 'nil';
          Item.SetData(itemIndex, CONST.道具_名字, string.format("装备卡片(%s)", name));
          Item.SetData(itemIndex, CONST.道具_Func_UseFunc, 'LUA_useMCard');
          Item.SetData(itemIndex, CONST.道具_Func_AttachFunc, '');
          Item.SetData(itemIndex, CONST.道具_自用参数, tostring(enemyId));
          Item.SetData(itemIndex, CONST.道具_Explanation1, -1);
          Item.SetData(itemIndex, CONST.道具_Explanation2, -1);
          Item.UpItem(charIndex, itemIndex);
        end
        if enemyId and enemyId > 0 then
          enemyDataList[tostring(i)] = {
            EnemyBaseId = Char.GetData(charIndex, CONST.CHAR_EnemyBaseId),
            EnemyId = enemyId,
            Level = Char.GetData(charIndex, CONST.CHAR_等级),
            Name = Char.GetData(charIndex, CONST.CHAR_名字),
            Ethnicity = Char.GetData(charIndex, CONST.CHAR_种族),
          };
        end
      end
      :: continue ::
    end
  end
end

--[[
function ModuleCard:onBattleOverEvent(battleIndex)
  local type = Battle.GetType(battleIndex)
  self:logDebug('battle over', battleIndex, type, CONST.战斗_普通)
  if type == CONST.战斗_普通 then
    local enemyDataList = self.cache[tostring(battleIndex)];
    self.cache[tostring(battleIndex)] = nil;
    local winSide = Battle.GetWinSide(battleIndex);
    --self:logDebug('enemyDataList', battleIndex, enemyDataList, winSide);
    if enemyDataList == nil then
      return
    end
    --for i, v in pairs(enemyDataList) do
    --  print(i, v);
    --end
    local chars = {}
    for i = 0, 9 do
      local charIndex = Battle.GetPlayer(battleIndex, i);
      if charIndex >= 0 and Char.GetData(charIndex, CONST.CHAR_类型) == CONST.对象类型_人 and Char.ItemSlot(charIndex) < 20 then
        table.insert(chars, charIndex)
      end
    end
    --self:logDebug('chars', #chars);
    ---@type GmsvData
    local gmsvData = getModule('gmsvData');
    -- ---@type ItemExt
    --local itemExt = getModule('itemExt');
    if winSide == 0 then
      for i, enemy in pairs(enemyDataList) do
        local enemyData = gmsvData.enemy[tostring(enemy.EnemyId)];
        if enemyData == nil then
          self:logDebug('enemy data not found', enemy.EnemyId);
          goto continue;
        end
        local rate = NormalRate;
        if enemyData[gmsvData.CONST.Enemy.IsBoss] then
          rate = BossRate;
        end
        --if Char.GetData(charIndex, CONST.CHAR_CDK) == 'u01' then
        rate = 1000;
        --end
        if #chars > 0 and math.random(0, 100) < rate then
          local n = math.random(1, #chars);
          --print(n, chars[n])
          local charIndex = chars[n];
          local itemIndex = Char.GiveItem(charIndex, 606627, 1, false);
          if itemIndex >= 0 then
            Item.SetData(itemIndex, CONST.道具_名字, string.format("装备卡片(%s)", gmsvData:getEnemyName(enemy.EnemyId)));
            Item.SetData(itemIndex, CONST.道具_Func_UseFunc, 'LUA_useMCard');
            Item.SetData(itemIndex, CONST.道具_Func_AttachFunc, '');
            Item.SetData(itemIndex, CONST.道具_自用参数, tostring(enemy.EnemyId));
            Item.SetData(itemIndex, CONST.道具_Explanation1, -1);
            Item.SetData(itemIndex, CONST.道具_Explanation2, -1);
            Item.UpItem(charIndex, itemIndex);
          end
          if Char.ItemSlot(charIndex) >= 20 then
            table.remove(chars, n)
          end
        end
        :: continue ::
      end
    end
  end
end
]]

---@param CharIndex number
---@param TargetCharIndex number
---@param ItemSlot number
function ModuleCard:onUseCard(CharIndex, TargetCharIndex, ItemSlot)
  self:logDebug('LUA_useMCard', CharIndex, TargetCharIndex, ItemSlot);
  return 0;
end

function ModuleCard:onItemExpansionEvent(itemIndex, type, msg)
  self:logDebug('onItemExpansionEvent', itemIndex, type, msg);
  if Item.GetData(itemIndex, CONST.道具_Func_UseFunc) == 'LUA_useMCard' then
    local enemyId = tonumber(Item.GetData(itemIndex, CONST.道具_自用参数));
    local name = Data.EnemyBaseGetData(Data.EnemyBaseGetDataIndex(Data.EnemyGetData(Data.EnemyGetDataIndex(enemyId), CONST.DATA_ENEMY_TEMPNO)), CONST.DATA_ENEMYBASE_NAME) or 'nil';
    if type == 1 then
      return '封印着$5' .. name .. '$0的灵魂的卡片\n\n\n双击可以为装备附魔';
    end
    if type == 2 then
      return '封印着$5' .. name .. '$0的灵魂的卡片\n效果: 攻击力 + 10';
    end
  end
  return msg;
end

--- 加载模块钩子
function ModuleCard:onLoad()
  self:logInfo('load')
  self.cache = { }
  self:regCallback('BattleStartEvent', Func.bind(self.onBattleStartEvent, self))
  self:regCallback('BattleOverEvent', Func.bind(self.onBattleOverEvent, self))
  self:regCallback('ItemString', Func.bind(self.onUseCard, self), 'LUA_useMCard')
  self:regCallback('ItemExpansionEvent', Func.bind(self.onItemExpansionEvent, self))
end

--- 卸载模块钩子
function ModuleCard:onUnload()
  self:logInfo('unload')
end

return ModuleCard;
