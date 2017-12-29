--[[
	询问对话框
		2016_04_27 C.P
	功能：确定/取消 对话框 与用户交互
]]
local ExitQueryDialog = class("ExitQueryDialog", function(msg,callback)
		local exitQueryDialog = display.newLayer()
    return exitQueryDialog
end)

--默认字体大小
ExitQueryDialog.DEF_TEXT_SIZE 	= 32

--UI标识
ExitQueryDialog.DG_QUERY_EXIT 	=  2 
ExitQueryDialog.BT_CANCEL		=  0   
ExitQueryDialog.BT_CONFIRM		=  1

-- 对话框类型
ExitQueryDialog.QUERY_SURE 			= 1
ExitQueryDialog.QUERY_SURE_CANCEL 	= 2

ExitQueryDialog.QUERY_AGREE 	    = 1
ExitQueryDialog.QUERY_REFUSE 	    = 0

-- 进入场景而且过渡动画结束时候触发。
function ExitQueryDialog:onEnterTransitionFinish()
    return self
end

-- 退出场景而且开始过渡动画时候触发。
function ExitQueryDialog:onExitTransitionStart()
	self:unregisterScriptTouchHandler()
    return self
end

--窗外触碰
function ExitQueryDialog:setCanTouchOutside(canTouchOutside)
	self._canTouchOutside = canTouchOutside
	return self
end

