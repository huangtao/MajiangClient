local cmd = appdf.req(appdf.GAME_SRC.."yule.sparrowchy.src.models.CMD_Game")

local GameViewLayer = class("GameViewLayer",function(scene)
	local gameViewLayer =  cc.CSLoader:createNode(cmd.RES_PATH.."game/GameScene.csb")
    return gameViewLayer
end)

require("client/src/plaza/models/yl")
local PopupInfoHead = appdf.req("client.src.external.PopupInfoHead")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.sparrowchy.src.models.GameLogic")
local CardLayer = appdf.req(appdf.GAME_SRC.."yule.sparrowchy.src.views.layer.CardLayer")
local ResultLayer = appdf.req(appdf.GAME_SRC.."yule.sparrowchy.src.views.layer.ResultLayer")
local SetLayer = appdf.req(appdf.GAME_SRC.."yule.sparrowchy.src.views.layer.SetLayer")
local GameChatLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.game.GameChatLayer")
local AnimationMgr = appdf.req(appdf.EXTERNAL_SRC .. "AnimationMgr")

local anchorPointHead = {cc.p(0, 1), cc.p(0, 0.5), cc.p(0, 0), cc.p(1, 0.5)}
local posHead = {cc.p(400, 260), cc.p(165, 300), cc.p(166, 230), cc.p(750, 273)}
local posReady = {cc.p(150, 0), cc.p(135, 0), cc.p(516, -140), cc.p(-134, 0)}
local posPlate = {cc.p(667, 589), cc.p(237, 464), cc.p(667, 174), cc.p(1093, 455)}
local posChat = {cc.p(873, 660), cc.p(229, 558), cc.p(270, 285), cc.p(1095, 528)}

GameViewLayer.SP_TABLE_BT_BG		= 1					--桌子按钮背景
GameViewLayer.BT_CHAT 				= 41				--聊天按钮
GameViewLayer.BT_SET 				= 42				--设置
GameViewLayer.BT_EXIT	 			= 43				--退出按钮
GameViewLayer.BT_TRUSTEE 			= 44				--托管按钮
GameViewLayer.BT_HOWPLAY 			= 45				--玩法按钮

GameViewLayer.BT_SWITCH 			= 2 				--按钮开关按钮
GameViewLayer.BT_START 				= 3 				--开始按钮

GameViewLayer.BT_VOICE 				= 5					--语音按钮（语音关闭）
-- GameViewLayer.BT_VOICEOPEN 			= 55				--语音按钮（语音开启）

GameViewLayer.SP_GAMEBTN 			= 6					--游戏操作按钮
GameViewLayer.BT_BUMP 				= 62				--游戏操作按钮碰
GameViewLayer.BT_BRIGDE 			= 63				--游戏操作按钮杠
GameViewLayer.BT_LISTEN 			= 64				--游戏操作按钮听
GameViewLayer.BT_WIN 				= 65				--游戏操作按钮胡
GameViewLayer.BT_PASS 				= 66				--游戏操作按钮过
GameViewLayer.BT_EAT 				= 67				--游戏操作按钮过

GameViewLayer.Chi_TAG              = 70  

GameViewLayer.SP_ROOMINFO 			= 7					--房间信息
GameViewLayer.TEXT_ROOMNUM 			= 1					--房间信息房号
GameViewLayer.TEXT_ROOMNAME 		= 2					--房间信息房名
GameViewLayer.TEXT_INDEX 			= 3					--房间信息局数
GameViewLayer.TEXT_INNINGS 			= 4					--房间信息剩多少局

--GameViewLayer.SP_ANNOUNCEMENT 		= 8					--公告

GameViewLayer.SP_CLOCK 				= 9					--计时器
GameViewLayer.ASLAB_TIME 			= 1					--计时器时间

GameViewLayer.SP_LISTEN 			= 10				--听牌提示

GameViewLayer.NODEPLAYER_1 			= 11				--玩家节点1
GameViewLayer.NODEPLAYER_2 			= 12				--玩家节点2
GameViewLayer.NODEPLAYER_3 			= 13				--玩家节点3
GameViewLayer.NODEPLAYER_4 			= 14				--玩家节点4
GameViewLayer.SP_HEAD 				= 1					--玩家头像
GameViewLayer.SP_HEADCOVER 			= 2					--玩家头像覆盖层
GameViewLayer.TEXT_NICKNAME 		= 3					--玩家昵称
GameViewLayer.ASLAB_SCORE 			= 4					--玩家金币
GameViewLayer.SP_READY 				= 5					--玩家准备标志
--GameViewLayer.SP_TRUSTEE 			= 6					--玩家托管标志
GameViewLayer.SP_BANKER 			= 7					--庄家
GameViewLayer.SP_ROOMHOST 			= 8 				--房主

-- GameViewLayer.BT_EXIT	 			= 17				--退出按钮
-- GameViewLayer.BT_TRUSTEE 			= 18				--托管按钮

GameViewLayer.SP_PLATE 				= 19				--牌盘
GameViewLayer.SP_PLATECARD		 	= 1					--排盘中的牌

GameViewLayer.TEXT_REMAINNUM 		= 20				--牌堆剩多少张

GameViewLayer.SP_SICE1 				= 27				--筛子1
GameViewLayer.SP_SICE2 				= 28				--筛子2
GameViewLayer.SP_OPERATFLAG			= 29				--操作标志

GameViewLayer.SP_TRUSTEEBG 			= 1					--托管底图
GameViewLayer.BT_TRUSTEECANCEL 		= 30 				--取消托管

function GameViewLayer:onEnterTransitionFinish()
    
end

function GameViewLayer:exitTransitionStart()

end

function GameViewLayer:onInitData()
    print("---------------------- GameViewLayer:onInitData() ----------------------------")
	self.cbActionCard = 0
	self.cbOutCardTemp = 0
	self.chatDetails = {}
	self.cbAppearCardIndex = {}
	self.m_bNormalState = {}
	--房卡需要
	self.m_sparrowUserItem = {}

    self.m_nodeHuanBaoAnim = nil
    self.m_actHuanBaoAnim = nil
    self.m_nodeJinBaoAnim = nil
    self.m_actJinBaoAnim = nil
    
    self.listen_state = false
    self.listen_count = 0
    print(self.listen_state)
    print(self.listen_count)
end

function GameViewLayer:playAnimHuanBao()
    if self.m_nodeHuanBaoAnim == nil then
        self.m_nodeHuanBaoAnim = ExternalFun.loadCSB("animHuanBao.csb", self)
		self.m_nodeHuanBaoAnim:setPosition(display.center)
		self.m_actHuanBaoAnim = ExternalFun.loadTimeLine("animHuanBao.csb")
		ExternalFun.SAFE_RETAIN(self.m_actHuanBaoAnim)
    end

    local function onFrameEvent(frame)
        print("animation play")
    end
    self.m_actHuanBaoAnim:setFrameEventCallFunc(onFrameEvent)
    --self.m_nodeHuanBaoAnim:setVisible(true)
	--self.m_nodeHuanBaoAnim:setLocalZOrder(1)
	self.m_nodeHuanBaoAnim:stopAllActions()
	self.m_actHuanBaoAnim:gotoFrameAndPlay(0,false)
	self.m_nodeHuanBaoAnim:runAction(self.m_actHuanBaoAnim)
end

function GameViewLayer:playAnimJinBao()
    if self.m_nodeJinBaoAnim == nil then
        self.m_nodeJinBaoAnim = ExternalFun.loadCSB("animJinBao.csb", self)
		self.m_nodeJinBaoAnim:setPosition(display.center)
		self.m_actJinBaoAnim = ExternalFun.loadTimeLine("animJinBao.csb")
		ExternalFun.SAFE_RETAIN(self.m_actJinBaoAnim)
    end

    local function onFrameEvent(frame)
        print("animation play")
    end
    self.m_actJinBaoAnim:setFrameEventCallFunc(onFrameEvent)
    --self.m_nodeHuanBaoAnim:setVisible(true)
	--self.m_nodeJinBaoAnim:setLocalZOrder(1)
	self.m_nodeJinBaoAnim:stopAllActions()
	self.m_actJinBaoAnim:gotoFrameAndPlay(0,false)
	self.m_nodeJinBaoAnim:runAction(self.m_actJinBaoAnim)
