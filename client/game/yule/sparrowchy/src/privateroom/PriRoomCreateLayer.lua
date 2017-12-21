--
-- Author: Tang
-- Date: 2017-01-08 16:27:52
--
-- 朝阳麻将私人房创建界面
--local PriRoom = appdf.req("client.src.privatemode.plaza.src.models.PriRoom")
require("client.src.plaza.models.yl")
local CreateLayerModel = appdf.req(PriRoom.MODULE.PLAZAMODULE .."models.CreateLayerModel")

local PriRoomCreateLayer = class("PriRoomCreateLayer", CreateLayerModel)
-- local PriRoomCreateLayer = class("PriRoomCreateLayer", function(scene)
--     local layer = display.newLayer()
--     return layer
-- end)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local Shop = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ShopLayer")

--local RES_PATH = "client/src/privatemode/game/yule/sparrowchy/res/"
--local RES_PATH = "game/yule/sparrowchy/res/"

local BT_CREATE = 1
local BT_HELP = 2
local BT_PAY = 3
local BT_CANCEL = 96

local CBX_MACOUNT_1 = 4
local CBX_MACOUNT_2 = 5
local CBX_MACOUNT_3 = 6
local CBX_MACOUNT_4 = 7
local CBX_MACOUNT_5 = 8
local CBX_MACOUNT_6 = 9

local CBX_INNINGS_1 = 10
local CBX_INNINGS_2 = 11
local CBX_INNINGS_3 = 12
local CBX_INNINGS_4 = 13
local CBX_INNINGS_5 = 14
local CBX_INNINGS_6 = 15

local CBX_USERNUM_2 = 16
local CBX_USERNUM_3 = 17
local CBX_USERNUM_4 = 18

local BT_MYROOM = 19

-- insert in ChaoYang
local CBX_COUNT1 = 20
local CBX_COUNT2 = 21
local CBX_ChangMaoGang = 22
local CBX_FengGang = 23

function PriRoomCreateLayer:onInitData()
    self.cbMaCount = 0
    self.cbInningsCount = 0
    self.cbUserNum = 0

    -- insert setting data in ChaoYang
    self.cbInningsCount_cy=0
    self.cbEnabled_DianPao=true
    self.cbEnabled_FengGang=true
    self.cbEnabled_HuiPai=true
    self.cbEnabled_BaoPai=true
    self.cbEnabled_ZhanLiHu=true
    self.cbEnabled_JiaHu=true
    self.cbEnabled_ChangMaoGang = true
end

function PriRoomCreateLayer:onResetData()
    self.cbMaCount = 0
    self.cbInningsCount = 0
    self.cbUserNum = 0

    -- insert setting data in ChaoYang
    self.cbInningsCount_cy=0
    self.cbEnabled_DianPao=true
    self.cbEnabled_FengGang=true
    self.cbEnabled_HuiPai=true
    self.cbEnabled_BaoPai=true
    self.cbEnabled_ZhanLiHu=true
    self.cbEnabled_JiaHu=true
    self.cbEnabled_ChangMaoGang = true
end

