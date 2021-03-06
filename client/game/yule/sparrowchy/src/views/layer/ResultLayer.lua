local cmd = appdf.req(appdf.GAME_SRC.."yule.sparrowchy.src.models.CMD_Game")
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC.."ExternalFun")
local CardLayer = appdf.req(appdf.GAME_SRC.."yule.sparrowchy.src.views.layer.CardLayer")
local PopupInfoHead = appdf.req("client.src.external.PopupInfoHead")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.sparrowchy.src.models.GameLogic")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

local ResultLayer = class("ResultLayer", function(scene)
	local resultLayer = cc.CSLoader:createNode(cmd.RES_PATH.."gameResult/GameResultLayer.csb")
	return resultLayer
end)

ResultLayer.TAG_NODE_USER_1					= 1
ResultLayer.TAG_NODE_USER_2					= 2
ResultLayer.TAG_NODE_USER_3					= 3
ResultLayer.TAG_NODE_USER_4					= 4
ResultLayer.TAG_SP_ROOMHOST					= 5
ResultLayer.TAG_SP_BANKER					= 6
ResultLayer.TAG_BT_RECODESHOW				= 8
ResultLayer.TAG_BT_CONTINUE					= 9

ResultLayer.TAG_SP_HEADCOVER				= 1
ResultLayer.TAG_TEXT_NICKNAME				= 2
ResultLayer.TAG_ASLAB_SCORE					= 3
ResultLayer.TAG_HEAD 						= 4
ResultLayer.TAG_NODE_CARD					= 5

ResultLayer.WINNER_ORDER					= 1

local posBanker = {cc.p(146, 556), cc.p(146, 451), cc.p(146, 343), cc.p(146, 237)}

function ResultLayer:onInitData()
	--body
	self.winnerIndex = nil
	self.bShield = false
end

function ResultLayer:onResetData()
	--body
	self.winnerIndex = nil
	self.bShield = false
	self.nodeAwardCard:removeAllChildren()
	self.nodeRemainCard:removeAllChildren()
	for i = 1, cmd.GAME_PLAYER do
		self.nodeUser[i]:getChildByTag(ResultLayer.TAG_NODE_CARD):removeAllChildren()
		local score = self.nodeUser[i]:getChildByTag(ResultLayer.TAG_ASLAB_SCORE)
		if score then
			score:removeFromParent()
		end
	end
end

function ResultLayer:ctor(scene)
	self._scene = scene
	self:onInitData()
	ExternalFun.registerTouchEvent(self, true)

	local btRecodeShow = self:getChildByTag(ResultLayer.TAG_BT_RECODESHOW)
	btRecodeShow:setVisible(false)
	btRecodeShow:addClickEventListener(function(ref)
		self:recodeShow()
	end)

	local btContinue = self:getChildByTag(ResultLayer.TAG_BT_CONTINUE)
	btContinue:setPositionX(display.cx)
	btContinue:addClickEventListener(function(ref)
		self:hideLayer()
		self._scene:onButtonClickedEvent(self._scene.BT_START)
	end)

	self.nodeUser = {}
	for i = 1, cmd.GAME_PLAYER do
		self.nodeUser[i] = self:getChildByTag(ResultLayer.TAG_NODE_USER_1 + i - 1)
		self.nodeUser[i]:setLocalZOrder(1)
		self.nodeUser[i]:getChildByTag(ResultLayer.TAG_SP_HEADCOVER):setLocalZOrder(1)
		--个人麻将
		local nodeUserCard = cc.Node:create()
			:setTag(ResultLayer.TAG_NODE_CARD)
			:addTo(self.nodeUser[i])
	end
	--奖码
	self.nodeAwardCard = cc.Node:create():addTo(self)
	--剩余麻将
	self.nodeRemainCard = cc.Node:create():addTo(self)
	--庄标志
	self.spBanker = self:getChildByTag(6):setLocalZOrder(1)
    -- init flags --
    self:getChildByName("sp_ZiMo_cy"):setVisible(false)
    self:getChildByName("sp_ZhuangJia"):setVisible(false)
    self:getChildByName("sp_ZiMo_cy"):setVisible(false)
    self:getChildByName("sp_QingYiSe"):setVisible(false)
    self:getChildByName("sp_PiaoHu"):setVisible(false)
    self:getChildByName("sp_QiongHu"):setVisible(false)
    self:getChildByName("sp_ShiSanYao"):setVisible(false)
    self:getChildByName("txt_ShowBaYi"):setVisible(false)
    self:getChildByName("txt_JiaHu"):setVisible(false)
    self:getChildByName("txt_JinBao"):setVisible(false)
    self:getChildByName("txt_HaiDiLaoYue"):setVisible(false)
    self:getChildByName("txt_GangShangHua"):setVisible(false)
    self:getChildByName("txt_GangShangPao"):setVisible(false)
    self:getChildByName("txt_QiangGangHu"):setVisible(false)