end

function GameViewLayer:onResetData()
	self._cardLayer:onResetData()

	self.spListenBg:removeAllChildren()
	self.spListenBg:setVisible(false)
	self.cbOutCardTemp = 0
	self.cbAppearCardIndex = {}
	local spFlag = self:getChildByTag(GameViewLayer.SP_OPERATFLAG)
	if spFlag then
		spFlag:removeFromParent()
	end
	self.spCardPlate:setVisible(false)
	self.spTrusteeCover:setVisible(false)
	for i = 1, cmd.GAME_PLAYER do
		--self.nodePlayer[i]:getChildByTag(6):setVisible(false)
		self.nodePlayer[i]:getChildByTag(GameViewLayer.SP_BANKER):setVisible(false)
	end
	self:setRemainCardNum(cmd.MAX_REPERTORY)
	self.spGameBtn:getChildByTag(GameViewLayer.BT_PASS):setEnabled(true):setColor(cc.c3b(255, 255, 255))
end

function GameViewLayer:onExit()
	print("GameViewLayer onExit")
	self._scene:KillGameClock()
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("gameScene.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("gameScene.png")
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    AnimationMgr.removeCachedAnimation(cmd.VOICE_ANIMATION_KEY)

    ExternalFun.SAFE_RELEASE(self.m_actHuanBaoAnim)
	self.m_actHuanBaoAnim = nil
    ExternalFun.SAFE_RELEASE(self.m_actJinBaoAnim)
	self.m_actJinBaoAnim = nil
end

local this
function GameViewLayer:ctor(scene)
	this = self
	self._scene = scene
	self:onInitData()
	self:preloadUI()
	self:initButtons()
	self._cardLayer = CardLayer:create(self):addTo(self)							--牌图层
	self._resultLayer = ResultLayer:create(self):addTo(self):setVisible(false)	--结算框
    self._chatLayer = GameChatLayer:create(self._scene._gameFrame):addTo(self, 4)	--聊天框
    self._setLayer = SetLayer:create(self):addTo(self, 4)

    self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。			
			self:onEnterTransitionFinish()			
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			self:onExitTransitionStart()
		elseif eventType == "exit" then
			self:onExit()
		end
	end)

	--聊天泡泡
	self.chatBubble = {}
	for i = 1 , cmd.GAME_PLAYER do
		local strFile = ""
		if i == 1 or i == 4 then
			strFile = "#sp_bubble_2.png"
		else
			strFile = "#sp_bubble_1.png"
		end
		self.chatBubble[i] = display.newSprite(strFile, {scale9 = true ,capInsets = cc.rect(0, 0, 204, 68)})
			:setAnchorPoint(cc.p(0.5, 0.5))
			:move(posChat[i])
			:setVisible(false)
			:addTo(self, 3)
	end

	--节点事件
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExit()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	self.nodePlayer = {}
	for i = 1, cmd.GAME_PLAYER do
		self.nodePlayer[i] = self:getChildByTag(GameViewLayer.NODEPLAYER_1 + i - 1)
		self.nodePlayer[i]:setLocalZOrder(1)
		self.nodePlayer[i]:setVisible(false)
		self.nodePlayer[i]:getChildByTag(GameViewLayer.SP_HEADCOVER):setLocalZOrder(1)
		self.nodePlayer[i]:getChildByTag(GameViewLayer.TEXT_NICKNAME):setLocalZOrder(1)
		self.nodePlayer[i]:getChildByTag(GameViewLayer.SP_READY):move(posReady[i]):setLocalZOrder(1)

		--local sp_trustee = self.nodePlayer[i]:getChildByTag(GameViewLayer.SP_TRUSTEE)
		--	:setVisible(false)
		local sp_banker = self.nodePlayer[i]:getChildByTag(GameViewLayer.SP_BANKER)
			:setLocalZOrder(1)
			:setVisible(false)
		local sp_roomHost = self.nodePlayer[i]:getChildByTag(GameViewLayer.SP_ROOMHOST)
			:setVisible(false)
        --[[
		if i == 2 or i == cmd.MY_VIEWID then
			sp_trustee:move(65, -41)
			sp_banker:move(44, 55)
			sp_roomHost:move(-79, -24)
		end
        ]]
	end

	self.spListenBg = self:getChildByTag(GameViewLayer.SP_LISTEN)
		:setLocalZOrder(3)
		:setVisible(false)
		:setScale(0.7)
	--庄家
	--self:getChildByTag(GameViewLayer.SP_ANNOUNCEMENT):setLocalZOrder(2):setVisible(false)

    
	--托管覆盖层
	self.spTrusteeCover = cc.Layer:create():setVisible(false):addTo(self, 4)
    --[[
	--阴影层
	display.newSprite(cmd.RES_PATH.."game/sp_trusteeCover.png")
		:move(667, 112)
		:setScaleY(1.6)
		:setTag(GameViewLayer.SP_TRUSTEEBG)
		:addTo(self.spTrusteeCover)
	--取消托管按钮
	self.btTrusteeCancel = ccui.Button:create("bt_trusteeCancel_1.png","bt_trusteeCancel_2.png","bt_trusteeCancel_1.png",ccui.TextureResType.plistType)
		:move(667, 108)
		:setTag(GameViewLayer.BT_TRUSTEECANCEL)
		:addTo(self.spTrusteeCover, 1)
	self.btTrusteeCancel:addTouchEventListener(function(ref, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(ref:getTag(), ref)
		end
	end)
	display.newSprite(cmd.RES_PATH.."game/sp_trusteeMan.png")
		:move(1067, 108)
		:addTo(self.spTrusteeCover)
	self.spTrusteeCover:setTouchEnabled(true)
	self.spTrusteeCover:registerScriptTouchHandler(function(eventType, x, y)
		return self:onTrusteeTouchCallback(eventType, x, y)
	end)
    ]]
	--牌盘
	self.spCardPlate = self:getChildByTag(GameViewLayer.SP_PLATE):setLocalZOrder(3):setVisible(false)
	display.newSprite("game/font_middle/card_down.png")
		:move(53, 67)
		--:setTag(GameViewLayer.SP_PLATECARD)
		--:setTextureRect(cc.rect(0, 0, 69, 107))
		:addTo(self.spCardPlate)
	display.newSprite("game/font_middle/font_3_5.png")
		:move(53, 75)
		:setTag(GameViewLayer.SP_PLATECARD)
		:addTo(self.spCardPlate)

	self.spClock = self:getChildByTag(GameViewLayer.SP_CLOCK)
	self.asLabTime = self.spClock:getChildByTag(GameViewLayer.ASLAB_TIME):setString("0")

    self.textNum = self:getChildByTag(GameViewLayer.TEXT_REMAINNUM)
    self.remainCard = self:getChildByName("card_back_up")

    self.card_HuiPai=self:getChildByName("card_HuiPai")
    self.card_BaoPai=self:getChildByName("card_BaoPai")
    -- hide components 
    self:setShowHide(false)
    self:controlHuiPai(false,0)
    self:controlBaoPai(false)
end

-- show and hide components (new inserted)
function GameViewLayer:setShowHide(flag)
    self.spClock:setVisible(flag)
    self.btSet:setVisible(flag)
    self.btChat:setVisible(flag)
    self.btVoice:setVisible(flag)
    self.textNum:setVisible(flag)
    self.remainCard:setVisible(flag)
end

function GameViewLayer:controlHuiPai(flag, data)
    self.card_HuiPai:setVisible(flag)
    self:getChildByName("sp_HuiPai")
        :setVisible(flag)
    if data>0 then
        local nValue = math.mod(data, 16)
	    local nColor = math.floor(data/16)
        s_width=60
        s_height=80
        self.card_HuiPai:removeAllChildren()
        display.newSprite("game/font_small/font_"..nColor.."_"..nValue..".png")
				    :move(s_width/2, s_height/2 + 8)
				    :addTo(self.card_HuiPai)
    end
end

function GameViewLayer:controlBaoPai(flag)
    self.card_BaoPai:setVisible(flag)
    self:getChildByName("sp_BaoPai")
        :setVisible(flag)
end
-- End ---

function GameViewLayer:preloadUI()
    print("欢迎来到我的酒馆！")
    --导入动画
    local animationCache = cc.AnimationCache:getInstance()
    for i = 1, 12 do
    	local strColor = ""
    	local index = 0
    	if i <= 6 then
    		strColor = "white"
    		index = i
    	else
    		strColor = "red"
    		index = i - 6
    	end
		local animation = cc.Animation:create()
		animation:setDelayPerUnit(0.1)
		animation:setLoops(1)
		for j = 1, 9 do
			local strFile = cmd.RES_PATH.."Animate_sice_"..strColor..string.format("/sice_%d.png", index)
			local spFrame = cc.SpriteFrame:create(strFile, cc.rect(133*(j - 1), 0, 133, 207))
			animation:addSpriteFrame(spFrame)
		end

		local strName = "sice_"..strColor..string.format("_%d", index)
		animationCache:addAnimation(animation, strName)
	end

    -- 语音动画
    AnimationMgr.loadAnimationFromFrame("record_play_ani_%d.png", 1, 3, cmd.VOICE_ANIMATION_KEY)
end

function GameViewLayer:initButtons()
	--按钮回调
	local btnCallback = function(ref, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(ref:getTag(), ref)
		end
	end

    --[[
	--桌子操作按钮屏蔽层
	local callbackShield = function(ref)
		local pos = ref:getTouchEndPosition()
        local rectBg = self.spTableBtBg:getBoundingBox()
        if not cc.rectContainsPoint(rectBg, pos)then
        	self:showTableBt(false)
        end
	end
	self.layoutShield = ccui.Layout:create()
		:setContentSize(cc.size(display.width, display.height))
		:setTouchEnabled(false)
		:addTo(self, 5)
	self.layoutShield:addClickEventListener(callbackShield)
    
	--桌子操作按钮
	self.spTableBtBg = self:getChildByTag(GameViewLayer.SP_TABLE_BT_BG)
        :setLocalZOrder(5)
		:move(1486, 706)
		:setVisible(false)
        ]]
	self.btSet = self:getChildByTag(GameViewLayer.BT_SET)
	--btSet:setSelected(not bAble)
	self.btSet:addTouchEventListener(btnCallback)

	self.btChat = self:getChildByTag(GameViewLayer.BT_CHAT)	--聊天
	self.btChat:addTouchEventListener(btnCallback)
    --[[
	local btExit = self.spTableBtBg:getChildByTag(GameViewLayer.BT_EXIT)	--退出
	btExit:addTouchEventListener(btnCallback)
    ]]
    --[[
	local btTrustee = self.spTableBtBg:getChildByTag(GameViewLayer.BT_TRUSTEE)	--托管
	btTrustee:addTouchEventListener(btnCallback)
	if GlobalUserItem.bPrivateRoom then
		btTrustee:setEnabled(false)
		btTrustee:setColor(cc.c3b(158, 112, 8))
	end
    ]]
    --[[
	local btHowPlay = self.spTableBtBg:getChildByTag(GameViewLayer.BT_HOWPLAY)	--玩法
	btHowPlay:addTouchEventListener(btnCallback)
    ]]
    --[[
	--桌子按钮开关
	self.btSwitch = self:getChildByTag(GameViewLayer.BT_SWITCH)
		:setLocalZOrder(2)
	self.btSwitch:addTouchEventListener(btnCallback)
    --]]
	--开始
	self.btStart = self:getChildByTag(GameViewLayer.BT_START)
		:setLocalZOrder(2)
		:setVisible(false)
	self.btStart:addTouchEventListener(btnCallback)

	--游戏操作按钮
	self.spGameBtn = self:getChildByTag(GameViewLayer.SP_GAMEBTN)
		:setLocalZOrder(3)
		:setVisible(false)
	local btBump = self.spGameBtn:getChildByTag(GameViewLayer.BT_BUMP) 	--碰
		:setEnabled(false)
		:setColor(cc.c3b(158, 112, 8))
	btBump:addTouchEventListener(btnCallback)

    local btEat = self.spGameBtn:getChildByTag(GameViewLayer.BT_EAT) 	-- CHI
		:setEnabled(false)
		:setColor(cc.c3b(158, 112, 8))
	btEat:addTouchEventListener(btnCallback)

	local btBrigde = self.spGameBtn:getChildByTag(GameViewLayer.BT_BRIGDE) 		--杠
		:setEnabled(false)
		:setColor(cc.c3b(158, 112, 8))
	btBrigde:addTouchEventListener(btnCallback)

    local btListen = self.spGameBtn:getChildByTag(GameViewLayer.BT_LISTEN) 	-- TING
		:setEnabled(false)
		:setColor(cc.c3b(158, 112, 8))
	btListen:addTouchEventListener(btnCallback)

	local btWin = self.spGameBtn:getChildByTag(GameViewLayer.BT_WIN)		--胡
		:setEnabled(false)
		:setColor(cc.c3b(158, 112, 8))
	btWin:addTouchEventListener(btnCallback)
	local btPass = self.spGameBtn:getChildByTag(GameViewLayer.BT_PASS)		--过
	btPass:addTouchEventListener(btnCallback)

    self.btnGroupChi = {}
    for i = 1, 3 do 
        self.btnGroupChi[i] = self:getChildByName("FileNode_Chi_"..i)
        for j = 1, 3 do 
            self.btnGroupChi[i]:getChildByName("btnChi"..j)
                :setTag(GameViewLayer.Chi_TAG + (i-1)*3 + j)
                :addTouchEventListener(btnCallback)
        end
        self.btnGroupChi[i]:setLocalZOrder(1)
            :setVisible(false)
    end

    self.btnGroupGang = {}
    for i = 1, 4 do 
        self.btnGroupGang[i] = self:getChildByName("FileNode_Gang_"..i)
        for j = 1, 4 do 
            self.btnGroupGang[i]:getChildByName("btn"..j)
                :setTag(100 + (i-1)*4 + j)
                :addTouchEventListener(btnCallback)
        end
        self.btnGroupGang[i]:setLocalZOrder(1)
            :setVisible(false)
    end

    self.btnZhongGang = self:getChildByName("FileNode_ZhongGang")
    for i = 1, 3 do 
        self.btnZhongGang:getChildByName("btn"..i)
            :setTag(116 + i)
            :addTouchEventListener(btnCallback)
    end
    self.btnZhongGang:setLocalZOrder(1)
        :setVisible(false)

    self.btnChangMaoGang = self:getChildByName("FileNode_ChangMaoGang")
        :setLocalZOrder(1)
        :setVisible(false)
    self.btnChangMaoGang:getChildByName("btn")
        :setTag(120)
        :addTouchEventListener(btnCallback)
   
	--语音
	self.btVoice = self:getChildByTag(GameViewLayer.BT_VOICE)
	self.btVoice:setLocalZOrder(3)
	--btVoice:setVisible(false)
	self.btVoice:addTouchEventListener(function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			self._scene._scene:startVoiceRecord()
        elseif eventType == ccui.TouchEventType.ended 
        	or eventType == ccui.TouchEventType.canceled then
            self._scene._scene:stopVoiceRecord()
        end
	end)
end

function GameViewLayer:showTableBt(bVisible)
    --[[
	if self.spTableBtBg:isVisible() == bVisible then
		return false
	end

	local fSpacing = 334
	if bVisible == true then
        self.layoutShield:setTouchEnabled(true)
		self.btSwitch:setVisible(false)
		self.spTableBtBg:setVisible(true)
		self.spTableBtBg:runAction(cc.MoveBy:create(0.3, cc.p(-fSpacing, 0)))
	else
        self.layoutShield:setTouchEnabled(false)
		self.spTableBtBg:runAction(cc.Sequence:create(
			cc.MoveBy:create(0.5, cc.p(fSpacing, 0)),
			cc.CallFunc:create(function(ref)
				self.btSwitch:setVisible(true)
				self.spTableBtBg:setVisible(false)
			end)))
	end
    --]]
	return true
end


--更新用户显示
function GameViewLayer:OnUpdateUser(viewId, userItem)
	if not viewId or viewId == yl.INVALID_CHAIR then
		print("OnUpdateUser viewId is nil")
		return
	end

	self.m_sparrowUserItem[viewId] = userItem
	--头像
	local head = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SP_HEAD)
	if not userItem then
		self.nodePlayer[viewId]:setVisible(false)
		if head then
			head:setVisible(false)
		end
	else
		self.nodePlayer[viewId]:setVisible(true)
		self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SP_READY):setVisible(userItem.cbUserStatus == yl.US_READY)
		--头像
		if not head then
			head = PopupInfoHead:createNormal(userItem, 82)
			head:setPosition(1, 1)			--初始位置
			head:enableHeadFrame(false)
			head:enableInfoPop(true, posHead[viewId], anchorPointHead[viewId])			--点击弹出的位置0
			head:setTag(GameViewLayer.SP_HEAD)
			self.nodePlayer[viewId]:addChild(head)

			self.m_bNormalState[viewId] = true
		else
			head:updateHead(userItem)
			--掉线头像变灰
			if userItem.cbUserStatus == yl.US_OFFLINE then
				if self.m_bNormalState[viewId] then
					convertToGraySprite(head.m_head.m_spRender)
				end
				self.m_bNormalState[viewId] = false
			else
				if not self.m_bNormalState[viewId] then
					convertToNormalSprite(head.m_head.m_spRender)
				end
				self.m_bNormalState[viewId] = true
			end
		end
		head:setVisible(true)
		--金币
		local score = userItem.lScore
		if userItem.lScore < 0 then
			score = -score
		end
		local strScore = self:numInsertPoint(score)
		if userItem.lScore < 0 then
			strScore = "."..strScore
		end
		self.nodePlayer[viewId]:getChildByTag(GameViewLayer.ASLAB_SCORE):setString(strScore)
		--昵称
		local strNickname = string.EllipsisByConfig(userItem.szNickName, 90, string.getConfig("fonts/round_body.ttf", 14))
		self.nodePlayer[viewId]:getChildByTag(GameViewLayer.TEXT_NICKNAME):setString(strNickname)
	end