--msg 显示信息
--callback 交互回调
--txtsize 字体大小
function ExitQueryDialog:ctor(msg, callback, txtsize, queryType,queryShow,userData)

    if queryType ~= 1 then 
        queryType = ExitQueryDialog.QUERY_SURE_CANCEL
    end 
    --queryType = queryType or ExitQueryDialog.QUERY_SURE_CANCEL
	self._callback = callback
	self._canTouchOutside = true
    local this = self 
    self:setContentSize(appdf.WIDTH,appdf.HEIGHT)
    self:move(0,appdf.HEIGHT)
    --回调函数
	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			this:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			this:onExitTransitionStart()
		end
	end)
    --按键监听
	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end
    --区域外取消显示
	local  onQueryExitTouch = function(eventType, x, y)
		if not self._canTouchOutside then
			return true
		end

		if self._dismiss == true then
			return true
		end

		if eventType == "began" then
			local rect = this:getChildByTag(ExitQueryDialog.DG_QUERY_EXIT):getBoundingBox()
        	if cc.rectContainsPoint(rect,cc.p(x,y)) == false then
        		--self:dismiss()
    		end
		end
    	return true
    end
	self:setTouchEnabled(true)
	self:registerScriptTouchHandler(onQueryExitTouch)
    local querDialog1 = cc.CSLoader:createNode("dissolv2/dissolv2.csb")
    self:addChild(querDialog1)
    local btn = querDialog1:getChildByName("btn_close")
    btn:setTag(ExitQueryDialog.BT_CANCEL)
    btn:addTouchEventListener(btcallback)
    btn:setVisible(false)

   
    self.m_btnAgree = querDialog1:getChildByName("btn_agree")
    self.m_btnAgree:setTag(ExitQueryDialog.BT_CONFIRM)
    self.m_btnAgree:addTouchEventListener(btcallback)

    self.m_btnRefuse = querDialog1:getChildByName("btn_refuse")
    self.m_btnRefuse:setTag(ExitQueryDialog.BT_CANCEL)
    self.m_btnRefuse:addTouchEventListener(btcallback)

    cc.Label:createWithTTF(msg, "fonts/round_body.ttf", not txtsize and ExitQueryDialog.DEF_TEXT_SIZE or txtsize)
		:setTextColor(cc.c4b(96,52,2,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:setDimensions(600,180)
		:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:move(appdf.WIDTH*0.3 ,470)
		:addTo(self)
     cc.Label:createWithTTF("申请解散房间，是否同意？", "fonts/round_body.ttf", not txtsize and ExitQueryDialog.DEF_TEXT_SIZE or txtsize)
		:setTextColor(cc.c4b(75,245,47,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:setDimensions(600,180)
		:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:move(appdf.WIDTH*0.6 ,470)
		:addTo(self)
    local tabData = {}
    local number = 1
    for i= 1,#userData do   
        if msg ~= userData[i].szNickName then 
            tabData[number] = userData[i]
            number = number + 1
        end            
    end 
    self.m_txtName = {}
    self.m_txtState = {}
    self.m_txtdata = {}
    for i= 1,#tabData do 
        self.m_txtdata[i] = {}
        self.m_txtdata[i].name = tabData[i].szNickName
--        self.m_txtdata[i].id = tabData[i].dwGameID
        self.m_txtdata[i].id = tabData[i].dwUserID
        self.m_txtName[i] = cc.Label:createWithTTF(tabData[i].szNickName, "fonts/round_body.ttf", not txtsize and ExitQueryDialog.DEF_TEXT_SIZE or txtsize)
		self.m_txtName[i]:setTextColor(cc.c4b(96,52,2,255))
		self.m_txtName[i]:setAnchorPoint(cc.p(0.5,0.5))
		self.m_txtName[i]:setDimensions(600,180)
		self.m_txtName[i]:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		self.m_txtName[i]:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		self.m_txtName[i]:move(appdf.WIDTH*0.3 ,470 - (i*50))
		self.m_txtName[i]:addTo(self,2)

        self.m_txtState[i] = cc.Label:createWithTTF("等待选择", "fonts/round_body.ttf", not txtsize and ExitQueryDialog.DEF_TEXT_SIZE or txtsize)
		self.m_txtState[i]:setTextColor(cc.c4b(75,245,47,255))
		self.m_txtState[i]:setAnchorPoint(cc.p(0.5,0.5))
		self.m_txtState[i]:setDimensions(600,180)
		self.m_txtState[i]:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		self.m_txtState[i]:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		self.m_txtState[i]:move(appdf.WIDTH*0.6 ,470 - (i*50))
		self.m_txtState[i]:addTo(self,2)
    end 
	self._dismiss  = false
	self:runAction(cc.MoveTo:create(0.3,cc.p(0,0)))
end

--按键点击
function ExitQueryDialog:UpdateUserState(id,state)
    local number = 1
    for i = 1 ,#self.m_txtdata do 
        number = i
	    if self.m_txtdata[i].id == id then 
            break
        end 
        
    end 
    if self.m_txtState[number] then
      if ExitQueryDialog.QUERY_REFUSE == state then 
        self.m_txtState[number]:setString("拒绝")
        self.m_txtState[number]:setTextColor(cc.c4b(255,36,36,255))
      elseif ExitQueryDialog.QUERY_AGREE == state then 
        self.m_txtState[number]:setString("同意")
        self.m_txtState[number]:setTextColor(cc.c4b(75,245,47,255))
      else
        self.m_txtState[number]:setString("等待选择")
        self.m_txtState[number]:setTextColor(cc.c4b(75,245,47,255))
      end 
    end
end
function ExitQueryDialog:setSelf(id,state)
    self.m_btnRefuse:setVisible(false)
    self.m_btnAgree:setVisible(false)
end



--按键点击
function ExitQueryDialog:onButtonClickedEvent(tag,ref)
	if self._dismiss == true then
		return
	end
    self:setSelf()
	--取消显示
	--self:dismiss()
	--通知回调
	if self._callback then
		self._callback(tag == ExitQueryDialog.BT_CONFIRM)
	end
end

--取消消失
function ExitQueryDialog:dismiss()
	self._dismiss = true
	local this = self
	self:stopAllActions()
	self:runAction(
		cc.Sequence:create(
			cc.MoveTo:create(0.3,cc.p(0,appdf.HEIGHT)),
			cc.CallFunc:create(function()
					this:removeSelf()
				end)
			))	
end
--取消清空
function ExitQueryDialog:dismiss2()
	self._dismiss = true
	local this = self
	self:stopAllActions()
    this:removeSelf()

end

return ExitQueryDialog