end

function ResultLayer:onTouchBegan(touch, event)
	local pos = touch:getLocation()
	local rect = cc.rect(17, 25, 1330, 750)
	if not cc.rectContainsPoint(rect, pos) then
		self:hideLayer()
	end
	return self.bShield
end

function ResultLayer:showLayer(resultList, cbAwardCard, cbRemainCard, wBankerChairId, cbHuCard, wProvideUser, cbBiMenStatus, cbHuKindData)
	assert(type(resultList) == "table" and type(cbAwardCard) == "table" and type(cbRemainCard) == "table")
    -- set false of HuKind visibility
    self:getChildByName("sp_ZiMo_cy"):setVisible(false)
    self:getChildByName("sp_ZhuangJia"):setVisible(false)
    self:getChildByName("sp_ZiMo_cy"):setVisible(false)
    self:getChildByName("sp_QingYiSe"):setVisible(false)
    self:getChildByName("sp_PiaoHu"):setVisible(false)
    self:getChildByName("sp_QiongHu"):setVisible(false)
    self:getChildByName("sp_ShiSanYao"):setVisible(false)
    self:getChildByName("txt_ShowBaYi"):setVisible(false)
    self:getChildByName("txt_JiaHu"):setVisible(false)
    self:getChildByName("txt_SanJiaBiMen"):setVisible(false)
    self:getChildByName("txt_JinBao"):setVisible(false)
    self:getChildByName("txt_HaiDiLaoYue"):setVisible(false)
    self:getChildByName("txt_GangShangHua"):setVisible(false)
    self:getChildByName("txt_GangShangPao"):setVisible(false)
    self:getChildByName("txt_QiangGangHu"):setVisible(false)

	local width = 44
	local height = 67
	for i = 1, #resultList do
		if resultList[i].cbChHuKind >= GameLogic.WIK_CHI_HU then
			self.winnerIndex = i
			break
		end
	end
	local nBankerOrder = 1
	for i = 1, cmd.GAME_PLAYER do
		local order = self:switchToOrder(i)
		if i <= #resultList then
			self.nodeUser[order]:setVisible(true)
			--头像
			local head = self.nodeUser[order]:getChildByTag(ResultLayer.TAG_HEAD)
			if head then
				head:updateHead(resultList[i].userItem)
			else
				head = PopupInfoHead:createNormal(resultList[i].userItem, 65)
				head:setPosition(0, 2)			--初始位置
				head:enableHeadFrame(false)
				head:enableInfoPop(false)
				head:setTag(ResultLayer.TAG_HEAD)
				self.nodeUser[order]:addChild(head)
			end
			--输赢积分
			local strFile = nil
			if resultList[i].lScore >= 0 then
				strFile = cmd.RES_PATH.."gameResult/num_win.png"
			else
				strFile = cmd.RES_PATH.."gameResult/num_lose.png"
				resultList[i].lScore = -resultList[i].lScore
			end
			local strNum = "/"..resultList[i].lScore --"/"代表“+”或者“-”
			labAtscore = cc.LabelAtlas:_create(strNum, strFile, 21, 27, string.byte("/"))
				:move(930, 0)
				:setAnchorPoint(cc.p(0, 0.5))
				:setTag(ResultLayer.TAG_ASLAB_SCORE)
				:addTo(self.nodeUser[order])
			--昵称
			local textNickname = self.nodeUser[order]:getChildByTag(ResultLayer.TAG_TEXT_NICKNAME)
			textNickname:setString(resultList[i].userItem.szNickName)
			--个人麻将
			local nodeUserCard = self.nodeUser[order]:getChildByTag(ResultLayer.TAG_NODE_CARD)
			local fX = 82
            
            for j = 1, 4 do 
                if #resultList[i].cbBpBgCardData[j] >= 0 then 
                     for k = 1, #resultList[i].cbBpBgCardData[j] do 
                        --牌底
				        local card = display.newSprite(cmd.RES_PATH.."game/font_small/card_down.png")
					        :move(fX, 0)
					        :addTo(nodeUserCard)
                        --字体
				        local nValue = math.mod(resultList[i].cbBpBgCardData[j][k], 16)
				        local nColor = math.floor(resultList[i].cbBpBgCardData[j][k]/16)
				        display.newSprite("game/font_small/font_"..nColor.."_"..nValue..".png")
					        :move(width/2, height/2 + 8)
					        :addTo(card)
                        fX = fX + width
                     end
                     fX = fX + 5
                     --末尾
				     if j == 4 then
					     fX = fX + 10
				     end
                end
            end
           
			for j = 1, #resultList[i].cbCardData do  											 	--剩余手牌
				--牌底
				local card = display.newSprite(cmd.RES_PATH.."game/font_small/card_down.png")
					:move(fX, 0)
					:addTo(nodeUserCard)
				--字体
				local nValue = math.mod(resultList[i].cbCardData[j], 16)
				local nColor = math.floor(resultList[i].cbCardData[j]/16)
				display.newSprite("game/font_small/font_"..nColor.."_"..nValue..".png")
					:move(width/2, height/2 + 8)
					:addTo(card)

				fX = fX + width
			end
			--胡的那张牌
            if math.mod(#resultList[i].cbCardData, 3) < 2 then
			    if resultList[i].cbChHuKind >= GameLogic.WIK_CHI_HU then
				    fX = fX + 20
				    --牌底
				    local huCard = display.newSprite(cmd.RES_PATH.."game/font_small/card_down.png")
					    :move(fX, 0)
					    :addTo(nodeUserCard)
				    --字体
				    local nValue = math.mod(cbHuCard, 16)
				    local nColor = math.floor(cbHuCard/16)
				    display.newSprite("game/font_small/font_"..nColor.."_"..nValue..".png")
					    :move(width/2, height/2 + 8)
					    :addTo(huCard)
			    end
            end

            --闭门
            if math.mod(cbBiMenStatus, 2^i) >= 2^(i-1) then
                fX = fX + 30
                cc.Label:createWithTTF("闭门", "fonts/round_body.ttf", 22)
		            :setTextColor(cc.c4b(192,18,194,255))
		            :setAnchorPoint(cc.p(0.5,0.5))
		            :move(fX, 0)
		            :addTo(nodeUserCard)
            end

            -- 点炮包三家
            if self._scene._scene.cbEnabled_DianPao == true and wProvideUser + 1 == i then
               fX = fX + 60
               cc.Label:createWithTTF("点炮", "fonts/round_body.ttf", 22)
		            :setTextColor(cc.c4b(90,18,194,255))
		            :setAnchorPoint(cc.p(0.5,0.5))
		            :move(fX, 0)
		            :addTo(nodeUserCard)
            end

			--庄家
			if wBankerChairId == resultList[i].userItem.wChairID then
				nBankerOrder = order
			end
		else
			self.nodeUser[order]:setVisible(false)
		end
        -- set true of HuKind visibility
        if math.mod(cbHuKindData, GameLogic.CHR_ZHUANG_JIA*2) >= GameLogic.CHR_ZHUANG_JIA then
            self:getChildByName("sp_ZhuangJia"):setVisible(true)
        end
        if math.mod(cbHuKindData, GameLogic.CHR_ZI_MO*2) >= GameLogic.CHR_ZI_MO then
            self:getChildByName("sp_ZiMo_cy"):setVisible(true)
        end
        if math.mod(cbHuKindData, GameLogic.CHR_QING_YI_SE*2) >= GameLogic.CHR_QING_YI_SE then
            self:getChildByName("sp_QingYiSe"):setVisible(true)
        end
        if math.mod(cbHuKindData, GameLogic.CHR_PIAO_HU*2) >= GameLogic.CHR_PIAO_HU then
            self:getChildByName("sp_PiaoHu"):setVisible(true)
        end
        if math.mod(cbHuKindData, GameLogic.CHR_QIONG_HU*2) >= GameLogic.CHR_QIONG_HU then
            self:getChildByName("sp_QiongHu"):setVisible(true)
        end
        if math.mod(cbHuKindData, GameLogic.CHR_SHI_SAN_YAO*2) >= GameLogic.CHR_SHI_SAN_YAO then
            self:getChildByName("sp_ShiSanYao"):setVisible(true)
        end
        if math.mod(cbHuKindData, GameLogic.CHR_SHOU_BA_YI*2) >= GameLogic.CHR_SHOU_BA_YI then
            self:getChildByName("txt_ShowBaYi"):setVisible(true)
        end
        if math.mod(cbHuKindData, GameLogic.CHR_JIA_HU*2) >= GameLogic.CHR_JIA_HU then
            self:getChildByName("txt_JiaHu"):setVisible(true)
        end
        if math.mod(cbHuKindData, GameLogic.CHR_JIN_BAO*2) >= GameLogic.CHR_JIN_BAO then
            self:getChildByName("txt_JinBao"):setVisible(true)
        end
        if math.mod(cbHuKindData, GameLogic.CHR_FEN_ZHANG*2) >= GameLogic.CHR_FEN_ZHANG then
            self:getChildByName("txt_HaiDiLaoYue"):setVisible(true)
        end
        if math.mod(cbHuKindData, GameLogic.CHR_GANG_SHANG_HUA*2) >= GameLogic.CHR_GANG_SHANG_HUA then
            self:getChildByName("txt_GangShangHua"):setVisible(true)
        end
        if math.mod(cbHuKindData, GameLogic.CHR_GANG_SHANG_PAO*2) >= GameLogic.CHR_GANG_SHANG_PAO then
            self:getChildByName("txt_GangShangPao"):setVisible(true)
        end
        if math.mod(cbHuKindData, GameLogic.CHR_QIANG_GANG_HU*2) >= GameLogic.CHR_QIANG_GANG_HU then
            self:getChildByName("txt_QiangGangHu"):setVisible(true)
        end
        if math.mod(cbHuKindData, GameLogic.CHR_QI_YU*2) >= GameLogic.CHR_QI_YU then
            self:getChildByName("txt_SanJiaBiMen"):setVisible(true)
        end

        -- show HuiPai and BaoPai
        local m_width=98
        local m_height=142
        if self._scene._scene.cbEnabledHuiPai then
            local cardHuiPai=self:getChildByName("card_HuiPai")
            local nValue = math.mod(GameLogic.MAGIC_DATA, 16)
		    local nColor = math.floor(GameLogic.MAGIC_DATA/16)
            if cardHuiPai:getChildByTag(1) then
                cardHuiPai:removeChildByTag(1)
            end
            display.newSprite("game/font_middle/font_"..nColor.."_"..nValue..".png")
					    :move(m_width/2, m_height/2 + 8)
                        :setTag(1)
					    :addTo(cardHuiPai)
                        
        else 
            self:getChildByName("card_HuiPai"):setVisible(false)
            self:getChildByName("sp_HuiPai_30"):setVisible(false)
        end

        if self._scene._scene.cbEnabledBaoPai then
            local valueOfBaoPai = self._scene._scene.cbBaoPai
            local cardBaoPai = self:getChildByName("card_BaoPai")
            local nValue = math.mod(valueOfBaoPai, 16)
		    local nColor = math.floor(valueOfBaoPai/16)
            if cardBaoPai:getChildByTag(1) then
                cardBaoPai:removeChildByTag(1)
            end
            display.newSprite("game/font_middle/font_"..nColor.."_"..nValue..".png")
					    :move(m_width/2, m_height/2 + 8)
                        :setTag(1)
					    :addTo(cardBaoPai)
        else 
            self:getChildByName("card_BaoPai"):setVisible(false)
            self:getChildByName("sp_BaoPai_31"):setVisible(false)
        end
	end

	--庄家
	self:setBanker(nBankerOrder)

	self.bShield = true
	self:setVisible(true)
	self:setLocalZOrder(yl.MAX_INT)
end

function ResultLayer:hideLayer()
	if not self:isVisible() then
		return
	end
	self:onResetData()
	self:setVisible(false)
	self._scene.btStart:setVisible(true)
end

--1~4转换到1~4
function ResultLayer:switchToOrder(index)
	assert(index >=1 and index <= cmd.GAME_PLAYER)
	if self.winnerIndex == nil then
		return index
	end
	local nDifference = ResultLayer.WINNER_ORDER - self.winnerIndex - 1
	local order = math.mod(index + nDifference, cmd.GAME_PLAYER) + 1
	return order
end

function ResultLayer:setBanker(order)
	assert(order ~= 0)
	self.spBanker:move(posBanker[order])
	self.spBanker:setVisible(true)
end

function ResultLayer:recodeShow()
	print("战绩炫耀")
	if not PriRoom then
		return
	end

    PriRoom:getInstance():getPlazaScene():popTargetShare(function(target, bMyFriend)
        bMyFriend = bMyFriend or false
        local function sharecall( isok )
            if type(isok) == "string" and isok == "true" then
                showToast(self, "战绩炫耀成功", 2)
            end
        end
        local url = GlobalUserItem.szWXSpreaderURL or yl.HTTP_URL
        -- 截图分享
        local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
        local area = cc.rect(0, 0, framesize.width, framesize.height)
        local imagename = "grade_share.jpg"
        if bMyFriend then
            imagename = "grade_share_" .. os.time() .. ".jpg"
        end
        ExternalFun.popupTouchFilter(0, false)
        captureScreenWithArea(area, imagename, function(ok, savepath)
            ExternalFun.dismissTouchFilter()
            if ok then
                if bMyFriend then
                    PriRoom:getInstance():getTagLayer(PriRoom.LAYTAG.LAYER_FRIENDLIST, function( frienddata )
                        PriRoom:getInstance():imageShareToFriend(frienddata, savepath, "分享我的战绩")
                    end)
                elseif nil ~= target then
                    MultiPlatform:getInstance():shareToTarget(target, sharecall, "我的战绩", "分享我的战绩", url, savepath, "true")
                end            
            end
        end)
    end)
end

return ResultLayer