end

--用户聊天
function GameViewLayer:userChat(wViewChairId, chatString)
	if chatString and #chatString > 0 then
		self._chatLayer:showGameChat(false)
		--取消上次
		if self.chatDetails[wViewChairId] then
			self.chatDetails[wViewChairId]:stopAllActions()
			self.chatDetails[wViewChairId]:removeFromParent()
			self.chatDetails[wViewChairId] = nil
		end

		--创建label
		local limWidth = 24*12
		local labCountLength = cc.Label:createWithTTF(chatString,"fonts/round_body.ttf", 24)  
		if labCountLength:getContentSize().width > limWidth then
			self.chatDetails[wViewChairId] = cc.Label:createWithTTF(chatString,"fonts/round_body.ttf", 24, cc.size(limWidth, 0))
		else
			self.chatDetails[wViewChairId] = cc.Label:createWithTTF(chatString,"fonts/round_body.ttf", 24)
		end
		self.chatDetails[wViewChairId]:setColor(cc.c3b(0, 0, 0))
		self.chatDetails[wViewChairId]:move(posChat[wViewChairId].x, posChat[wViewChairId].y + 15)
		self.chatDetails[wViewChairId]:setAnchorPoint(cc.p(0.5, 0.5))
		self.chatDetails[wViewChairId]:addTo(self, 3)

	    --改变气泡大小
		self.chatBubble[wViewChairId]:setContentSize(self.chatDetails[wViewChairId]:getContentSize().width+38, self.chatDetails[wViewChairId]:getContentSize().height + 54)
			:setVisible(true)
		--动作
	    self.chatDetails[wViewChairId]:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(3),
	    	cc.CallFunc:create(function(ref)
	    		self.chatDetails[wViewChairId]:removeFromParent()
				self.chatDetails[wViewChairId] = nil
				self.chatBubble[wViewChairId]:setVisible(false)
	    	end)))
    end