function PriRoomCreateLayer:ctor( scene )
    self:onInitData()
    PriRoomCreateLayer.super.ctor(self, scene)

   
    local rootLayer
    rootLayer, self.m_csbNode = ExternalFun.loadRootCSB("privateRoom/RoomCardLayer_cy.csb", self)

    local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    -- 创建按钮
    self.m_csbNode:getChildByName("bt_createRoom")
        :setTag(BT_CREATE)
        :addTouchEventListener(btncallback)

    --我的房间
    self.m_csbNode:getChildByName("bt_myRoom"):setVisible(false)
    
    -- Exit button
    self.m_csbNode:getChildByName("bt_cancel")
        :setTag(BT_CANCEL)
        :addTouchEventListener(btncallback)
            
    --复选按钮
    local cbtlistener = function (sender,eventType)
        self:onSelectedEvent(sender:getTag(), sender)
    end

    self.m_csbNode:getChildByName("cbx_roundCount1")
        :setTag(CBX_COUNT1)
        :addEventListener(cbtlistener)
    self.m_csbNode:getChildByName("cbx_roundCount2")
        :setTag(CBX_COUNT2)
        :addEventListener(cbtlistener)
    self.m_csbNode:getChildByName("cbx_ChangMaoGang")
        :setTag(CBX_ChangMaoGang)
        :addEventListener(cbtlistener)
    self.m_csbNode:getChildByName("cbx_FengGang")
        :setTag(CBX_FengGang)
        :addEventListener(cbtlistener)
    --房间限制
    local roomConfigList = PriRoom:getInstance().m_tabFeeConfigList
    self.m_tabSelectConfig = PriRoom:getInstance().m_tabFeeConfigList[1]
    -- round setting
    self.m_csbNode:getChildByName("AtlasLabel_1_0"):setVisible(false)
    self.m_csbNode:getChildByName("cbx_roundCount2"):setVisible(false)
    self.m_csbNode:getChildByName("sp_cell_Ju_14"):setVisible(false)
    self.m_csbNode:getChildByName("sp_cell_FangKa_13"):setVisible(false)
    self.m_csbNode:getChildByName("AtlasLabel_2_0"):setVisible(false)

    self.m_csbNode:getChildByName("AtlasLabel_1")
                  :setString(self.m_tabSelectConfig.dwDrawCountLimit)
    self.m_csbNode:getChildByName("AtlasLabel_2")
                  :setString(self.m_tabSelectConfig.lFeeScore)
    if #roomConfigList > 1 then
        self.m_csbNode:getChildByName("AtlasLabel_1_0"):setVisible(true)
        self.m_csbNode:getChildByName("cbx_roundCount2"):setVisible(true)
        self.m_csbNode:getChildByName("sp_cell_Ju_14"):setVisible(true)
        self.m_csbNode:getChildByName("sp_cell_FangKa_13"):setVisible(true)
        self.m_csbNode:getChildByName("AtlasLabel_2_0"):setVisible(true)

        self.m_csbNode:getChildByName("AtlasLabel_1_0")
                  :setString(roomConfigList[2].dwDrawCountLimit)
        self.m_csbNode:getChildByName("AtlasLabel_2_0")
                  :setString(roomConfigList[2].lFeeScore)
    end

    --创建房卡花费花费
    self.m_bLow = false
    local feeType = "房卡"
    local strLockPrompt = "sp_lackRoomCard.png"
    local lMyTreasure = GlobalUserItem.lRoomCard
    if nil ~= self.m_tabSelectConfig then
        local dwCost = self.m_tabSelectConfig.lFeeScore
        if PriRoom:getInstance().m_tabRoomOption.cbCardOrBean == 0 then
            feeType = "游戏豆"
            strLockPrompt = "sp_lackBean.png"
            lMyTreasure = GlobalUserItem.dUserBeans
        end
        if lMyTreasure < dwCost or lMyTreasure == 0 then
            self.m_bLow = true
        end
    end
end

------
-- 继承/覆盖
------
-- 刷新界面
function PriRoomCreateLayer:onRefreshInfo()
    -- 房卡数更新
    --self.textCardNum:setString(GlobalUserItem.lRoomCard .. "")
end

