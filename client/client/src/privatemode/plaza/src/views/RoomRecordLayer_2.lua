--
-- Author: zhong
-- Date: 2016-12-17 10:32:26
--
-- 房间记录界面

local RoomRecordLayer_2 = class("RoomRecordLayer_2", function(scene)
		local RoomRecordLayer_2 = display.newLayer(cc.c4b(56, 56, 56, 56))
    return RoomRecordLayer_2
end)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")
local RoomDetailLayer = appdf.req(PriRoom.MODULE.PLAZAMODULE .. "views.RoomDetailLayer")
local cmd_private = appdf.req(PriRoom.MODULE.PRIHEADER .. "CMD_Private")

local ROOMDETAIL_NAME = "__pri_room_detail_layer_name__"
function RoomRecordLayer_2:ctor( scene )
    ExternalFun.registerNodeEvent(self)

    self.scene = scene
    -- 加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("room/RecordLayer_2.csb", self)

    local cbtlistener = function (sender,eventType)
        self:onSelectedEvent(sender:getTag(),sender,eventType)
    end
    -- 切换按钮
    self.m_checkSwitch = csbNode:getChildByName("check_switchrec")
    self.m_checkSwitch:setSelected(false)
    self.m_checkSwitch:addEventListener(cbtlistener)

    -- 创建记录
    self.m_layCreateRec = csbNode:getChildByName("lay_create")
    self.m_layCreateRec:setVisible(false)
    self.m_creCreateTime = self.m_layCreateRec:getChildByName("pri_sp_createtime")
    self.m_creRoomID = self.m_layCreateRec:getChildByName("pri_sp_roomid")
    self.m_creRoomLimit = self.m_layCreateRec:getChildByName("pri_sp_roomlimit")
    self.m_creCost = self.m_layCreateRec:getChildByName("pri_sp_createcost")
    self.m_creDisTime = self.m_layCreateRec:getChildByName("pri_sp_dissolvetime")
    self.m_creAward = self.m_layCreateRec:getChildByName("pri_sp_award")
    self.m_creStatus = self.m_layCreateRec:getChildByName("pri_sp_roomstatus")

    -- 参与记录
    self.m_layJoinRec = csbNode:getChildByName("lay_join")
    self.m_layJoinRec:setVisible(true)
    self.m_joinCreateTime = self.m_layJoinRec:getChildByName("pri_sp_createtime")
    self.m_joinRoomID = self.m_layJoinRec:getChildByName("pri_sp_roomid")
    self.m_joinCreateUser = self.m_layJoinRec:getChildByName("pri_sp_createuser")
    self.m_joinUinfo = self.m_layJoinRec:getChildByName("pri_sp_uinfo")
    self.m_joinDisTime = self.m_layJoinRec:getChildByName("pri_sp_dissolvetime")

    --底框

    local content = csbNode:getChildByName("lay_content")
    -- 列表
    local m_tableView = cc.TableView:create(content:getContentSize())
    m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    m_tableView:setPosition(content:getPosition())
    m_tableView:setDelegate()
    m_tableView:registerScriptHandler(self.cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    m_tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    m_tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    csbNode:addChild(m_tableView)
    self.m_tableView = m_tableView
    content:removeFromParent()
    --退出
    self._btnBack = csbNode:getChildByName("pri_btn_back")
    self._btnBack:addTouchEventListener(function(ref, type)
       		 	if type == ccui.TouchEventType.ended then
					self.scene:onKeyBack()
				end
			end)

    -- 房间信息
    self.m_layRoomDetail = nil
end

function RoomRecordLayer_2:onSelectedEvent( tag,sender,eventType )
    local sel = sender:isSelected()
    --self.m_layCreateRec:setVisible(sel)
    --self.m_layJoinRec:setVisible(not sel)
    self.m_layJoinRec:setVisible(false)
    self.m_layCreateRec:setVisible(false)

    if not sel and 0 == #(PriRoom:getInstance().m_tabJoinRecord) then
        PriRoom:getInstance():showPopWait()
        PriRoom:getInstance():getNetFrame():onQueryJoinList()
        return
    end
    self.m_tableView:reloadData()
end

function RoomRecordLayer_2:onEnterTransitionFinish()
    PriRoom:getInstance():showPopWait()
    -- 请求记录列表
   -- PriRoom:getInstance():getNetFrame():onQueryRoomList()
    PriRoom:getInstance():getNetFrame():onQueryJoinList()
end

function RoomRecordLayer_2:onExit()
    -- 清除缓存
    PriRoom:getInstance().m_tabJoinRecord = {}
    PriRoom:getInstance().m_tabCreateRecord = {}
end

function RoomRecordLayer_2:onReloadRecordList()
    self.m_tableView:reloadData()
    local rd = self:getChildByName(ROOMDETAIL_NAME)
    if nil ~= rd then
        rd:hide()
    end
end

function RoomRecordLayer_2.cellSizeForTable( view, idx )
    return yl.WIDTH*0.75,90
end

function RoomRecordLayer_2:numberOfCellsInTableView( view )
    if self.m_checkSwitch:isSelected() then
        return #(PriRoom:getInstance().m_tabCreateRecord)
    else
        return #(PriRoom:getInstance().m_tabJoinRecord)
    end
end

function RoomRecordLayer_2:tableCellAtIndex( view, idx )
    local cell = view:dequeueCell()
    if not cell then        
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end

    if self.m_checkSwitch:isSelected() then
        local tabData = PriRoom:getInstance().m_tabCreateRecord[idx + 1]
        local item = self:createRecordItem(tabData)
        item:setPosition(view:getViewSize().width * 0.5, 25)
        cell:addChild(item)
    else
        local tabData = PriRoom:getInstance().m_tabJoinRecord[idx + 1]
        local item = self:joinRecordItem(tabData)
        item:setPosition(view:getViewSize().width * 0.5, 25)
        cell:addChild(item)
    end

    return cell
end

-- 创建记录
function RoomRecordLayer_2:createRecordItem( tabData )
    --tabData = tagPersonalRoomInfo
    local item = ccui.Widget:create()
    --item:setContentSize(cc.size(1130, 50))
    item:setContentSize(cc.size(yl.WIDTH*0.76, 74))
    
    -- 线
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("pri_sp_listline.png")
    if nil ~= frame then
        local sp = cc.Sprite:createWithSpriteFrame(frame)
        item:addChild(sp)
        sp:setPosition(yl.WIDTH*0.76*0.5, 74*0.56)
    end
    
    -- 创建时间
    local tabTime = tabData.sysCreateTime
    local strTime = string.format("%d-%02d-%02d %02d:%02d:%02d", tabTime.wYear, tabTime.wMonth, tabTime.wDay, tabTime.wHour, tabTime.wMinute, tabTime.wSecond)
    local createtime = cc.Label:createWithTTF(strTime,"fonts/yehe_body.TTF",28)
    --createtime:setTextColor(cc.c3b(244,237,182))
    createtime:setTextColor(cc.c3b(106,60,11))
    item:addChild(createtime)
    createtime:setPosition(self.m_creCreateTime:getPositionX()+15, 25)

    -- 房间ID
    local roomid = cc.Label:createWithTTF(tabData.szRoomID,"fonts/yehe_body.TTF",28)
    --roomid:setTextColor(cc.c3b(244,237,182))
    roomid:setTextColor(cc.c3b(106,60,11))
    item:addChild(roomid)
    roomid:setPosition(self.m_creRoomID:getPositionX()-15, 25)

    -- 房间限制
    local roomlimit = cc.Label:createWithTTF(tabData.dwPlayTurnCount .. "","fonts/yehe_body.TTF",28)
    --roomlimit:setTextColor(cc.c3b(244,237,182))
    roomlimit:setTextColor(cc.c3b(106,60,11))
    item:addChild(roomlimit)
    roomlimit:setPosition(self.m_creRoomLimit:getPositionX(), 25)

    local feeType = "房卡"
    if tabData.cbCardOrBean == 0 then
        feeType = "蓝钻"
    end
    -- 创建消耗
    local cost = cc.Label:createWithTTF(tabData.lFeeCardOrBeanCount .. feeType,"fonts/yehe_body.TTF",28)    
    cost:setTextColor(cc.c3b(106,60,11))
    item:addChild(cost)
    cost:setPosition(self.m_creCost:getPositionX(), 25)

    -- 奖励
    local award = cc.Label:createWithTTF(tabData.lScore .. "游戏币","fonts/yehe_body.TTF",28)
    award:setTextColor(cc.c3b(106,60,11))
    item:addChild(award)
    award:setPosition(self.m_creAward:getPositionX()+10, 25)

    -- 房间状态
    local bOnGame = false
    local status = cc.Label:createWithTTF("","fonts/yehe_body.TTF",28)
    if tabData.cbIsDisssumRoom == 1 then -- 解散
        status:setTextColor(cc.c3b(106,60,11))
        status:setString("已解散")
        tabTime = tabData.sysDissumeTime
        strTime = string.format("%d-%02d-%02d %02d:%02d:%02d", tabTime.wYear, tabTime.wMonth, tabTime.wDay, tabTime.wHour, tabTime.wMinute, tabTime.wSecond)
    else -- 游戏中
        status:setTextColor(cc.c3b(106,60,11))
        status:setString("游戏中")
        bOnGame = true
        strTime = ""
    end    
    item:addChild(status)
    status:setPosition(self.m_creStatus:getPositionX(), 25)

    -- 解散时间    
    local distime = cc.Label:createWithTTF(strTime,"fonts/yehe_body.TTF",28)
    distime:setTextColor(cc.c3b(106,60,11))
    item:addChild(distime)
    distime:setPosition(self.m_creDisTime:getPositionX(), 25)

    item:setTouchEnabled(true)
    item:setSwallowTouches(false)
    local itemFunC = function(ref, tType)
        if tType == ccui.TouchEventType.ended then
            local tabDetail = tabData
            tabDetail.onGame = bOnGame
            tabDetail.enableDismiss = true
            local rd = RoomDetailLayer:create(tabDetail)
            rd:setName(ROOMDETAIL_NAME)
            self:addChild(rd)
        end
    end
    item:addTouchEventListener( itemFunC )
    return item
end

-- 参与记录
function RoomRecordLayer_2:joinRecordItem( tabData )
    --tabData = tagQueryPersonalRoomUserScore
    local item = ccui.Widget:create()
    --item:setContentSize(cc.size(1130, 50))
    item:setContentSize(cc.size(1140, 52))

    -- 线
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("pri_sp_listline.png")
    if nil ~= frame then
        local sp = cc.Sprite:createWithSpriteFrame(frame)
        item:addChild(sp)
        sp:setPosition(570, 45)
    end
    -- 创建时间
    local tabTime = tabData.sysCreateTime
   -- local strTime = string.format("%d-%02d-%02d %02d:%02d:%02d", tabTime.wYear, tabTime.wMonth, tabTime.wDay, tabTime.wHour, tabTime.wMinute, tabTime.wSecond)
    local strTime1 = string.format("%d-%02d-%02d", tabTime.wYear, tabTime.wMonth, tabTime.wDay)
    local strTime2 = string.format("%02d:%02d:%02d",tabTime.wHour, tabTime.wMinute, tabTime.wSecond)
    local createtime1 = cc.Label:createWithTTF(strTime1,"fonts/yehe_body.TTF",25)
    local createtime2 = cc.Label:createWithTTF(strTime2,"fonts/yehe_body.TTF",25)
    createtime1:setTextColor(cc.c3b(108,53,21))
    createtime2:setTextColor(cc.c3b(108,53,21))
    item:addChild(createtime1)
    item:addChild(createtime2)
    createtime1:setPosition(self.m_creCreateTime:getPositionX()-45, 50)
    createtime2:setPosition(self.m_creCreateTime:getPositionX()-45, 25)

    -- 房间ID
    local roomid = cc.Label:createWithTTF(tabData.szRoomID,"fonts/yehe_body.TTF",25)
    roomid:setTextColor(cc.c3b(108,53,21))
    item:addChild(roomid)
    roomid:setPosition(self.m_joinRoomID:getPositionX()+85, 38)

    -- 创建玩家
    local createusr = ClipText:createClipText(cc.size(120, 30), tabData.szUserNicname, "fonts/yehe_body.TTF", 25)
    createusr:setAnchorPoint(cc.p(0.5, 0.5))
    createusr:setTextColor(cc.c4b(108,53,21))
    item:addChild(createusr)
    createusr:setPosition(self.m_joinCreateUser:getPositionX()+85, 38)

    local scorestr = "+" .. tabData.lScore
    if tabData.lScore < 0 then
        scorestr = "" .. tabData.lScore
    end
    if tabData.bFlagOnGame then
        scorestr = ""
    end
    -- 个人战绩
    local uinfo = ClipText:createClipText(cc.size(150, 30), scorestr, "fonts/yehe_body.TTF", 25)
    uinfo:setAnchorPoint(cc.p(0.5, 0.5))
    uinfo:setTextColor(cc.c4b(217,51,6))
    item:addChild(uinfo)
    uinfo:setPosition(self.m_joinUinfo:getPositionX()+75, 38)

    -- 解散时间
    tabTime = tabData.sysDissumeTime
   -- strTime = string.format("%d-%02d-%02d %02d:%02d:%02d", tabTime.wYear, tabTime.wMonth, tabTime.wDay, tabTime.wHour, tabTime.wMinute, tabTime.wSecond)
    local strTime1 = string.format("%d-%02d-%02d", tabTime.wYear, tabTime.wMonth, tabTime.wDay)
    local strTime2 = string.format("%02d:%02d:%02d",tabTime.wHour, tabTime.wMinute, tabTime.wSecond)
    local distime1 = cc.Label:createWithTTF(strTime1,"fonts/yehe_body.TTF",25)
    local distime2 = cc.Label:createWithTTF(strTime2,"fonts/yehe_body.TTF",25)
    distime1:setTextColor(cc.c3b(108,53,21))
    distime2:setTextColor(cc.c3b(108,53,21))
    if tabData.bFlagOnGame then
        distime1:setString("游戏中")
        distime1:setTextColor(cc.c3b(108,53,21))
    end
    item:addChild(distime1)
    item:addChild(distime2)
    distime1:setPosition(self.m_joinDisTime:getPositionX()+90, 50)
    distime2:setPosition(self.m_joinDisTime:getPositionX()+90, 25)

    item:setTouchEnabled(true)
    item:setSwallowTouches(false)
    local itemFunC = function(ref, tType)
        if tType == ccui.TouchEventType.ended then
            local tabDetail = tabData
            tabDetail.onGame = false--tabData.bFlagOnGame or false 
            tabDetail.enableDismiss = false
            local rd = RoomDetailLayer:create(tabDetail)
            rd:setName(ROOMDETAIL_NAME)
            self:addChild(rd)            
        end
    end
    item:addTouchEventListener( itemFunC )
    return item
end

return RoomRecordLayer_2