end

--用户表情
function GameViewLayer:userExpression(wViewChairId, wItemIndex)
	if wItemIndex and wItemIndex >= 0 then
		self._chatLayer:showGameChat(false)
		--取消上次
		if self.chatDetails[wViewChairId] then
			self.chatDetails[wViewChairId]:stopAllActions()
			self.chatDetails[wViewChairId]:removeFromParent()
			self.chatDetails[wViewChairId] = nil
		end

	    local strName = string.format("e(%d).png", wItemIndex)
	    self.chatDetails[wViewChairId] = cc.Sprite:createWithSpriteFrameName(strName)
	        :move(posChat[wViewChairId].x, posChat[wViewChairId].y + 15)
			:setAnchorPoint(cc.p(0.5, 0.5))
			:addTo(self, 3)
	    --改变气泡大小
		self.chatBubble[wViewChairId]:setContentSize(90,100)
			:setVisible(true)

	    self.chatDetails[wViewChairId]:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(3),
	    	cc.CallFunc:create(function(ref)
	    		self.chatDetails[wViewChairId]:removeFromParent()
				self.chatDetails[wViewChairId] = nil
				self.chatBubble[wViewChairId]:setVisible(false)
	    	end)))
    end
end

function GameViewLayer:onUserVoiceStart(viewId)
	--取消上次
	if self.chatDetails[viewId] then
		self.chatDetails[viewId]:stopAllActions()
		self.chatDetails[viewId]:removeFromParent()
		self.chatDetails[viewId] = nil
	end
     -- 语音动画
    local param = AnimationMgr.getAnimationParam()
    param.m_fDelay = 0.1
    param.m_strName = cmd.VOICE_ANIMATION_KEY
    local animate = AnimationMgr.getAnimate(param)
    self.m_actVoiceAni = cc.RepeatForever:create(animate)

    self.chatDetails[viewId] = display.newSprite("#blank.png")
    	:move(posChat[viewId].x, posChat[viewId].y + 15)
		:setAnchorPoint(cc.p(0.5, 0.5))
		:addTo(self, 3)
	if viewId == 2 or viewId == 3 then
		self.chatDetails[viewId]:setRotation(180)
	end
	self.chatDetails[viewId]:runAction(self.m_actVoiceAni)

    --改变气泡大小
	self.chatBubble[viewId]:setContentSize(90,100)
		:setVisible(true)
end

function GameViewLayer:onUserVoiceEnded(viewId)
	if self.chatDetails[viewId] then
	    self.chatDetails[viewId]:removeFromParent()
	    self.chatDetails[viewId] = nil
	    self.chatBubble[viewId]:setVisible(false)
	end
end