function PriRoomCreateLayer:onLoginPriRoomFinish()
    local meUser = PriRoom:getInstance():getMeUserItem()
    if nil == meUser then
        return false
    end

    -- 发送创建桌子
    if ((meUser.cbUserStatus == yl.US_FREE or meUser.cbUserStatus == yl.US_NULL or meUser.cbUserStatus == yl.US_PLAYING)) then
        if PriRoom:getInstance().m_nLoginAction == PriRoom.L_ACTION.ACT_CREATEROOM then
            -- 创建登陆
            local buffer = CCmd_Data:create(188)
            buffer:setcmdinfo(self._cmd_pri_game.MDM_GR_PERSONAL_TABLE,self._cmd_pri_game.SUB_GR_CREATE_TABLE)
            buffer:pushscore(1)
            buffer:pushdword(self.m_tabSelectConfig.dwDrawCountLimit)  
            buffer:pushdword(self.m_tabSelectConfig.dwDrawTimeLimit)
            buffer:pushword(0)
            buffer:pushdword(0)
            buffer:pushstring("", yl.LEN_PASSWORD)
            --单个游戏规则(额外规则)
            buffer:pushbyte(1)
            buffer:pushbyte(self.cbUserNum)         --人数必须在第2个位置
            buffer:pushbyte(self.cbMaCount)
            -- insert in ChaoYang
            buffer:pushbyte(self.cbInningsCount_cy)  -- count of round
            buffer:pushbool(self.cbEnabled_DianPao)
            buffer:pushbool(self.cbEnabled_FengGang)
            buffer:pushbool(self.cbEnabled_HuiPai)
            buffer:pushbool(self.cbEnabled_BaoPai)
            buffer:pushbool(self.cbEnabled_ZhanLiHu)
            buffer:pushbool(self.cbEnabled_JiaHu)
            buffer:pushbool(self.cbEnabled_ChangMaoGang)
            print(self.cbUserNum,self.m_tabSelectConfig.dwDrawCountLimit,self.cbEnabled_DianPao,self.cbEnabled_FengGang,self.cbEnabled_HuiPai,self.cbEnabled_BaoPai,self.cbEnabled_ZhanLiHu,self.cbEnabled_JiaHu,self.cbEnabled_ChangMaoGang)
            for i = 1, 100 - 11 do
                buffer:pushbyte(0)
            end
            PriRoom:getInstance():getNetFrame():sendGameServerMsg(buffer)
            return true
        end        
    end
    return false
end

function PriRoomCreateLayer:getInviteShareMsg( roomDetailInfo )
    local shareTxt = "朝阳麻将约战 房间ID:" .. roomDetailInfo.szRoomID .. " 局数:" .. roomDetailInfo.dwPlayTurnCount
    local friendC = "朝阳麻将房间ID:" .. roomDetailInfo.szRoomID .. " 局数:" .. roomDetailInfo.dwPlayTurnCount
    return {title = "朝阳麻将约战", content = shareTxt .. " 朝阳麻将游戏精彩刺激, 一起来玩吧! ", friendContent = friendC}
end

------
-- 继承/覆盖
------

