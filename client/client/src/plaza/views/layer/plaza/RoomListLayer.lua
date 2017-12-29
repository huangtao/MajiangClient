local RoomListLayer = class("RoomListLayer", function(scene)
	local roomlist_layer = display.newLayer()
    return roomlist_layer
end)

RoomListLayer.BT_EXIT			= 1
RoomListLayer.BT_PRIROOM        = 2

-- 进入场景而且过渡动画结束时候触发。
function RoomListLayer:onEnterTransitionFinish()
--	self._listView:reloadData()
    return self
end
-- 退出场景而且开始过渡动画时候触发。
function RoomListLayer:onExitTransitionStart()
    return self
end
function RoomListLayer:onSceneAniFinish()
end


function RoomListLayer:ctor(scene, isQuickStart)
	self._scene = scene
	local this = self
	self.m_bIsQuickStart = isQuickStart or false

	local enterGame = self._scene:getEnterGameInfo()
	--缓存资源
	local modulestr = string.gsub(enterGame._KindName, "%.", "/")
	local path = "game/" .. modulestr .. "res/roomlist/roomlist.plist"	
	if false == cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded(path) then
		if cc.FileUtils:getInstance():isFileExist(path) then
			cc.SpriteFrameCache:getInstance():addSpriteFrames(path)
		end
	end
    

    local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

	self.m_fThree = yl.WIDTH / 3

    self.m_tabRoomListInfo = {}
	for k,v in pairs(GlobalUserItem.roomlist) do
		if tonumber(v[1]) == GlobalUserItem.nCurGameKind then
			local listinfo = v[2]
			if type(listinfo) ~= "table" then
				break
			end
			local normalList = {}
			for k,v in pairs(listinfo) do
				if v.wServerType ~= yl.GAME_GENRE_PERSONAL then
					table.insert( normalList, v)
				end
			end
			self.m_tabRoomListInfo = normalList
			break
		end
	end	

    self._scrollview = nil

    --列表数据
    local room_count = #self.m_tabRoomListInfo  --游戏数量
    local column = 2     --列
    local line = math.ceil(room_count/column)  --行
    
    local spacing = 40      --间距
    local margin = 20       --边距

    local cellsize = self:cellSizeForTable() -- 控件大小
    local Inner_width = cellsize.width*column + spacing*(column-1) + margin*2 --内容宽
    local Inner_height = cellsize.height*line + spacing*(line-1) + margin*2 --内容高
    local scroll_width = cellsize.width*column + spacing*(column-1) + margin*2 --视图宽
    local scroll_height = 600--cellsize.height*line + spacing*(line-1) + margin*2 --视图高

    if Inner_height < scroll_height then
        Inner_height = scroll_height
    end


    --游戏列表（多行）
    self._scrollview=ccui.ScrollView:create()  
    self._scrollview:setTouchEnabled(true) 
    self._scrollview:setBounceEnabled(false) --这句必须要不然就不会滚动噢
    self._scrollview:setScrollBarEnabled(false)
    self._scrollview:setDirection(ccui.ScrollViewDir.vertical) --设置滚动的方向 
    self._scrollview:setContentSize(cc.size(scroll_width,scroll_height)) --设置尺寸 
    self._scrollview:setInnerContainerSize(cc.size(Inner_width,Inner_height))
    self._scrollview:setAnchorPoint(cc.p(0.5,0.5)) 
    self._scrollview:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2-15))
    self._scrollview:addTo(self)



    --返回
	ccui.Button:create("RoomList/bt_close_1.png","RoomList/bt_close_2.png")
    	:move(60,yl.HEIGHT-51)
    	:setTag(RoomListLayer.BT_EXIT)
    	:addTo(self)
    	:addTouchEventListener(btcallback)

        
    local btPriRoom = ccui.Button:create("RoomList/icon_roomlist_frame_friend.png","RoomList/icon_roomlist_frame_friend.png")
    	btPriRoom:move(1250,yl.HEIGHT-51)
    	btPriRoom:setTag(RoomListLayer.BT_PRIROOM)
    	btPriRoom:addTo(self)
    	btPriRoom:addTouchEventListener(btcallback)
    self._btPriRoom = btPriRoom


    cc.Label:createWithTTF("朋友场", "fonts/round_body.ttf", 40)
        :setPosition(cc.p(self.m_fThree * 0.5-135,110))
		:setTextColor(cc.c4b(131,92,8,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:addTo(self._btPriRoom)

    --底注
    cc.Label:createWithTTF("（基数0）", "fonts/round_body.ttf", 28)
        :setPosition(cc.p(self.m_fThree * 0.5 - 70,105))
		:setTextColor(cc.c4b(131,92,8,255))
		:setAnchorPoint(cc.p(0.0,0.5))
		:addTo(self._btPriRoom)

    --限制
    display.newSprite("RoomList/text_roomlist_cellscore.png")
			:setPosition(cc.p(self.m_fThree * 0.5 - 160,40))
			:setAnchorPoint(cc.p(1.0,0.5))
			:addTo(self._btPriRoom)
    cc.Label:createWithTTF("1万准入", "fonts/round_body.ttf", 36)
        :setPosition(cc.p(self.m_fThree * 0.5 - 150,40))
		:setTextColor(cc.c4b(255,131,131,255))
		:setAnchorPoint(cc.p(0.0,0.5))
		:addTo(self._btPriRoom)



    self:onUpdateShowList(Inner_width, Inner_height,spacing,margin,column,line)

	--区域设置
	self:setContentSize(yl.WIDTH,yl.HEIGHT)

	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			this:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			this:onExitTransitionStart()
		end
	end)

	if true == self.m_bIsQuickStart then
		self:stopAllActions()
		GlobalUserItem.nCurRoomIndex = 1
		self:onStartGame()
	end


end

--更新当前显示
function RoomListLayer:onUpdateShowList(width, height,spacing,margin,column,line)
    if self.m_tabRoomListInfo ~= nil then
        local count = #self.m_tabRoomListInfo

        if line == 0 then
            line = 1
        end
        if column == 0 then
            column = 1
        end

        local cellsize = self:cellSizeForTable();
        local cell_width = nil
        local cell_height = nil

        self._showList = nil
        self._showList = {}

 	    for i=1,count+1 do

            if ccui.ScrollViewDir.vertical == self._scrollview:getDirection() then
                cell_width = math.floor((i-1)%column)*(cellsize.width+spacing) + cellsize.width/2 + margin
                cell_height = math.floor((i-1)/column)*(cellsize.height+spacing) + cellsize.height/2 + margin
            else
                cell_width = math.floor((i-1)/column)*(cellsize.width+spacing) + cellsize.width/2 + margin
                cell_height = math.floor((i-1)%column)*(cellsize.height+spacing) + cellsize.height/2 + margin
            end

            if i == 1 then
                local pos = self._scrollview:convertToWorldSpace(cc.p(cell_width,height-cell_height))
                self._btPriRoom:move(pos.x, pos.y)
            else
                local iRoomIndex = i-1
                self._showList[iRoomIndex] = self:tableCellAtIndex(iRoomIndex)
                self._showList[iRoomIndex]:move(cell_width, height-cell_height)
                self._showList[iRoomIndex]:addTo(self._scrollview)
            end
	    end
             
    end
end

function RoomListLayer.cellHightLight(view,cell)

end

function RoomListLayer.cellUnHightLight(view,cell)

end

--子视图大小
function RoomListLayer:cellSizeForTable()
  	return cc.size(583 , 143)
end

--子视图数目
function RoomListLayer:numberOfCellsInTableView(view)
	return #self.m_tabRoomListInfo
end

function RoomListLayer:tableCellTouched(view, cell)
    local index = cell:getTag() 
    local roomlistLayer = view:getParent()

	local roominfo = roomlistLayer.m_tabRoomListInfo[index]
	if not roominfo then
		return
	end

	GlobalUserItem.nCurRoomIndex = roominfo._nRoomIndex
	GlobalUserItem.bPrivateRoom = (roominfo.wServerType == yl.GAME_GENRE_PERSONAL)
	if view:getParent()._scene:roomEnterCheck() then
		view:getParent():onStartGame()
	end	
end


--获取子视图
function RoomListLayer:tableCellAtIndex(idx)
    local cell = nil
    if self._showList ~= nil then
        cell = self._showList[idx]
    end

	local iteminfo = self.m_tabRoomListInfo[idx]
    
    --背景
    local filestr = "RoomList/icon_roomlist_frame.png"
    local filestr_frame = cc.Sprite:create(filestr)

    if not cell then
        cell = ccui.Button:create(filestr,filestr)
        cell:setContentSize(self:cellSizeForTable())
			:setSwallowTouches(false)
			:setName(iteminfo.szServerName)
    else
        cell:setTexture(filestr)
    end
    cell:removeAllChildren()


	local wLv = (iteminfo == nil and 0 or iteminfo.wServerLevel)	
	if 8 == wLv then
		--比赛场单独处理
	else
		local rule = (iteminfo == nil and 0 or iteminfo.dwServerRule)
		wLv = (bit:_and(yl.SR_ALLOW_AVERT_CHEAT_MODE, rule) ~= 0) and 10 or iteminfo.wServerLevel
		wLv = (wLv ~= 0) and wLv or 1
		local wRoom = math.mod(wLv, 3)--bit:_and(wLv, 3)
		local szName = (iteminfo == nil and "房间名称" or iteminfo.szServerName)
		local szCount = (iteminfo == nil and "0" or(iteminfo.dwOnLineCount..""))
		local szServerScore = (iteminfo == nil and "0" or iteminfo.lCellScore)
		local enterGame = self._scene:getEnterGameInfo()

		--检查房间背景资源
		local modulestr = string.gsub(enterGame._KindName, "%.", "/")
		local path = "game/" .. modulestr .. "res/roomlist/icon_roomlist_" .. wRoom .. ".png"
		local framename = enterGame._KindID .. "_icon_roomlist_" .. wRoom .. ".png"
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framename)
--		if nil ~= frame then
--			local sp = cc.Sprite:createWithSpriteFrame(frame)
--			sp:setPosition(cc.p(self.m_fThree * 0.5, filestr_frame:getContentSize().height * 0.5 + 10))
--			cell:addChild(sp)
--		elseif cc.FileUtils:getInstance():isFileExist(path) then
--			--房间类型
--			display.newSprite(path)
--				:setPosition(cc.p(self.m_fThree * 0.5, filestr_frame:getContentSize().height * 0.5 + 10))
--				:addTo(cell)
--		end

		--背景
		--cell:setTexture("RoomList/icon_roomlist_frame.png")

        local roomType = "新手场"
        if wLv == 1 then
            roomType = "新手场"
        elseif wLv == 2 then
            roomType = "初级场"
        elseif wLv == 3 then
            roomType = "中级场"
        elseif wLv == 4 then
            roomType = "高级场"
        elseif wLv == 5 then
            roomType = "土豪场"
        end

        cc.Label:createWithTTF(roomType, "fonts/round_body.ttf", 40)
            :setPosition(cc.p(self.m_fThree * 0.5-135,110))
		    :setTextColor(cc.c4b(131,92,8,255))
		    :setAnchorPoint(cc.p(0.5,0.5))
		    :addTo(cell)


        --底注
        cc.Label:createWithTTF("（基数"..szServerScore.."）", "fonts/round_body.ttf", 28)
            :setPosition(cc.p(self.m_fThree * 0.5 - 70,105))
		    :setTextColor(cc.c4b(131,92,8,255))
		    :setAnchorPoint(cc.p(0.0,0.5))
		    :addTo(cell)

        --限制
        display.newSprite("RoomList/text_roomlist_cellscore.png")
			    :setPosition(cc.p(self.m_fThree * 0.5 - 160,40))
			    :setAnchorPoint(cc.p(1.0,0.5))
			    :addTo(cell)
        cc.Label:createWithTTF("1万准入", "fonts/round_body.ttf", 36)
            :setPosition(cc.p(self.m_fThree * 0.5 - 150,40))
		    :setTextColor(cc.c4b(255,131,131,255))
		    :setAnchorPoint(cc.p(0.0,0.5))
		    :addTo(cell)


		--房间类型