function GameViewLayer:onButtonClickedEvent(tag, ref)
	if tag == GameViewLayer.BT_START then
		print("红中麻将开始！")
		self.btStart:setVisible(false)
		self:showTableBt(false)
         -- hide components 
        self:setShowHide(false)
        self:controlHuiPai(false,0)
        self:controlBaoPai(false)
		self._scene:sendGameStart()
	elseif tag == GameViewLayer.BT_SWITCH then
		print("按钮开关")
		self:showTableBt(true)
	elseif tag == GameViewLayer.BT_CHAT then
		print("聊天！")
		self:showTableBt(false)
		self._chatLayer:showGameChat(true)
		--self._chatLayer:setLocalZOrder(yl.MAX_INT)
	elseif tag == GameViewLayer.BT_SET then
		print("设置开关")
		self:showTableBt(false)
		self._setLayer:showLayer()
		--self._setLayer:setLocalZOrder(yl.MAX_INT)
		-- local data2 = {0x02, 0x03, 0x04, 0x04, 0x05, 0x06, 0x11, 0x12, 0x14, 0x17, 0x19, 0x19, 0x25,
		-- 			0x02, 0x03, 0x04, 0x04, 0x05, 0x06, 0x11, 0x12, 0x14, 0x17, 0x19, 0x19, 0x25}
		-- self:setListeningCard(data2)
	elseif tag == GameViewLayer.BT_HOWPLAY then
		print("玩法！")
		self:showTableBt(false)
        --self._scene._scene:popHelpLayer(yl.HTTP_URL .. "/Mobile/Introduce.aspx?kindid=389&typeid=0")
		self._scene._scene:popHelpLayer2(cmd.KIND_ID, 0)
		-- local data1 = {0x11, 0x08, 0x06, 0x09, 0x08, 0x02, 0x02, 0x07}
		-- local data2 = {0x02, 0x03, 0x04, 0x04, 0x05, 0x06, 0x11, 0x12, 0x14, 0x17, 0x19, 0x19, 0x25, 0x36}
		-- local data3 = {0x22, 0x22, 0x22, 0x19, 0x19}
		-- local data4 = {0x01, 0x03, 0x05, 0x15, 0x16, 0x17, 0x24, 0x24, 0x25, 0x25, 0x25, 0x27, 0x36, 0x29}
		-- local data5 = {1, 1, 1, 6, 7, 8, 9, 18, 19, 20, 33, 34, 35, 53}
		-- for i = 1, cmd.GAME_PLAYER do
		-- 	self._cardLayer:setHandCard(i, 14, data5)
		-- end
	elseif tag == GameViewLayer.BT_EXIT then
		print("退出！")
		-- self._cardLayer:bumpOrBridgeCard(1, {1, 1, 1}, GameLogic.SHOW_PENG)
		-- self._cardLayer:bumpOrBridgeCard(2, {1, 1, 1, 1}, GameLogic.SHOW_PENG)
		--self._cardLayer:bumpOrBridgeCard(3, {1, 1, 1, 1}, GameLogic.SHOW_AN_GANG)
		-- self._cardLayer:bumpOrBridgeCard(4, {1, 1, 1, 1}, GameLogic.SHOW_FANG_GANG)
		self._scene:onQueryExitGame()
	elseif tag == GameViewLayer.BT_TRUSTEE then
		print("托管")
		self:showTableBt(false)
		self._scene:sendUserTrustee(true)
	elseif tag == GameViewLayer.BT_TRUSTEECANCEL then
		print("取消托管")
		self._scene:sendUserTrustee(false)
	-- elseif tag == GameViewLayer.BT_VOICE then
	-- 	print("语音关闭！")
	-- 	self._scene._scene:startVoiceRecord()
	-- elseif tag == GameViewLayer.BT_VOICEOPEN then
	-- 	print("语音开启！")
	-- 	self._scene._scene:stopVoiceRecord()
	elseif tag == GameViewLayer.BT_BUMP then
		print("碰！")

		--发送碰牌
		local cbOperateCard = {self.cbActionCard, self.cbActionCard, self.cbActionCard}
		self._scene:sendOperateCard(GameLogic.WIK_PENG, cbOperateCard)

		self:HideGameBtn()
	elseif tag == GameViewLayer.BT_BRIGDE then
		print("杠！")
        self.GangTable = {{0, 0, 0, 0, 16}, 
                          {0, 0, 0, 0, 16}, 
                          {0, 0, 0, 0, 16}, 
                          {0, 0, 0, 0, 512}, 
                          {0, 0, 0, 0, 256}, 
                          {0, 0, 0, 0, 0}}
        self:allKindGang()
        dump(self.GangTable, "GangTable",3)
        local n = 0
        for i = 1, 6 do
            if self.GangTable[i][1] >0 then
                n = n + 1
            end
        end
        local xflag = {1, 1, 1, 1, 1}
        local xBtnGang = {300, 300, 300, 260, 160}
        if n < 1 then
            local cbOperateCard = {self.cbActionCard, self.cbActionCard, self.cbActionCard}
            self._scene:sendOperateCard(GameLogic.WIK_GANG, cbOperateCard)
        elseif n == 1 then
            for i = 1, 6 do
                if self.GangTable[i][1] ~= 0 then
                    local cbOperateCard = {self.GangTable[i][1], self.GangTable[i][2], self.GangTable[i][3]}
                    self._scene:sendOperateCard(self.GangTable[i][5], cbOperateCard)
                end
            end
        else 
            for i = 1, 4 do
                if self.GangTable[i][1] ~= 0 then
                    xflag[i] = 0
                    for j = 1, 4 do
                        value = self.GangTable[i][j]
                        local nValue = math.mod(value, 16)
	                    local nColor = math.floor(value/16)
	                    display.newSprite("game/font_middle/font_"..nColor.."_"..nValue..".png")
		                    :move(35, 53)
                            :setTag(1)
		                    :addTo(self.btnGroupGang[i]:getChildByName("btn"..j))
                    end
                    self.btnGroupGang[i]:setVisible(true)
                end
            end
            if self.GangTable[5][1] ~= 0 then
                xflag[5] = 0
                for i = 1, 3 do
                    value = self.GangTable[5][i]
                    local nValue = math.mod(value, 16)
	                local nColor = math.floor(value/16)
                    display.newSprite("game/font_middle/font_"..nColor.."_"..nValue..".png")
		                    :move(35, 53)
                            :setTag(1)
		                    :addTo(self.btnZhongGang:getChildByName("btn"..i))
                end
                self.btnZhongGang:setVisible(true)
            end
            if self.GangTable[6][1] ~= 0 then
                value = self.GangTable[6][1]
                local nValue = math.mod(value, 16)
	            local nColor = math.floor(value/16)
                display.newSprite("game/font_middle/font_"..nColor.."_"..nValue..".png")
		                :move(35, 53)
                        :setTag(1)
		                :addTo(self.btnChangMaoGang:getChildByName("btn"))
                self.btnChangMaoGang:setVisible(true)
            end
            -- set position of Gangbtns
            self.btnGroupGang[1]:move(300, 200)
            for i = 1, 5 do 
                xBtnGang[i] = xBtnGang[i] * (1 - xflag[i])
            end
            self.btnGroupGang[2]:move(300 + xBtnGang[1], 200)
            self.btnGroupGang[3]:move(300 + xBtnGang[1] + xBtnGang[2], 200)
            self.btnGroupGang[4]:move(300 + xBtnGang[1] + xBtnGang[2] + xBtnGang[3], 200)
            self.btnZhongGang:move(300 + xBtnGang[1] + xBtnGang[2] + xBtnGang[3] + xBtnGang[4], 200)
            self.btnChangMaoGang:move(300 + xBtnGang[1] + xBtnGang[2] + xBtnGang[3] + xBtnGang[4] + xBtnGang[5], 200)
        end
        
		self:HideGameBtn()
    elseif tag == GameViewLayer.BT_EAT then
        print("吃！")
        local len = #self.chi_data
        if len == 1 then
            local cbOperateCard = {self.chi_data[1][1], self.chi_data[1][2], self.chi_data[1][3]}
            self._scene:sendOperateCard(self.chi_data[1][4], cbOperateCard)
        else
            for i = 1, len do 
                local direct = self.chi_data[i][4]
                local font_data = {0, 0, 0}
                if direct == 1 then
                    font_data = {self.chi_data[i][1], self.chi_data[i][2], self.chi_data[i][3]}
                end
                if direct == 2 then
                    font_data = {self.chi_data[i][2], self.chi_data[i][1], self.chi_data[i][3]}
                end 
                if direct == 4 then
                    font_data = {self.chi_data[i][2], self.chi_data[i][3], self.chi_data[i][1]}
                end
                for j = 1, 3 do
                    value = font_data[j]
                    local nValue = math.mod(value, 16)
	                local nColor = math.floor(value/16)
	                display.newSprite("game/font_middle/font_"..nColor.."_"..nValue..".png")
		                :move(35, 53)
                        :setTag(1)
		                :addTo(self.btnGroupChi[i]:getChildByName("btnChi"..j))
                end
                self.btnGroupChi[i]:setVisible(true)
            end
        end
        self:HideGameBtn()
    elseif tag == GameViewLayer.BT_LISTEN then
        print("听!")
        self.listen_state = true
		--self._scene:sendUserListenCard(true)
        self:HideGameBtn()
	elseif tag == GameViewLayer.BT_WIN then
		print("胡！")

		local cbOperateCard = {self.cbActionCard, 0, 0}
		self._scene:sendOperateCard(GameLogic.WIK_CHI_HU, cbOperateCard)

		self:HideGameBtn()
	elseif tag == GameViewLayer.BT_PASS then
		print("过！")
		local cbOperateCard = {0, 0, 0}
		self._scene:sendOperateCard(GameLogic.WIK_NULL, cbOperateCard)
		self:HideGameBtn()
	elseif tag > GameViewLayer.Chi_TAG and tag <= GameViewLayer.Chi_TAG + 3 then
        local cbOperateCard = {self.chi_data[1][1], self.chi_data[1][2], self.chi_data[1][3]}
        self._scene:sendOperateCard(self.chi_data[1][4], cbOperateCard)
        self:eatBtnHide()
    elseif tag > GameViewLayer.Chi_TAG + 3 and tag <= GameViewLayer.Chi_TAG + 6 then
        local cbOperateCard = {self.chi_data[2][1], self.chi_data[2][2], self.chi_data[2][3]}
        self._scene:sendOperateCard(self.chi_data[2][4], cbOperateCard)
        self:eatBtnHide()
    elseif tag > GameViewLayer.Chi_TAG + 6 and tag <= GameViewLayer.Chi_TAG + 9 then
        local cbOperateCard = {self.chi_data[3][1], self.chi_data[3][2], self.chi_data[3][3]}
        self._scene:sendOperateCard(self.chi_data[3][4], cbOperateCard)
        self:eatBtnHide()
    elseif tag > 100 and tag <= 104 then
        local cbOperateCard = {self.GangTable[1][1], self.GangTable[1][2], self.GangTable[1][3]}
        self._scene:sendOperateCard(self.GangTable[1][5], cbOperateCard)
        self:gangBtnHide()
    elseif tag > 104 and tag <= 108 then
        local cbOperateCard = {self.GangTable[2][1], self.GangTable[2][2], self.GangTable[2][3]}
        self._scene:sendOperateCard(self.GangTable[2][5], cbOperateCard)
        self:gangBtnHide()
    elseif tag > 108 and tag <= 112 then
        local cbOperateCard = {self.GangTable[3][1], self.GangTable[3][2], self.GangTable[3][3]}
        self._scene:sendOperateCard(self.GangTable[3][5], cbOperateCard)
        self:gangBtnHide()
    elseif tag > 112 and tag <= 116 then
        local cbOperateCard = {self.GangTable[4][1], self.GangTable[4][2], self.GangTable[4][3]}
        self._scene:sendOperateCard(self.GangTable[4][5], cbOperateCard)
        self:gangBtnHide()
    elseif tag > 116 and tag <= 119 then
        local cbOperateCard = {self.GangTable[5][1], self.GangTable[5][2], self.GangTable[5][3]}
        self._scene:sendOperateCard(self.GangTable[5][5], cbOperateCard)
        self:gangBtnHide()
    elseif tag == 120 then
        local cbOperateCard = {self.GangTable[6][1], self.GangTable[6][2], self.GangTable[6][3]}
        self._scene:sendOperateCard(self.GangTable[6][5], cbOperateCard)
        self:gangBtnHide()
    else 
		print("default")
	end