function PriRoomCreateLayer:onButtonClickedEvent(tag, sender)
    if BT_HELP == tag then
        print("帮助")
        --self._scene:popHelpLayer(yl.HTTP_URL .. "/Mobile/Introduce.aspx?kindid=389&typeid=1")
        self._scene:popHelpLayer2(389, 1)
    elseif BT_CREATE == tag then
        self.cbMaCount=2
        self.cbInningsCount=4
        self.cbUserNum=4
        print("创建房间_tom")

        if self.m_bLow then
            local feeType = "房卡"
            if PriRoom:getInstance().m_tabRoomOption.cbCardOrBean == 0 then
                feeType = "游戏豆"
            end
            local QueryDialog = appdf.req("app.views.layer.other.QueryDialog")
            local query = QueryDialog:create("您的" .. feeType .. "数量不足，是否前往商城充值！", function(ok)
                if ok == true then
                    if feeType == "游戏豆" then
                        self._scene:onChangeShowMode(yl.SCENE_SHOP, Shop.CBT_BEAN)
                    else
                        self._scene:onChangeShowMode(yl.SCENE_SHOP, Shop.CBT_PROPERTY)
                    end
                end
                query = nil
            end):setCanTouchOutside(false)
                :addTo(self._scene)
            return
        end

        -- insert in ChoaYang
        if self.m_csbNode:getChildByTag(CBX_COUNT1):isSelected() then
            self.cbInningsCount_cy = 16
        end
        if self.m_csbNode:getChildByTag(CBX_COUNT2):isSelected() then
            self.cbInningsCount_cy = 32
        end
        if self.m_csbNode:getChildByName("cbx_DianPao"):isSelected() == false then
            self.cbEnabled_DianPao = false
        end
        if self.m_csbNode:getChildByName("cbx_FengGang"):isSelected() == false then
            self.cbEnabled_FengGang = false
        end
        if self.m_csbNode:getChildByName("cbx_HuiPai"):isSelected() == false then
            self.cbEnabled_HuiPai = false
        end
        if self.m_csbNode:getChildByName("cbx_BaoPai"):isSelected() == false then
            self.cbEnabled_BaoPai = false
        end
        if self.m_csbNode:getChildByName("cbx_ZhanLiHu"):isSelected() == false then
            self.cbEnabled_ZhanLiHu = false
        end
        if self.m_csbNode:getChildByName("cbx_JiaHu"):isSelected() == false then
            self.cbEnabled_JiaHu = false
        end
        if self.m_csbNode:getChildByName("cbx_ChangMaoGang"):isSelected() == false then
            self.cbEnabled_ChangMaoGang = false
        end

        if nil == self.m_tabSelectConfig or
            table.nums(self.m_tabSelectConfig) == 0 or
            self.cbMaCount == 0 or
            self.cbUserNum == 0 then
            showToast(self, "未选择玩法配置!", 2)
            return
        end

        if self.m_tabSelectConfig.dwDrawCountLimit ~=16 then
            if self.m_tabSelectConfig.dwDrawCountLimit ~=32 then
                showToast(self, "非法玩法配置! 16圈 或者 32圈！", 2)
                return
            end
        end

        PriRoom:getInstance():showPopWait()
        PriRoom:getInstance():getNetFrame():onCreateRoom()
    elseif BT_PAY == tag then
        print("充值")
        local feeType = "房卡"
        if PriRoom:getInstance().m_tabRoomOption.cbCardOrBean == 0 then
            feeType = "游戏豆"
        end
        if feeType == "游戏豆" then
            self._scene:onChangeShowMode(yl.SCENE_SHOP, Shop.CBT_BEAN)
        else
            self._scene:onChangeShowMode(yl.SCENE_SHOP, Shop.CBT_PROPERTY)
        end
    elseif BT_MYROOM == tag then
        print("我的房间")
        self._scene:onChangeShowMode(PriRoom.LAYTAG.LAYER_MYROOMRECORD)
    elseif BT_CANCEL == tag then
        self._scene:onKeyBack()
    end
end

function PriRoomCreateLayer:onSelectedEvent(tag, sender)
    print("进", tag)
    local checkBox = self.m_csbNode:getChildByTag(tag)
    
    if CBX_MACOUNT_1 <= tag and tag <= CBX_MACOUNT_6 then
        for i = CBX_MACOUNT_1, CBX_MACOUNT_6 do
            local checkBox = self.m_csbNode:getChildByTag(i)
            if i == tag then
                self.cbMaCount = checkBox:isSelected() and i - CBX_MACOUNT_1 + 1 or 0
            else
                checkBox:setSelected(false)
            end
        end
    elseif CBX_USERNUM_2 <= tag and tag <= CBX_USERNUM_4 then
        for i = CBX_USERNUM_2, CBX_USERNUM_4 do
            local checkBox = self.m_csbNode:getChildByTag(i)
            if i == tag then
                self.cbUserNum = checkBox:isSelected() and i - CBX_USERNUM_2 + 2 or 0
            else
                checkBox:setSelected(false)
            end
        end
    -- insert in ChaoYang
    elseif CBX_COUNT1 == tag then
        self.m_csbNode:getChildByTag(CBX_COUNT2)
            :setSelected(false)
        self.m_tabSelectConfig = PriRoom:getInstance().m_tabFeeConfigList[1]
    elseif CBX_COUNT2 == tag then
        self.m_csbNode:getChildByTag(CBX_COUNT1)
            :setSelected(false)
        self.m_tabSelectConfig = PriRoom:getInstance().m_tabFeeConfigList[2]
    elseif CBX_ChangMaoGang == tag then
        if checkBox:isSelected() then 
            self.m_csbNode:getChildByName("cbx_FengGang")
                :setSelected(true)
        end
    elseif CBX_FengGang == tag then
        if checkBox:isSelected() == false then
            self.m_csbNode:getChildByName("cbx_ChangMaoGang"):setSelected(false)
        end
    else
        assert(false)
    end
    
end

return PriRoomCreateLayer