--		framename = enterGame._KindID .. "_title_icon_" .. wLv .. ".png"
--		frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framename)
--		path = "game/" .. modulestr .. "res/roomlist/title_icon_" .. wLv .. ".png"
--		if nil ~= frame then
--			local sp = cc.Sprite:createWithSpriteFrame(frame)
--			sp:setPosition(cc.p(self.m_fThree * 0.5-145,110))
--			cell:addChild(sp)
--		elseif cc.FileUtils:getInstance():isFileExist(path) then		
--			display.newSprite(path)
--				:setPosition(cc.p(self.m_fThree * 0.5-145,110))
--				:addTo(cell)
--		else
--			local default = "RoomList/title_icon_" .. wLv .. ".png"
--			if cc.FileUtils:getInstance():isFileExist(default) then
--				--默认资源
--				display.newSprite(default)
--					:setPosition(cc.p(self.m_fThree * 0.5-145,110))
--					:addTo(cell)
--			end			
--		end


--		cc.LabelAtlas:_create(szServerScore, "RoomList/num_roomlist_cellscore.png", 14, 19, string.byte("0")) 
--			:move(self.m_fThree * 0.5 - 150,40)
--			:setAnchorPoint(cc.p(0,0.5))
--			:addTo(cell)


	end


    local btCallBack = function (ref,type)
        self:tableCellTouched(self._scrollview,ref)
	end

	cell:setVisible(true)
	cell:setTag(idx)
    cell:addTouchEventListener(btCallBack)

	return cell
end

--显示等待
function RoomListLayer:showPopWait()
	if self._scene then
		self._scene:showPopWait()
	end
end

--关闭等待
function RoomListLayer:dismissPopWait()
	if self._scene then
		self._scene:dismissPopWait()
	end
end


function RoomListLayer:onStartGame(index)
	local iteminfo = GlobalUserItem.GetRoomInfo(index)
	if iteminfo ~= nil then
		self._scene:onStartGame(index)
	end
end

--按键监听
function RoomListLayer:onButtonClickedEvent(tag,sender)
	if tag == RoomListLayer.BT_EXIT then
		self._scene:onKeyBack()
    elseif tag == RoomListLayer.BT_PRIROOM then
        self._scene:onChangeShowMode(PriRoom.LAYTAG.LAYER_ROOMLIST)
	end
end

return RoomListLayer