end

function GameViewLayer:eatBtnHide()
    for i = 1, 3 do 
        for j = 1, 3 do
            if #self.btnGroupChi[i]:getChildByName("btnChi"..j):getChildren() > 0 then
                self.btnGroupChi[i]:getChildByName("btnChi"..j):removeChildByTag(1)
            end
        end
        self.btnGroupChi[i]:setVisible(false)
    end
end

function GameViewLayer:gangBtnHide()
    for i = 1, 4 do 
        for j = 1, 4 do 
            if #self.btnGroupGang[i]:getChildByName("btn"..j):getChildren() > 0 then
                self.btnGroupGang[i]:getChildByName("btn"..j):removeChildByTag(1)
            end
        end
        self.btnGroupGang[i]:setVisible(false)
    end
    for i = 1, 3 do 
        if #self.btnZhongGang:getChildByName("btn"..i):getChildren() > 0 then
            self.btnZhongGang:getChildByName("btn"..i):removeChildByTag(1)
        end
    end
    self.btnZhongGang:setVisible(false)
    if #self.btnChangMaoGang:getChildByName("btn"):getChildren() > 0 then
        self.btnChangMaoGang:getChildByName("btn"):removeChildByTag(1)
    end
    self.btnChangMaoGang:setVisible(false)
end

function GameViewLayer:allKindGang()
    local handGangData = self._cardLayer:getAllGangData()
    if #handGangData >= 1 then
        for i = 1, #handGangData do
            self.GangTable[i][1] = handGangData[i]
            self.GangTable[i][2] = handGangData[i]
            self.GangTable[i][3] = handGangData[i]
            self.GangTable[i][4] = handGangData[i]
            self.GangTable[i][5] = GameLogic.WIK_GANG
        end
    end
    if math.mod(self.actionMask, 512*2) >= 512 then
        self.GangTable[4][1] = 49
        self.GangTable[4][2] = 50
        self.GangTable[4][3] = 51
        self.GangTable[4][4] = 52
        self.GangTable[4][5] = GameLogic.WIK_WIND
    end
    if math.mod(self.actionMask, 256*2) >= 256 then
        self.GangTable[5][1] = 53
        self.GangTable[5][2] = 54
        self.GangTable[5][3] = 55
        self.GangTable[5][4] = 0
        self.GangTable[5][5] = GameLogic.WIK_ARROW
    end
    if math.mod(self.actionMask, 1024*2) >= 1024 then
        self.GangTable[6][1] = self.cbActionCard
        self.GangTable[6][2] = 0
        self.GangTable[6][3] = 0
        self.GangTable[6][4] = 0
        self.GangTable[6][5] = GameLogic.WIK_CHASEARROW
    end
    if math.mod(self.actionMask, 2048*2) >= 2048 then
        self.GangTable[6][1] = self.cbActionCard
        self.GangTable[6][2] = 0
        self.GangTable[6][3] = 0
        self.GangTable[6][4] = 0
        self.GangTable[6][5] = GameLogic.WIK_CHASEWIND
    end
    return true
end

--计时器刷新
function GameViewLayer:OnUpdataClockView(viewId, time)
	if not viewId or viewId == yl.INVALID_CHAIR or not time then
		--self.spClock:setVisible(false)
		self.asLabTime:setString(0)
	else
		--self.spClock:setVisible(true)
		local res = string.format("sp_clock_Dong_%d.png", viewId)
		self.spClock:setSpriteFrame(res)
		self.asLabTime:setString(time)
	end
end

--开始
function GameViewLayer:gameStart(startViewId, wHeapHead, cbCardData, cbCardCount, cbSiceCount1, cbSiceCount2)
    -- display HuiPai and sendCard
    if self._scene.cbEnabledHuiPai then 
        local display_Hui_card = display.newSprite("#card_round_middle_up.png")
                        :setPosition(667,375)
					    :addTo(self)
        width=80
        height=116
        local nValue = math.mod(self._scene:getShowingData(GameLogic.MAGIC_DATA), 16)
	    local nColor = math.floor(self._scene:getShowingData(GameLogic.MAGIC_DATA)/16)
	    local hui_num=display.newSprite("game/font_big/font_"..nColor.."_"..nValue..".png")
		    :move(width/2+8, height/2 + 20)
		    :addTo(display_Hui_card)
        scaleTo=cc.ScaleTo:create(1,1.9)
        fadeOut = cc.FadeOut:create(1.0)
        this=display_Hui_card
        display_Hui_card:runAction(cc.Sequence:create(scaleTo, fadeOut, cc.CallFunc:create(function()
					    this:removeSelf()
                        self._cardLayer:sendCard(cbCardData, cbCardCount)
				    end)
			    ))
    else 
        self._cardLayer:sendCard(cbCardData, cbCardCount)
    end
	--self:runSiceAnimate(cbSiceCount1, cbSiceCount2, function()
		--self._cardLayer:sendCard(cbCardData, cbCardCount)
	--end)
end
--用户出牌
function GameViewLayer:gameOutCard(viewId, card)
	self:showCardPlate(viewId, card)
	self._cardLayer:removeHandCard(viewId, {card}, true)

	self.cbOutCardTemp = card
	self.cbOutUserTemp = viewId
	--self._cardLayer:discard(viewId, card)
end
--用户抓牌
function GameViewLayer:gameSendCard(viewId, card, bTail)
	--把上一个人打出的牌丢入弃牌堆
	if self.cbOutCardTemp ~= 0 and not bTail then
		self._cardLayer:discard(self.cbOutUserTemp, self.cbOutCardTemp)
		self.cbOutUserTemp = nil
		self.cbOutCardTemp = 0
	end

	--清理之前的出牌
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
			self:showCardPlate(nil)
			self:showOperateFlag(nil)
		end)))

	--当前的人抓牌
	self._cardLayer:catchCard(viewId, card, bTail)
end
--摇骰子
function GameViewLayer:runSiceAnimate(cbSiceCount1, cbSiceCount2, callback)
	local str1 = string.format("sice_red_%d", cbSiceCount1)
	local str2 = string.format("sice_white_%d", cbSiceCount2)
	local siceX1 = 667 - 320 + math.random(640) - 35
	local siceY1 = 375 - 120 + math.random(240) + 43
	local siceX2 = 667 - 320 + math.random(640) - 35
	local siceY2 = 375 - 120 + math.random(240) + 43
	display.newSprite()
		:move(siceX1, siceY1)
		:setTag(GameViewLayer.SP_SICE1)
		:addTo(self, 0)
		:runAction(cc.Sequence:create(
			self:getAnimate(str1),
			cc.DelayTime:create(1),
			cc.CallFunc:create(function(ref)
				--ref:removeFromParent()
			end)))
	display.newSprite()
		:move(siceX2, siceY2)
		:setTag(GameViewLayer.SP_SICE2)
		:addTo(self, 0)
		:runAction(cc.Sequence:create(
			self:getAnimate(str2),
			cc.DelayTime:create(1),
			cc.CallFunc:create(function(ref)
				--ref:removeFromParent()
				if callback then
					callback()
				end
			end)))
	self._scene:PlaySound(cmd.RES_PATH.."sound/DRAW_SICE.wav")
end

function GameViewLayer:sendCardFinish()
	local spSice1 = self:getChildByTag(GameViewLayer.SP_SICE1)
	if spSice1 then
		spSice1:removeFromParent()
	end
	local spSice2 = self:getChildByTag(GameViewLayer.SP_SICE2)
	if spSice2 then
		spSice2:removeFromParent()
	end	
	self._scene:sendCardFinish()
    -- show components
    self:setShowHide(true)
    if self._scene.cbEnabledHuiPai then
        self:controlHuiPai(true,self._scene:getShowingData(GameLogic.MAGIC_DATA))
    end
    if self._scene.cbEnabledBaoPai then
        self:controlBaoPai(true)
    end
end

function GameViewLayer:gameConclude()
    for i = 1, cmd.GAME_PLAYER do
		self:setUserTrustee(i, false)
	end
	self._cardLayer:gameEnded()
end

function GameViewLayer:HideGameBtn()
	for i = GameViewLayer.BT_BUMP, GameViewLayer.BT_EAT do
        if i ~= GameViewLayer.BT_PASS then
            local bt = self.spGameBtn:getChildByTag(i)
		    if bt then
			    bt:setEnabled(false)
			    bt:setColor(cc.c3b(158, 112, 8))
		    end
        end
	end
	self.spGameBtn:setVisible(false)
end

--识别动作掩码
function GameViewLayer:recognizecbActionMask(cbActionMask, cbCardData)
	print("收到提示操作：", cbActionMask, cbCardData)
	if cbActionMask == GameLogic.WIK_NULL then
		assert("false")
		return false
	end

    self.actionMask = cbActionMask
	if self._cardLayer:isUserMustWin() then
		--必须胡牌的情况
		self.spGameBtn:getChildByTag(GameViewLayer.BT_PASS)
			:setEnabled(false)
			:setColor(cc.c3b(158, 112, 8))
		-- self.spGameBtn:getChildByTag(GameViewLayer.BT_WIN)
		-- 	:setEnabled(true)
		-- 	:setColor(cc.c3b(255, 255, 255))
		-- self.spGameBtn:setVisible(true)
		-- self._scene:SetGameOperateClock()
		-- return true
	end

	if cbCardData then
		self.cbActionCard = cbCardData
    else 
        self.cbActionCard = 0
	end

    if cbActionMask >= 32768 then
        cbActionMask = cbActionMask - 32768
        self:playAnimHuanBao()
        return true
    end

    if cbActionMask >= 2048 then
        cbActionMask = cbActionMask - 2048
        self.spGameBtn:getChildByTag(GameViewLayer.BT_BRIGDE)
			:setEnabled(true)
			:setColor(cc.c3b(255, 255, 255))
    end

    if cbActionMask >= 1024 then
        cbActionMask = cbActionMask - 1024
        self.spGameBtn:getChildByTag(GameViewLayer.BT_BRIGDE)
			:setEnabled(true)
			:setColor(cc.c3b(255, 255, 255))
    end
    
    if cbActionMask >= 512 then
        cbActionMask = cbActionMask - 512
        self.spGameBtn:getChildByTag(GameViewLayer.BT_BRIGDE)
			:setEnabled(true)
			:setColor(cc.c3b(255, 255, 255))
    end

    if cbActionMask >= 256 then
        cbActionMask = cbActionMask - 256
        self.spGameBtn:getChildByTag(GameViewLayer.BT_BRIGDE)
			:setEnabled(true)
			:setColor(cc.c3b(255, 255, 255))
    end

	if cbActionMask >= 128 then 				--放炮
		cbActionMask = cbActionMask - 128
		self.spGameBtn:getChildByTag(GameViewLayer.BT_WIN)
			:setEnabled(true)
			:setColor(cc.c3b(255, 255, 255))
	end
	if cbActionMask >= 64 then 					--胡
		cbActionMask = cbActionMask - 64
		self.spGameBtn:getChildByTag(GameViewLayer.BT_WIN)
			:setEnabled(true)
			:setColor(cc.c3b(255, 255, 255))
	end
	if cbActionMask >= 32 then 					--听
		cbActionMask = cbActionMask - 32
        self.spGameBtn:getChildByTag(GameViewLayer.BT_LISTEN)
			:setEnabled(true)
			:setColor(cc.c3b(255, 255, 255))
	end
	if cbActionMask >= 16 then 					--杠
		cbActionMask = cbActionMask - 16
		self.spGameBtn:getChildByTag(GameViewLayer.BT_BRIGDE)
			:setEnabled(true)
			:setColor(cc.c3b(255, 255, 255))
	end
	if cbActionMask >= 8 then 					--碰
		cbActionMask = cbActionMask - 8
		if self._cardLayer:isUserCanBump() then
			self.spGameBtn:getChildByTag(GameViewLayer.BT_BUMP)
				:setEnabled(true)
				:setColor(cc.c3b(255, 255, 255))
		end
	end

    if cbActionMask > 0 then     -- Chi
        self:playAnimJinBao()
        self.spGameBtn:getChildByTag(GameViewLayer.BT_EAT)
				:setEnabled(true)
				:setColor(cc.c3b(255, 255, 255))
        self.chi_data = {}
        if math.mod(cbActionMask, 4*2) >= 4 then
            table.insert(self.chi_data, {cbCardData, cbCardData - 2, cbCardData - 1, 4})
        end
        if math.mod(cbActionMask, 2*2) >= 2 then
            table.insert(self.chi_data, {cbCardData, cbCardData - 1, cbCardData + 1, 2})
        end
        if math.mod(cbActionMask, 2*1) >= 1 then
            table.insert(self.chi_data, {cbCardData, cbCardData + 1, cbCardData + 2, 1})
        end
    end

	self.spGameBtn:setVisible(true)
	self._scene:SetGameOperateClock()

	return true
end

function GameViewLayer:getAnimate(name, bEndRemove)
	local animation = cc.AnimationCache:getInstance():getAnimation(name)
	local animate = cc.Animate:create(animation)

	if bEndRemove then
		animate = cc.Sequence:create(animate, cc.CallFunc:create(function(ref)
			ref:removeFromParent()
		end))
	end

	return animate
end
--设置听牌提示
function GameViewLayer:setListeningCard(cbCardData)
	if cbCardData == nil then
		self.spListenBg:setVisible(false)
		return
	end
	assert(type(cbCardData) == "table")
	self.spListenBg:removeAllChildren()
	--self.spListenBg:setVisible(true)

	local cbCardCount = #cbCardData
	local bTooMany = (cbCardCount >= 16)
	--拼接块
	local width = 44
	local height = 67
	local posX = 327
	local fSpacing = 100
	if not bTooMany then
		for i = 1, fSpacing*cbCardCount do
			display.newSprite("#sp_listenBg_2.png")
				:move(posX, 46.5)
				:setAnchorPoint(cc.p(0, 0.5))
				:addTo(self.spListenBg)
			posX = posX + 1
			if i > 700 then
				break
			end
		end
	end
	--尾块
	display.newSprite("#sp_listenBg_3.png")
		:move(posX, 46.5)
		:setAnchorPoint(cc.p(0, 0.5))
		:addTo(self.spListenBg)
	--可胡牌过多，屏幕摆不下
	if bTooMany then
		local cardBack = display.newSprite("game/font_small/card_down.png")
			:move(183 + 40, 46)
			:addTo(self.spListenBg)
		local cardFont = display.newSprite("game/font_small/font_3_5.png")
			:move(width/2, height/2 + 8)
			:addTo(cardBack)

		local strFilePrompt = ""
		local spListenCount = nil
		if cbCardCount == 28 then 		--所有牌
			strFilePrompt = "#389_sp_listen_anyCard.png"
		else
			strFilePrompt = "#389_sp_listen_manyCard.png"
			spListenCount = cc.Label:createWithTTF(cbCardCount.."", "fonts/round_body.ttf", 30)
		end

		local spPrompt = display.newSprite(strFilePrompt)
			:move(183 + 110, 46)
			:setAnchorPoint(cc.p(0, 0.5))
			:addTo(self.spListenBg)
		if spListenCount then
			spListenCount:move(70, 12):addTo(spPrompt)
		end

		-- cc.Label:createWithTTF("厉害了word哥！你可以胡的牌太多，摆不下了....", "fonts/round_body.ttf", 50)
		-- 	:move(260, 40)
		-- 	:setAnchorPoint(cc.p(0, 0.5))
		-- 	:setColor(cc.c3b(0, 0, 0))
		-- 	:addTo(self.spListenBg, 1)
	end
	--牌、番、数
	self.cbAppearCardIndex = GameLogic.DataToCardIndex(self._scene.cbAppearCardData)
	for i = 1, cbCardCount do
		if bTooMany then
			break
		end
		local tempX = fSpacing*(i - 1)
		--local rectX = self._cardLayer:switchToCardRectX(cbCardData[i])
		local cbCardIndex = GameLogic.SwitchToCardIndex(cbCardData[i])
		local nLeaveCardNum = 4 - self.cbAppearCardIndex[cbCardIndex]
		--牌底
		local card = display.newSprite("game/font_small/card_down.png")
			--:setTextureRect(cc.rect(width*rectX, 0, width, height))
			:move(183 + tempX, 46)
			:addTo(self.spListenBg)
		--字体
		local nValue = math.mod(cbCardData[i], 16)
		local nColor = math.floor(cbCardData[i]/16)
		local strFile = "game/font_small/font_"..nColor.."_"..nValue..".png"
		local cardFont = display.newSprite(strFile)
			:move(width/2, height/2 + 8)
			:addTo(card)
		cc.Label:createWithTTF("1", "fonts/round_body.ttf", 16)		--番数
			:move(220 + tempX, 61)
			:setColor(cc.c3b(254, 246, 165))
			:addTo(self.spListenBg)
		display.newSprite("#sp_listenTimes.png")
			:move(244 + tempX, 61)
			:addTo(self.spListenBg)
		cc.Label:createWithTTF(nLeaveCardNum.."", "fonts/round_body.ttf", 16) 		--剩几张
			:move(220 + tempX, 31)
			:setColor(cc.c3b(254, 246, 165))
			:setTag(cbCardIndex)
			:addTo(self.spListenBg)
		display.newSprite("#sp_listenNum.png")
			:move(244 + tempX, 31)
			:addTo(self.spListenBg)
	end
end

--减少可听牌数
function GameViewLayer:reduceListenCardNum(cbCardData)
	local cbCardIndex = GameLogic.SwitchToCardIndex(cbCardData)
	if #self.cbAppearCardIndex == 0 then
		self.cbAppearCardIndex = GameLogic.DataToCardIndex(self._scene.cbAppearCardData)
	end
	self.cbAppearCardIndex[cbCardIndex] = self.cbAppearCardIndex[cbCardIndex] + 1
	local labelLeaveNum = self.spListenBg:getChildByTag(cbCardIndex)
	if labelLeaveNum then
		local nLeaveCardNum = 4 - self.cbAppearCardIndex[cbCardIndex]
		labelLeaveNum:setString(nLeaveCardNum.."")
	end
end

function GameViewLayer:setBanker(viewId)
	if viewId < 1 or viewId > cmd.GAME_PLAYER then
		print("chair id is error!")
		return false
	end
	local spBanker = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SP_BANKER)
	spBanker:setVisible(true)

	return true
end

function GameViewLayer:setUserTrustee(viewId, bTrustee)
	--self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SP_TRUSTEE):setVisible(bTrustee)
	if viewId == cmd.MY_VIEWID then
		self.spTrusteeCover:setVisible(bTrustee)
	end
end

--设置房间信息
function GameViewLayer:setRoomInfo(tableId, chairId)
end

function GameViewLayer:onTrusteeTouchCallback(event, x, y)
	if not self.spTrusteeCover:isVisible() then
		return false
	end

	local rect = self.spTrusteeCover:getChildByTag(GameViewLayer.SP_TRUSTEEBG):getBoundingBox()
	if cc.rectContainsPoint(rect, cc.p(x, y)) then
		return true
	else
		return false
	end
end
--设置剩余牌
function GameViewLayer:setRemainCardNum(num)
	--local strRemianNum = string.format("剩%d张", num)
	
	self.textNum:setString(num)
	-- if num == 112 then
	-- 	text:setVisible(false)
	-- else
	-- 	text:setVisible(true)
	-- end
end
--牌托
function GameViewLayer:showCardPlate(viewId, cbCardData)
	if nil == viewId then
		self.spCardPlate:setVisible(false)
		return
	end 
	--local rectX = self._cardLayer:switchToCardRectX(cbCardData)
	local nValue = math.mod(cbCardData, 16)
	local nColor = math.floor(cbCardData/16)
	local strFile = "game/font_middle/font_"..nColor.."_"..nValue..".png"
	self.spCardPlate:getChildByTag(GameViewLayer.SP_PLATECARD):setTexture(strFile)
	self.spCardPlate:move(posPlate[viewId]):setVisible(true)
end
--操作效果
function GameViewLayer:showOperateFlag(viewId, operateCode)
	local spFlag = self:getChildByTag(GameViewLayer.SP_OPERATFLAG)
	if spFlag then
		spFlag:removeFromParent()
	end
	if nil == viewId then
		return false
	end
	local strFile = "#"
	if operateCode == GameLogic.WIK_NULL then
		return false
	elseif operateCode == GameLogic.WIK_CHI_HU then
		strFile = "#sp_other_Hu.png"
	elseif operateCode == GameLogic.WIK_LISTEN then
		strFile = "#sp_other_Ting.png"
	elseif operateCode == GameLogic.WIK_GANG or operateCode == GameLogic.WIK_ARROW or operateCode == GameLogic.WIK_WIND or operateCode == GameLogic.WIK_CHASEARROW or operateCode == GameLogic.WIK_CHASEWIND then
		strFile = "#sp_other_Gang.png"
	elseif operateCode == GameLogic.WIK_PENG then
		strFile = "#sp_other_Peng.png"
	elseif operateCode <= GameLogic.WIK_RIGHT then
		strFile = "#sp_other_Chi.png"
	end
	display.newSprite(strFile)
		:setTag(GameViewLayer.SP_OPERATFLAG)
		:move(posPlate[viewId])
		:addTo(self, 2)

	return true
end

--数字中插入点
function GameViewLayer:numInsertPoint(lScore)
	assert(lScore >= 0)
	local strRes = ""
	local str = string.format("%d", lScore)
	local len = string.len(str)

	local times = math.floor(len/3)
	local remain = math.mod(len, 3)
	strRes = strRes..string.sub(str, 1, remain)
	for i = 1, times do
		if strRes ~= "" then
			strRes = strRes.."/"
		end
		local index = (i - 1)*3 + remain + 1	--截取起始位置
		strRes = strRes..string.sub(str, index, index + 2)
	end

	return strRes
end


function GameViewLayer:setRoomHost(viewId)
	for i = 1, cmd.GAME_PLAYER do
		self.nodePlayer[i]:getChildByTag(GameViewLayer.SP_ROOMHOST):setVisible(false)
	end
	self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SP_ROOMHOST):setVisible(true)
end

return GameViewLayer